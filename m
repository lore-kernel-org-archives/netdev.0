From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-d80211: Add ID for ZyXEL ZyAIR G-220 v2
Date: Sun, 18 Feb 2007 01:40:41 +0000 (GMT)
Message-ID: <20070218014041.D25797B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested by Marijn Schouten
zd1211b chip 0586:340f v4810 high 00-13-49 AL2230_RF pa0 g---
FCC ID: I88G220V2

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/d80211/zd1211rw/zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
index 1e8a45e..aaa055d 100644
--- a/drivers/net/wireless/zd1211rw/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
@@ -60,6 +60,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x13b1, 0x0024), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x340f), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
-- 
1.5.0
