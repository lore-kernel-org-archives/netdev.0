From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for Linksys WUSBF54G
Date: Sat, 30 Dec 2006 22:38:23 +0000 (GMT)
Message-ID: <20061230223823.9D1DF7B40A1@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from queue02-winn.ispmail.ntl.com ([81.103.221.56]:58356 "EHLO
	queue02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030361AbWL3WsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Dec 2006 17:48:22 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by Henrik Hjelte
zd1211b chip 13b1:0024 v4802 high 00-14-bf AL2230_RF pa0 ----

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -60,6 +60,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x13b1, 0x0024), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
