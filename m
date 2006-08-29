From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for Siemens Gigaset USB Stick 54
Date: Tue, 29 Aug 2006 23:49:32 +0100 (BST)
Message-ID: <20060829224932.90A1C7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:21057 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S965029AbWH2WrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:47:19 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by Martin Dummer.

zd1211 chip 0b3b:5630 v4330 high 00-01-e3 RF2959_RF pa0 ---

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -44,6 +44,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x3204), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3402), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0b3b, 0x5630), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
