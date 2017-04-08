From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net: rfkill: gpio: Add OBDA8723 ACPI HID
Date: Sat,  8 Apr 2017 23:05:20 +0200
Message-ID: <20170408210520.2799-1-hdegoede@redhat.com>
Cc: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The OBDA8723 ACPI HID is used on quite a few Bay Trail based tablets
for bluetooth rfkill functionality.

Tested-by: russianneuromancer-k+OT61UuxXo@public.gmane.org <russianneuromancer-k+OT61UuxXo@public.gmane.org>
Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/rfkill/rfkill-gpio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 76c01cb..50ca65e 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -163,6 +163,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 static const struct acpi_device_id rfkill_acpi_match[] = {
 	{ "BCM4752", RFKILL_TYPE_GPS },
 	{ "LNV4752", RFKILL_TYPE_GPS },
+	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
 	{ },
 };
 MODULE_DEVICE_TABLE(acpi, rfkill_acpi_match);
-- 
2.9.3
