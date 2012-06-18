From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH RESEND] net: lpc_eth: Driver cleanup
Date: Mon, 18 Jun 2012 22:14:42 +0200
Message-ID: <1340050482-22666-1-git-send-email-stigge@antcom.de>
Cc: Roland Stigge <stigge@antcom.de>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes some nowadays superfluous definitions (one unused define and
an obsolete function forward declaration) and corrects a netdev_err() to
netdev_dbg().

Signed-off-by: Roland Stigge <stigge@antcom.de>
Signed-off-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>

---
 Applies to: v3.5-rc3

 drivers/net/ethernet/nxp/lpc_eth.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
+++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
@@ -52,7 +52,6 @@
 
 #define MODNAME "lpc-eth"
 #define DRV_VERSION "1.00"
-#define PHYDEF_ADDR 0x00
 
 #define ENET_MAXF_SIZE 1536
 #define ENET_RX_DESC 48
@@ -416,9 +415,6 @@ static bool use_iram_for_net(struct devi
 #define TXDESC_CONTROL_LAST		(1 << 30)
 #define TXDESC_CONTROL_INT		(1 << 31)
 
-static int lpc_eth_hard_start_xmit(struct sk_buff *skb,
-				   struct net_device *ndev);
-
 /*
  * Structure of a TX/RX descriptors and RX status
  */
@@ -1442,7 +1438,7 @@ static int lpc_eth_drv_probe(struct plat
 			res->start);
 	netdev_dbg(ndev, "IO address size      :%d\n",
 			res->end - res->start + 1);
-	netdev_err(ndev, "IO address (mapped)  :0x%p\n",
+	netdev_dbg(ndev, "IO address (mapped)  :0x%p\n",
 			pldat->net_base);
 	netdev_dbg(ndev, "IRQ number           :%d\n", ndev->irq);
 	netdev_dbg(ndev, "DMA buffer size      :%d\n", pldat->dma_buff_size);
