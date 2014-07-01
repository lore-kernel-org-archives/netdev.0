From: Bernd Wachter <bernd.wachter@jolla.com>
Subject: [PATCH] net: qmi_wwan: Add ID for Telewell TW-LTE 4G v2
Date: Tue, 01 Jul 2014 22:01:09 +0300
Message-ID: <87vbrgewei.fsf@bwachter.lart.info>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There's a new version of the Telewell 4G modem working with, but not
recognized by this driver. 

Signed-off-by: Bernd Wachter <bernd.wachter@jolla.com>
---
--- linux-3.15.3/drivers/net/usb/qmi_wwan.c.orig	2014-07-01 21:31:07.000000000 +0300
+++ linux-3.15.3/drivers/net/usb/qmi_wwan.c	2014-07-01 20:39:30.000000000 +0300
@@ -741,6 +741,7 @@ static const struct usb_device_id produc
 	{QMI_FIXED_INTF(0x19d2, 0x1424, 2)},
 	{QMI_FIXED_INTF(0x19d2, 0x1425, 2)},
 	{QMI_FIXED_INTF(0x19d2, 0x1426, 2)},	/* ZTE MF91 */
+	{QMI_FIXED_INTF(0x19d2, 0x1428, 2)},	/* Telewell TW-LTE 4G v2 */
 	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
 	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 */
 	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
