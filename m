From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: 2 new ZD1211B device ID's
Date: Tue, 12 Dec 2006 01:25:37 +0000 (GMT)
Message-ID: <20061212012537.1307B7B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:14658 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbWLLBZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:25:40 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philips SNU5600, tested by unibrow
zd1211b chip 0471:1236 v4810 high 00-12-bf AL2230_RF pa0 g--

SMC Ez Connect 802.11g (SMCWUSB-G), tested by Victorino Sanz Prat
zd1211b chip 083a:4505 v4810 full 00-13-f7 AL2230_RF pa0 g--N

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -58,6 +58,8 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
