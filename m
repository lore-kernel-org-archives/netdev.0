From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Remove unnecessary skb->dev assignment
Date: Tue, 08 May 2007 00:46:04 +0900 (JST)
Message-ID: <20070508.004604.108738613.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:49897 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934347AbXEGPp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 11:45:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apply changes in commit 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0 to
newly added piece of code.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index f1e2dfc..463d600 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -540,7 +540,6 @@ static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
 	skb = dev_alloc_skb(RX_BUF_SIZE);
 	if (!skb)
 		return NULL;
-	skb->dev = dev;
 	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
 				     PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(*dma_handle)) {
