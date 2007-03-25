From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Add another ID for Linksys WUSBF54G
Date: Mon, 26 Mar 2007 00:20:25 +0100 (BST)
Message-ID: <20070325232025.7AFF97B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested by TiCPU on irc

zd1211 chip 13b1:001e v4802 high 00-14-bf AL2230_RF pa0 g---

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 24d22dc..1d84830 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -50,6 +50,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3401), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x14ea, 0xab13), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x13b1, 0x001e), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
-- 
1.5.0.5
