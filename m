From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 3/6] net: moxa: Fix comparison to NULL could be written with !
Date: Sat, 29 Jul 2017 18:42:36 +0800
Message-ID: <20170729104239.14999-4-sz.lin@moxa.com>
References: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729104239.14999-1-sz.lin@moxa.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed coding style for null comparisons in moxart_ether driver
to be more consistent with the rest of the kernel coding style

Signed-off-by: SZ Lin <sz.lin@moxa.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 9997e72103d5..1d6384873393 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -494,7 +494,7 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	priv->tx_desc_base = dma_alloc_coherent(NULL, TX_REG_DESC_SIZE *
 						TX_DESC_NUM, &priv->tx_base,
 						GFP_DMA | GFP_KERNEL);
-	if (priv->tx_desc_base == NULL) {
+	if (!priv->tx_desc_base) {
 		ret = -ENOMEM;
 		goto init_fail;
 	}
@@ -502,7 +502,7 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	priv->rx_desc_base = dma_alloc_coherent(NULL, RX_REG_DESC_SIZE *
 						RX_DESC_NUM, &priv->rx_base,
 						GFP_DMA | GFP_KERNEL);
-	if (priv->rx_desc_base == NULL) {
+	if (!priv->rx_desc_base) {
 		ret = -ENOMEM;
 		goto init_fail;
 	}
-- 
2.13.3
