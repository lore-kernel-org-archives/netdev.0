From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add 3 more device IDs
Date: Tue, 26 Sep 2006 04:04:38 +0100 (BST)
Message-ID: <20060926030438.488CE7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:12946 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750793AbWIZDEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 23:04:41 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

iNexQ UR055g: Tested by Todor T Zviskov
zd1211 chip 1435:0711 v4330 high 00-10-a7 AL2230_RF pa0 g--

ZyXEL AG-225, FCC ID SI5WUB410: Tested by Nathan
zd1211 chip 0586:3409 v4810 full 00-13-49 AL7230B_RF pa0 g---

Yakumo QuickWLAN USB: Tested by EdB
zd1211 chip 0b3b:1630 v4330 high 00-01-36 RF2959_RF pa0 ---

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -47,6 +47,9 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0586, 0x3402), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b3b, 0x5630), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b05, 0x170c), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x1435, 0x0711), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0586, 0x3409), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
