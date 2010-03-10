From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 3/6] smsc95xx: add constant definition for SMSC USB vendor id
Date: Wed, 10 Mar 2010 18:32:36 +0000
Message-ID: <1268245959-13861-4-git-send-email-steve.glendinning@smsc.com>
References: <1268245959-13861-1-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-2-git-send-email-steve.glendinning@smsc.com>
 <1268245959-13861-3-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:41122 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932698Ab0CJScp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:32:45 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 0665767E44
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:32:40 +0000 (GMT)
In-Reply-To: <1268245959-13861-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index a2cb77d..a55dc27 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -45,6 +45,7 @@
 #define SMSC95XX_INTERNAL_PHY_ID	(1)
 #define SMSC95XX_TX_OVERHEAD		(8)
 #define SMSC95XX_TX_OVERHEAD_CSUM	(12)
+#define USB_VENDOR_ID_SMSC		(0x0424)
 
 struct smsc95xx_priv {
 	u32 mac_cr;
@@ -1225,77 +1226,77 @@ static const struct driver_info smsc95xx_info = {
 static const struct usb_device_id products[] = {
 	{
 		/* SMSC9500 USB Ethernet Device */
-		USB_DEVICE(0x0424, 0x9500),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9500),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9505 USB Ethernet Device */
-		USB_DEVICE(0x0424, 0x9505),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9505),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9500A USB Ethernet Device */
-		USB_DEVICE(0x0424, 0x9E00),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9E00),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9505A USB Ethernet Device */
-		USB_DEVICE(0x0424, 0x9E01),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9E01),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9512/9514 USB Hub & Ethernet Device */
-		USB_DEVICE(0x0424, 0xec00),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0xec00),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9500 USB Ethernet Device (SAL10) */
-		USB_DEVICE(0x0424, 0x9900),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9900),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9505 USB Ethernet Device (SAL10) */
-		USB_DEVICE(0x0424, 0x9901),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9901),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9500A USB Ethernet Device (SAL10) */
-		USB_DEVICE(0x0424, 0x9902),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9902),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9505A USB Ethernet Device (SAL10) */
-		USB_DEVICE(0x0424, 0x9903),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9903),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9512/9514 USB Hub & Ethernet Device (SAL10) */
-		USB_DEVICE(0x0424, 0x9904),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9904),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9500A USB Ethernet Device (HAL) */
-		USB_DEVICE(0x0424, 0x9905),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9905),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9505A USB Ethernet Device (HAL) */
-		USB_DEVICE(0x0424, 0x9906),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9906),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9500 USB Ethernet Device (Alternate ID) */
-		USB_DEVICE(0x0424, 0x9907),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9907),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9500A USB Ethernet Device (Alternate ID) */
-		USB_DEVICE(0x0424, 0x9908),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9908),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{
 		/* SMSC9512/9514 USB Hub & Ethernet Device (Alternate ID) */
-		USB_DEVICE(0x0424, 0x9909),
+		USB_DEVICE(USB_VENDOR_ID_SMSC, 0x9909),
 		.driver_info = (unsigned long) &smsc95xx_info,
 	},
 	{ },		/* END */
-- 
1.6.6.1

