From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add Sagem device ID's
Date: Wed,  5 Jul 2006 15:57:31 +0100 (BST)
Message-ID: <20060705145731.3F2B48AFF4E@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:44872 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S964893AbWGEO53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 10:57:29 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on a patch by Matthieu CASTET.

zd1211 chip 079b:004a v4330 high 00-60-b3 AL2230_RF pa0 g--
zd1211b chip 079b:0062 v4810 high 00-60-b3 AL2230_RF pa0 g--

Signed-off-by: Daniel Drake <dsd@gentoo.org>

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 72f9052..c68b9f8 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -39,9 +39,11 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{}
 };
