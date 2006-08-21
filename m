From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 05/14] ipw2200: remove unused struct ipw_rx_buffer
Date: Mon, 21 Aug 2006 11:37:36 +0800
Message-ID: <20060821033736.GA5362@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17200 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932577AbWHUDjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:39:31 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    1 -
 drivers/net/wireless/ipw2200.h |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

03c243ef92ce7b04edb74b8a97bd112d06dafd86
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index e929f88..946d5b4 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -5043,7 +5043,6 @@ static void ipw_rx_queue_replenish(void 
 		}
 		list_del(element);
 
-		rxb->rxb = (struct ipw_rx_buffer *)rxb->skb->data;
 		rxb->dma_addr =
 		    pci_map_single(priv->pci_dev, rxb->skb->data,
 				   IPW_RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index b49f766..32b4ef8 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -713,7 +713,6 @@ struct ipw_rx_packet {
 
 struct ipw_rx_mem_buffer {
 	dma_addr_t dma_addr;
-	struct ipw_rx_buffer *rxb;
 	struct sk_buff *skb;
 	struct list_head list;
 };				/* Not transferred over network, so not  __attribute__ ((packed)) */
-- 
1.2.6
