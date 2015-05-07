From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: ll_temac: Use one return statement instead of two
Date: Thu,  7 May 2015 15:29:17 +0200
Message-ID: <b10b8e1e696a09152b9df535a8bd37e6500ac1c7.1431005352.git.michal.simek@xilinx.com>
Cc: Michal Simek <monstr@monstr.eu>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	Fabian Frederick <fabf@skynet.be>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Markus Elfring <elfring@users.sourceforge.net>,
	Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <monstr@monstr.eu>

Use one return statement instead of two to simplify the code.
Both are returning the same value.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/ll_temac_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 690a4c36b316..ca640d04fd93 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -688,10 +688,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 
 	if (temac_check_tx_bd_space(lp, num_frag)) {
-		if (!netif_queue_stopped(ndev)) {
+		if (!netif_queue_stopped(ndev))
 			netif_stop_queue(ndev);
-			return NETDEV_TX_BUSY;
-		}
 		return NETDEV_TX_BUSY;
 	}
 
-- 
2.3.5
