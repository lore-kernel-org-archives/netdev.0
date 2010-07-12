From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso: remove driver version
Date: Mon, 12 Jul 2010 15:42:05 +0200
Message-ID: <1278942125.23105.39.camel@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch removes the driver version from the driver. This version hasn't changed since the driver's inclusion in the kernel and is a source
of confusion for some customers.

Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 4dd2351..41fc903 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -73,7 +73,6 @@
 #include <linux/serial.h>
 
 
-#define DRIVER_VERSION			"1.2"
 #define MOD_AUTHOR			"Option Wireless"
 #define MOD_DESCRIPTION			"USB High Speed Option driver"
 #define MOD_LICENSE			"GPL"
@@ -401,7 +400,7 @@ static int disable_net;
 /* driver info */
 static const char driver_name[] = "hso";
 static const char tty_filename[] = "ttyHS";
-static const char *version = __FILE__ ": " DRIVER_VERSION " " MOD_AUTHOR;
+static const char *version = __FILE__ ": " MOD_AUTHOR;
 /* the usb driver itself (registered in hso_init) */
 static struct usb_driver hso_driver;
 /* serial structures */
@@ -848,7 +847,6 @@ static void hso_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info
 	struct hso_net *odev = netdev_priv(net);
 
 	strncpy(info->driver, driver_name, ETHTOOL_BUSINFO_LEN);
-	strncpy(info->version, DRIVER_VERSION, ETHTOOL_BUSINFO_LEN);
 	usb_make_path(odev->parent->usb, info->bus_info, sizeof info->bus_info);
 }
 
@@ -3388,7 +3386,6 @@ module_exit(hso_exit);
 MODULE_AUTHOR(MOD_AUTHOR);
 MODULE_DESCRIPTION(MOD_DESCRIPTION);
 MODULE_LICENSE(MOD_LICENSE);
-MODULE_INFO(Version, DRIVER_VERSION);
 
 /* change the debug level (eg: insmod hso.ko debug=0x04) */
 MODULE_PARM_DESC(debug, "Level of debug [0x01 | 0x02 | 0x04 | 0x08 | 0x10]");

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
