From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: USB id 1582:6003 for Longshine 8131G3 added
Date: Sat, 12 Aug 2006 18:00:05 +0100 (BST)
Message-ID: <20060812170006.369CF8E7773@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:3786 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932573AbWHLRAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 13:00:04 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

The Longshine device is a ZD1211B and has a AL2230 RF. I tested it
successfully with no encryption and WEP.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -48,6 +48,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
