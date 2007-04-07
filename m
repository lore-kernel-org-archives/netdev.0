From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Add ID for ZyXEL AG-220
Date: Sat,  7 Apr 2007 15:45:39 +0100 (BST)
Message-ID: <20070407144539.3915D7B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested by Christoph Sager and Tomas Klas

zd1211b chip 0586:3412 v4810 high 00-13-49 AL7230B_RF pa0 g----

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 1d84830..533f189 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -64,6 +64,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0b05, 0x171b), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3410), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0baf, 0x0121), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
-- 
1.5.1
