From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 04/11] can: flexcan: fix i.MX6 state transition issue
Date: Thu, 19 Oct 2017 13:19:38 +0200
Message-ID: <20171019111945.13580-5-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>,
        Zhu Yi <yi.zhu5@cn.bosch.com>,
        Mark Jonas <mark.jonas@de.bosch.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>

Enable FLEXCAN_QUIRK_BROKEN_PERR_STATE for i.MX6 to report correct state
transitions.

Signed-off-by: Zhu Yi <yi.zhu5@cn.bosch.com>
Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v4.11
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index c83a09fa4166..d6ad12744ff1 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -289,7 +289,7 @@ static const struct flexcan_devtype_data fsl_imx28_devtype_data;
 
 static const struct flexcan_devtype_data fsl_imx6q_devtype_data = {
 	.quirks = FLEXCAN_QUIRK_DISABLE_RXFG | FLEXCAN_QUIRK_ENABLE_EACEN_RRS |
-		FLEXCAN_QUIRK_USE_OFF_TIMESTAMP,
+		FLEXCAN_QUIRK_USE_OFF_TIMESTAMP | FLEXCAN_QUIRK_BROKEN_PERR_STATE,
 };
 
 static const struct flexcan_devtype_data fsl_vf610_devtype_data = {
-- 
2.14.2
