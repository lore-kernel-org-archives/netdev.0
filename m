From: Jingchang Lu <b35083@freescale.com>
Subject: [PATCH] ethernet/fec: Add Vybrid family fec support
Date: Fri, 12 Apr 2013 15:12:45 +0800
Message-ID: <1365750765-3615-1-git-send-email-b35083@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <shawn.guo@linaro.org>,
	Jingchang Lu <b35083@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:36968
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753698Ab3DLHwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 03:52:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Freescale Vybrid platform implentments MAC-ENET core
providing compatibility with half- or full-duplex
10/100 Mbit/s Ethernet LANs.

Signed-off-by: Jingchang Lu <b35083@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f292c3a..c27d748 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -107,6 +107,9 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX,
 	}, {
+		.name = "mvf-fec",
+		.driver_data = FEC_QUIRK_ENET_MAC,
+	}, {
 		/* sentinel */
 	}
 };
@@ -117,6 +120,7 @@ enum imx_fec_type {
 	IMX27_FEC,	/* runs on i.mx27/35/51 */
 	IMX28_FEC,
 	IMX6Q_FEC,
+	MVF_FEC,
 };
 
 static const struct of_device_id fec_dt_ids[] = {
@@ -124,6 +128,7 @@ static const struct of_device_id fec_dt_ids[] = {
 	{ .compatible = "fsl,imx27-fec", .data = &fec_devtype[IMX27_FEC], },
 	{ .compatible = "fsl,imx28-fec", .data = &fec_devtype[IMX28_FEC], },
 	{ .compatible = "fsl,imx6q-fec", .data = &fec_devtype[IMX6Q_FEC], },
+	{ .compatible = "fsl,mvf-fec", .data = &fec_devtype[MVF_FEC], },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
-- 
1.8.0
