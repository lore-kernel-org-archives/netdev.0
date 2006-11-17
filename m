From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for Belkin F5D7050 v4000
Date: Fri, 17 Nov 2006 00:26:40 +0000 (GMT)
Message-ID: <20061117002640.A31A97B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:47770 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1424805AbWKQA0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 19:26:34 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zd1211b chip 050d:705c v4810 high 00-17-3f AL2230_RF pa0 g--N

Tested by Bryan Barnard

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -57,6 +57,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
