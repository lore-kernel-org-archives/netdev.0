From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: sxgbe: make local functions static
Date: Thu, 17 Apr 2014 19:13:53 +0900
Message-ID: <004401cf5a25$bc8ed200$35ac7600$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Byungho An' <bh74.an@samsung.com>,
	'Girish K S' <ks.giri@samsung.com>,
	'Siva Reddy Kallam' <siva.kallam@samsung.com>,
	'Vipul Pandya' <vipul.pandya@samsung.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: netdev@vger.kernel.org, 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:64192 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbaDQKNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 06:13:55 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N46003H57362830@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 17 Apr 2014 19:13:54 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make local functions static, because these are used only in this
file.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index a72688e..dbb0abb 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -425,8 +425,8 @@ dmamem_err:
  * @rx_rsize: ring size
  * Description:  this function initializes the DMA RX descriptor
  */
-void free_rx_ring(struct device *dev, struct sxgbe_rx_queue *rx_ring,
-		  int rx_rsize)
+static void free_rx_ring(struct device *dev, struct sxgbe_rx_queue *rx_ring,
+			 int rx_rsize)
 {
 	dma_free_coherent(dev, rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
 			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
@@ -519,8 +519,8 @@ error:
  * @tx_rsize: ring size
  * Description:  this function initializes the DMA TX descriptor
  */
-void free_tx_ring(struct device *dev, struct sxgbe_tx_queue *tx_ring,
-		  int tx_rsize)
+static void free_tx_ring(struct device *dev, struct sxgbe_tx_queue *tx_ring,
+			 int tx_rsize)
 {
 	dma_free_coherent(dev, tx_rsize * sizeof(struct sxgbe_tx_norm_desc),
 			  tx_ring->dma_tx, tx_ring->dma_tx_phy);
@@ -1218,11 +1218,10 @@ static int sxgbe_release(struct net_device *dev)
 
 	return 0;
 }
-
 /* Prepare first Tx descriptor for doing TSO operation */
-void sxgbe_tso_prepare(struct sxgbe_priv_data *priv,
-		       struct sxgbe_tx_norm_desc *first_desc,
-		       struct sk_buff *skb)
+static void sxgbe_tso_prepare(struct sxgbe_priv_data *priv,
+			      struct sxgbe_tx_norm_desc *first_desc,
+			      struct sk_buff *skb)
 {
 	unsigned int total_hdr_len, tcp_hdr_len;
 
-- 
1.7.10.4
