From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] Add support for SMSC LAN9530, LAN9730 and LAN89530
Date: Fri,  8 Apr 2011 19:51:59 +0100
Message-ID: <1302288719-17103-1-git-send-email-steve.glendinning@smsc.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([217.169.15.170]:43162 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756846Ab1DHS7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 14:59:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for SMSC's LAN9530, LAN9730 and LAN89530 USB
ethernet controllers to the existing smsc95xx driver by adding
their new USB VID/PID pairs.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 727874d..47a6c87 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1313,6 +1313,21 @@ static const struct usb_device_id products[] = {
 		USB_DEVICE(0x0424, 0x9909),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
+	{
+		/* SMSC LAN9530 USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9530),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC LAN9730 USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9730),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC LAN89530 USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9E08),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
 	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
-- 
1.7.2.5

