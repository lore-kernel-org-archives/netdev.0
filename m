From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 08/11] net: stmmac: prepare rx/tx set tail function for multiple queues
Date: Tue, 14 Mar 2017 10:24:30 +0000
Message-ID: <deb39228a77454f07561880076125146cc0dd099.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:49715 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdCNKY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:24:58 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares RX and TX set tail functions for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up the patch-set version

 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
index da54c0b..49f5687 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -37,12 +37,12 @@ int dwmac4_dma_reset(void __iomem *ioaddr)
 
 void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 {
-	writel(tail_ptr, ioaddr + DMA_CHAN_RX_END_ADDR(0));
+	writel(tail_ptr, ioaddr + DMA_CHAN_RX_END_ADDR(chan));
 }
 
 void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 {
-	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(0));
+	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(chan));
 }
 
 void dwmac4_dma_start_tx(void __iomem *ioaddr, u32 chan)
-- 
2.9.3
