From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH] mISDN: Add X-Tensions USB ISDN TA XC-525
Date: Tue, 22 May 2012 09:14:14 +0200
Message-ID: <1337670854-7008-1-git-send-email-keil@b1-systems.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:49598 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab2EVHZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 03:25:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to http://www.ip-phone-forum.de/showthread.php?t=225313 this
HW works. Thanks to Lars Immisch for pointing to this thread.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcsusb.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.h b/drivers/isdn/hardware/mISDN/hfcsusb.h
index cb1231b..4157311 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.h
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.h
@@ -410,6 +410,12 @@ static struct usb_device_id hfcsusb_idtab[] = {
 			{LED_SCHEME1, {0x88, -64, -32, -16},
 					"ZyXEL OMNI.NET USB II"}),
 	},
+	{
+		USB_DEVICE(0x1ae7, 0x0525),
+		.driver_info = (unsigned long) &((struct hfcsusb_vdata)
+			{LED_SCHEME1, {0x88, -64, -32, -16},
+					"X-Tensions USB ISDN TA XC-525"}),
+	},
 	{ }
 };
 
-- 
1.7.3.4
