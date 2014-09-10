From: Frank Li <Frank.Li@freescale.com>
Subject: [Patch v3 net-next 08/12] net:fec: Add fsl,imx6sx-fec  compatible strings
Date: Thu, 11 Sep 2014 02:30:41 +0800
Message-ID: <1410373845-5801-9-git-send-email-Frank.Li@freescale.com>
References: <1410373845-5801-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux@arm.linux.org.uk>,
	Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0103.outbound.protection.outlook.com ([157.56.111.103]:30304
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753254AbaIJSyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 14:54:45 -0400
In-Reply-To: <1410373845-5801-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

Add compatible string "fsl,imx6sx-fec" for i.MX6SX.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 658b0b3..0cc7313 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -157,6 +157,7 @@ enum imx_fec_type {
 	IMX28_FEC,
 	IMX6Q_FEC,
 	MVF600_FEC,
+	IMX6SX_FEC,
 };
 
 static const struct of_device_id fec_dt_ids[] = {
@@ -165,6 +166,7 @@ static const struct of_device_id fec_dt_ids[] = {
 	{ .compatible = "fsl,imx28-fec", .data = &fec_devtype[IMX28_FEC], },
 	{ .compatible = "fsl,imx6q-fec", .data = &fec_devtype[IMX6Q_FEC], },
 	{ .compatible = "fsl,mvf600-fec", .data = &fec_devtype[MVF600_FEC], },
+	{ .compatible = "fsl,imx6sx-fec", .data = &fec_devtype[IMX6SX_FEC], },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
-- 
1.9.1
