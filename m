From: Schmiedl Christian <Christian.Schmiedl@gemalto.com>
Subject: [PATCH] qmi_wwan: Added support for Cinterion's PLxx WWAN Interface
Date: Tue, 21 May 2013 14:07:17 +0200
Message-ID: <376FB829F3ECB542B825EAF4D8CA8A97013E8459E48B@CROEXCFWP03.gemalto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>

Added support for Cinterion's PLxx WWAN Interface by adding QMI_FIXED_INTF with
Cinterion's Vendor ID as well as Product ID and WWAN Interface Number.

Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel@gemalto.com>
Signed-off-by: Christian Schmiedl <christian.schmiedl@gemalto.com>
---
patch is against linux-3.9
--- linux-3.9/drivers/net/usb/qmi_wwan.c.orig	2013-05-06 08:10:11.170034451 +0200
+++ linux-3.9/drivers/net/usb/qmi_wwan.c	2013-05-06 08:58:00.800264179 +0200
@@ -569,6 +569,7 @@ static const struct usb_device_id produc
 	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Alcatel One Touch L100V LTE) */
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
+	{QMI_FIXED_INTF(0x1e2d, 0x12d1, 4)},	/* Cinterion PLxx */

 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
