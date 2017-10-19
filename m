From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 06/11] can: flexcan: fix p1010 state transition issue
Date: Thu, 19 Oct 2017 13:19:40 +0200
Message-ID: <20171019111945.13580-7-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>,
        Zhu Yi <yi.zhu5@cn.bosch.com>,
        Mark Jonas <mark.jonas@de.bosch.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>

Enable FLEXCAN_QUIRK_BROKEN_WERR_STATE and
FLEXCAN_QUIRK_BROKEN_PERR_STATE for p1010 to report correct state
transitions.

Signed-off-by: Zhu Yi <yi.zhu5@cn.bosch.com>
Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v4.11
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ed544c44848f..a13a4896a8bd 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -282,7 +282,8 @@ struct flexcan_priv {
 };
 
 static const struct flexcan_devtype_data fsl_p1010_devtype_data = {
-	.quirks = FLEXCAN_QUIRK_BROKEN_WERR_STATE,
+	.quirks = FLEXCAN_QUIRK_BROKEN_WERR_STATE |
+		FLEXCAN_QUIRK_BROKEN_PERR_STATE,
 };
 
 static const struct flexcan_devtype_data fsl_imx28_devtype_data = {
-- 
2.14.2

