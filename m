From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 07/10] net/macb: tx status is more than 8 bits now
Date: Wed, 5 Sep 2012 11:00:52 +0200
Message-ID: <7a88fcbd7812a7536fdfa1e1f83dd4ee77fdc319.1346775479.git.nicolas.ferre@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>, <nicolas.ferre@atmel.com>,
	<plagnioj@jcrosoft.com>, <jamie@jamieiles.com>,
	<linux-kernel@vger.kernel.org>, <patrice.vilchez@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some revision of GEM, TSR status register is has more information.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index af71151..bd331fd 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -390,7 +390,7 @@ static void macb_tx_interrupt(struct macb *bp)
 	status = macb_readl(bp, TSR);
 	macb_writel(bp, TSR, status);
 
-	netdev_vdbg(bp->dev, "macb_tx_interrupt status = %02lx\n",
+	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
 		(unsigned long)status);
 
 	head = bp->tx_head;
-- 
1.7.10
