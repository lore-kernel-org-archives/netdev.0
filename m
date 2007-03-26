From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add another ID for Linksys WUSBF54G
Date: Mon, 26 Mar 2007 01:00:12 +0100 (BST)
Message-ID: <20070326000012.20BE47B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:16397 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933103AbXCZAAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 20:00:09 -0400
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by TiCPU on irc

zd1211 chip 13b1:001e v4802 high 00-14-bf AL2230_RF pa0 g---

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-zd1211rw.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -52,6 +52,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3401), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x14ea, 0xab13), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x13b1, 0x001e), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
