From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Add ID for Sitecom WL-117
Date: Tue,  1 May 2007 17:14:30 +0100 (BST)
Message-ID: <20070501161430.9A8C07B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Cc: mj.davidson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Matthew Davidson <mj.davidson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This is another "driverless" device which first presents itself as a USB
CDROM drive. A separate patch has been submitted to make usb-storage
ignore that device, so that zd1211rw can eject it.

zd1211 chip 0df6:9075 v4916 full 00-0c-f6 AL2230_RF pa0 ----

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -40,6 +40,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x126f, 0xa006), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0df6, 0x9075), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
@@ -70,6 +71,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
+	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
 	{}
 };
 
