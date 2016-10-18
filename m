From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v2 2/2] dwc_eth_qos: enable flow control by default
Date: Tue, 18 Oct 2016 09:20:55 +0200
Message-ID: <1476775255-14701-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Niklas Cassel <niklass@axis.com>,
        Jesper Nilsson <jespern@axis.com>
To: <larper@axis.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

Allow autoneg to enable flow control by default.
The behavior when autoneg is off has not changed.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
Signed-off-by: Jesper Nilsson <jespern@axis.com>
Acked-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index d775729648ef..5eedac495077 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -988,6 +988,7 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	lp->link    = 0;
 	lp->speed   = 0;
 	lp->duplex  = DUPLEX_UNKNOWN;
+	lp->flowcontrol.autoneg = AUTONEG_ENABLE;
 
 	return 0;
 }
-- 
2.1.4
