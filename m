From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for Asus WL-159g
Date: Tue, 29 Aug 2006 23:49:53 +0100 (BST)
Message-ID: <20060829224953.C30BC7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:6272 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S965150AbWH2Wrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:47:40 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by Vincent TOUCHARD

zd1211 chip 0b05:170c v4802 high 00-11-d8 AL2230_RF pa0 g---

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -45,6 +45,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x157e, 0x3204), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3402), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b3b, 0x5630), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0b05, 0x170c), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
