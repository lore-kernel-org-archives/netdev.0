From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for ZyXEL ZyAIR G-220 v2
Date: Thu,  4 Jan 2007 03:33:54 +0000 (GMT)
Message-ID: <20070104033354.D33EC7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:36948 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932245AbXADDd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 22:33:58 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by Marijn Schouten
zd1211b chip 0586:340f v4810 high 00-13-49 AL2230_RF pa0 g---
FCC ID: I88G220V2

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -61,6 +61,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x13b1, 0x0024), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x340f), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
