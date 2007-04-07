From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for ZyXEL AG-220
Date: Sat,  7 Apr 2007 16:00:43 +0100 (BST)
Message-ID: <20070407150043.123CA7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:42587 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966017AbXDGPAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2007 11:00:41 -0400
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by Christoph Sager and Tomas Klas

zd1211b chip 0586:3412 v4810 high 00-13-49 AL7230B_RF pa0 g----

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -66,6 +66,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0b05, 0x171b), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3410), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0baf, 0x0121), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
