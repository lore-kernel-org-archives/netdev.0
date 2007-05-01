From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-mac80211: Add ID for Sitecom WL-117
Date: Tue,  1 May 2007 04:03:40 +0100 (BST)
Message-ID: <20070501030340.34EEC7B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:31369 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754629AbXEADDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 23:03:44 -0400
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Cc: mj.davidson@gmail.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Davidson <mj.davidson@gmail.com>

This is another "driverless" device which first presents itself as a USB
CDROM drive. A separate patch has been submitted to make usb-storage
ignore that device, so that zd1211rw can eject it.

zd1211 chip 0df6:9075 v4916 full 00-0c-f6 AL2230_RF pa0 ----

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index b22d908..35f4383 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -38,6 +38,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x126f, 0xa006), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0df6, 0x9075), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
@@ -68,6 +69,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
+	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
 	{}
 };
 
-- 
1.5.1.2

