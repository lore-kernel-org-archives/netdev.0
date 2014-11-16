From: Martin Hauke <mardnh@gmx.de>
Subject: [PATCH] qmi_wwan: Add support for HP lt4112 LTE/HSPA+ Gobi 4G Modem
Date: Sun, 16 Nov 2014 19:55:25 +0100
Message-ID: <20141116185525.GA19989@gmx.de>
References: <20141116000322.GA22833@gmx.de>
 <871tp3gfpr.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:55521 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbaKPSzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2014 13:55:35 -0500
Content-Disposition: inline
In-Reply-To: <871tp3gfpr.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the USB VID/PID for the HP lt4112 LTE/HSPA+ Gobi 4G Modem (Huawei me906e)

Signed-off-by: Martin Hauke <mardnh@gmx.de>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 22756db..b8a82b8 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -780,6 +780,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x413c, 0x81a4, 8)},	/* Dell Wireless 5570e HSPA+ (42Mbps) Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a8, 8)},	/* Dell Wireless 5808 Gobi(TM) 4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) 4G LTE Mobile Broadband Card */
+	{QMI_FIXED_INTF(0x03f0, 0x581d, 4)},	/* HP lt4112 LTE/HSPA+ Gobi 4G Module (Huawei me906e) */
 
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
-- 
2.1.2
