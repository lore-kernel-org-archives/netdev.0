From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: add additional USB product IDs
Date: Tue, 22 Sep 2009 16:13:02 +0100
Message-ID: <1253632382-18458-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:39923 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756497AbZIVPNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 11:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   65 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 938fb35..3aafebd 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1237,10 +1237,75 @@ static const struct usb_device_id products[] = {
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
+		/* SMSC9505 USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9505),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9500A USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9E00),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9505A USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9E01),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
 		/* SMSC9512/9514 USB Hub & Ethernet Device */
 		USB_DEVICE(0x0424, 0xec00),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
+	{
+		/* SMSC9500 USB Ethernet Device (SAL10) */
+		USB_DEVICE(0x0424, 0x9900),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9505 USB Ethernet Device (SAL10) */
+		USB_DEVICE(0x0424, 0x9901),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9500A USB Ethernet Device (SAL10) */
+		USB_DEVICE(0x0424, 0x9902),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9505A USB Ethernet Device (SAL10) */
+		USB_DEVICE(0x0424, 0x9903),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9512/9514 USB Hub & Ethernet Device (SAL10) */
+		USB_DEVICE(0x0424, 0x9904),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9500A USB Ethernet Device (HAL) */
+		USB_DEVICE(0x0424, 0x9905),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9505A USB Ethernet Device (HAL) */
+		USB_DEVICE(0x0424, 0x9906),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9500 USB Ethernet Device (Alternate ID) */
+		USB_DEVICE(0x0424, 0x9907),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9500A USB Ethernet Device (Alternate ID) */
+		USB_DEVICE(0x0424, 0x9908),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{
+		/* SMSC9512/9514 USB Hub & Ethernet Device (Alternate ID) */
+		USB_DEVICE(0x0424, 0x9909),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
 	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
-- 
1.6.2.5

