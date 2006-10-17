From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for ZyXEL G-220
Date: Wed, 18 Oct 2006 00:17:02 +0100 (BST)
Message-ID: <20061017231702.55C0F7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:6831 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751072AbWJQXQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 19:16:56 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by Newsome on IRC

zd1211 chip 0586:3401 v4330 high 00-13-49 AL2230_RF  pa0 g---

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---

This is suitable for 2.6.19

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -50,6 +50,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x1435, 0x0711), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3409), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0586, 0x3401), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
