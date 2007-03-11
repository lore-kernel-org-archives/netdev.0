From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: More device IDs
Date: Sun, 11 Mar 2007 19:54:39 +0000 (GMT)
Message-ID: <20070311195439.0A3EF7B40A1@zog.reactivated.net>
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ASUS A9Rp
Tested by Serge
zd1211b chip 0b05:171b v4802 high 00-17-31 AL2230_RF pa0 g--

ZyXEL G-202
Tested by Marcus D. Hanwell
zd1211b chip 0586:3410 v4810 high 00-13-49 AL2230_RF pa0 g---

US Robotics USR805423
Tested by Pascal S. de Kloe
FCC ID: RAXWN4501H
zd1211b chip 0baf:0121 v4810 high 00-14-c1 AL2230_RF pa0 g--N
Julien Pinon reports this also comes in AL2230S form

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_usb.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -62,6 +62,9 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x13b1, 0x0024), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x340f), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0b05, 0x171b), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x3410), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0baf, 0x0121), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
