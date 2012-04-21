From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 27/28] mISDN: Add X-Tensions USB ISDN TA XC-525
Date: Sat, 21 Apr 2012 18:19:17 +0200
Message-ID: <20120423170551.C07889FBA7@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:53168 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276Ab2DWRIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From  http://www.ip-phone-forum.de/showthread.php?t=225313
Thanks to Lars Immisch for pointing to this.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcsusb.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.h b/drivers/isdn/hardware/mISDN/hfcsusb.h
index 7d48b86..56e9755 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.h
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.h
@@ -341,6 +341,12 @@ static const char *HFC_NT_LAYER1_STATES[HFC_MAX_NT_LAYER1_STATE + 1] = {
 /* supported devices */
 static struct usb_device_id hfcsusb_idtab[] = {
 	{
+		USB_DEVICE(0x1ae7, 0x0525),
+		.driver_info = (unsigned long) &((struct hfcsusb_vdata)
+			       {LED_SCHEME1, {0x88, -64, -32, -16},
+			       "X-Tensions USB ISDN TA XC-525"}),
+	},
+	{
 		USB_DEVICE(0x0959, 0x2bd0),
 		.driver_info = (unsigned long) &((struct hfcsusb_vdata)
 			{LED_OFF, {4, 0, 2, 1},
-- 
1.7.3.4
