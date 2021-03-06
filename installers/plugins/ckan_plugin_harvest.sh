clear
echo    "# ======================================================== #"
echo    "# == Easy CKAN : [PLUGIN] Harvest installation          == #"
echo    "# ======================================================== #"
su -c "sleep 2"

cd /tmp

# Redis database
# ==============================================
echo    "| Install Redis Server"
apt-get install -y redis-server
sed -i "s/## Plugins Settings/## Plugins Settings\n\n# Harvest plugin dependence\nckan.harvest.mq.type = redis\n/g" /etc/ckan/default/development.ini


# Install Harvest plugin
# ==============================================
echo    "| Install Harvest from GitHub"
su -s /bin/bash - ckan -c ". /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/ckan/ckanext-harvest.git@v0.0.5#egg=ckanext-harvest"
su -s /bin/bash - ckan -c ". /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-harvest/pip-requirements.txt"


# Activate Harvest plugin
# ==============================================
echo    "| Active Harvest plugin on CKAN config file"
sed -i 's/harvest ckan_harvester/ /g' /etc/ckan/default/development.ini # FIX DUPLICATE ON SECOND INSTALLATION
sed -i 's/ckan.plugins = /ckan.plugins = harvest ckan_harvester /g' /etc/ckan/default/development.ini


# Configuration of Harvest plugin
# ==============================================
echo    "| Install Harvest modifications on database"
su -s /bin/bash - ckan -c ". /usr/lib/ckan/default/bin/activate && paster --plugin=ckanext-harvest harvester initdb --config=/etc/ckan/default/development.ini"


# Creating helper (deprecated on version 0.2)
# ==============================================
# echo    "| Creating Helper"
# mkdir -p /root/easy_ckan/
# cp /tmp/Easy-CKAN/helpers/harvest.sh /root/easy_ckan/harvest.sh
# cp /tmp/Easy-CKAN/helpers/harvest_background.sh /root/easy_ckan/harvest_background.sh


# Install on startup (init.d)
# ==============================================
# rm -f /etc/init.d/easyckan_harvest
# rm -f /etc/rc0.d/easyckan_harvest
# cp /etc/easyckan/helpers/harvest_background /etc/init.d/easyckan_harvest
# ln -s /etc/init.d/easyckan_harvest /etc/rc0.d/easyckan_harvest
# chmod +x /etc/easyckan/helpers/harvest_background
# chmod +x /etc/init.d/easyckan_harvest
# chmod +x /etc/rc0.d/easyckan_harvest


# Crontab
# ==============================================
chmod +x /etc/easyckan/helpers/harvest_background
echo "@reboot /etc/easyckan/helpers/harvest_background" > /tmp/cron_harvest
crontab -u root /tmp/cron_harvest


echo    "| Starting Harvest daemon...#"
/etc/easyckan/helpers/harvest_background


echo    "# Harvest was installed! #"
