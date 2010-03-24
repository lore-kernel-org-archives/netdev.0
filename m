From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 5/7] wireless/prism54: remove trailing space in messages
Date: Wed, 24 Mar 2010 19:46:33 +0100
Message-ID: <1269456395-15343-5-git-send-email-elendil@planet.nl>
References: <201003241927.12434.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml109.kpnxchange.com ([195.121.3.13]:61674 "EHLO
	CPSMTPM-EML109.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932806Ab0CXSrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 14:47:39 -0400
In-Reply-To: <201003241927.12434.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: Luis R. Rodriguez <mcgrof@gmail.com>
---
 drivers/net/wireless/p54/txrx.c           |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c |   16 ++++++++--------
 drivers/net/wireless/prism54/islpci_eth.c |    8 ++++----
 drivers/net/wireless/prism54/islpci_mgt.c |    8 ++++----
 drivers/net/wireless/prism54/oid_mgt.c    |    2 +-
 5 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 6605799..2ceff54 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -38,7 +38,7 @@ static void p54_dump_tx_queue(struct p54_common *priv)
 	u32 largest_hole = 0, free;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
-	printk(KERN_DEBUG "%s: / --- tx queue dump (%d entries) --- \n",
+	printk(KERN_DEBUG "%s: / --- tx queue dump (%d entries) ---\n",
 	       wiphy_name(priv->hw->wiphy), skb_queue_len(&priv->tx_queue));
 
 	prev_addr = priv->rx_start;
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index a3ba353..7c82e43 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -227,14 +227,14 @@ islpci_interrupt(int irq, void *config)
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		DEBUG(SHOW_FUNCTION_CALLS,
-		      "IRQ: Identification register 0x%p 0x%x \n", device, reg);
+		      "IRQ: Identification register 0x%p 0x%x\n", device, reg);
 #endif
 
 		/* check for each bit in the register separately */
 		if (reg & ISL38XX_INT_IDENT_UPDATE) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			/* Queue has been updated */
-			DEBUG(SHOW_TRACING, "IRQ: Update flag \n");
+			DEBUG(SHOW_TRACING, "IRQ: Update flag\n");
 
 			DEBUG(SHOW_QUEUE_INDEXES,
 			      "CB drv Qs: [%i][%i][%i][%i][%i][%i]\n",
@@ -300,7 +300,7 @@ islpci_interrupt(int irq, void *config)
 						ISL38XX_CB_RX_DATA_LQ) != 0) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
 				DEBUG(SHOW_TRACING,
-				      "Received frame in Data Low Queue \n");
+				      "Received frame in Data Low Queue\n");
 #endif
 				islpci_eth_receive(priv);
 			}
@@ -325,7 +325,7 @@ islpci_interrupt(int irq, void *config)
 			/* Device has been initialized */
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			DEBUG(SHOW_TRACING,
-			      "IRQ: Init flag, device initialized \n");
+			      "IRQ: Init flag, device initialized\n");
 #endif
 			wake_up(&priv->reset_done);
 		}
@@ -333,7 +333,7 @@ islpci_interrupt(int irq, void *config)
 		if (reg & ISL38XX_INT_IDENT_SLEEP) {
 			/* Device intends to move to powersave state */
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			DEBUG(SHOW_TRACING, "IRQ: Sleep flag \n");
+			DEBUG(SHOW_TRACING, "IRQ: Sleep flag\n");
 #endif
 			isl38xx_handle_sleep_request(priv->control_block,
 						     &powerstate,
@@ -343,7 +343,7 @@ islpci_interrupt(int irq, void *config)
 		if (reg & ISL38XX_INT_IDENT_WAKEUP) {
 			/* Device has been woken up to active state */
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			DEBUG(SHOW_TRACING, "IRQ: Wakeup flag \n");
+			DEBUG(SHOW_TRACING, "IRQ: Wakeup flag\n");
 #endif
 
 			isl38xx_handle_wakeup(priv->control_block,
@@ -634,7 +634,7 @@ islpci_alloc_memory(islpci_private *priv)
 	      ioremap(pci_resource_start(priv->pdev, 0),
 		      ISL38XX_PCI_MEM_SIZE))) {
 		/* error in remapping the PCI device memory address range */
-		printk(KERN_ERR "PCI memory remapping failed \n");
+		printk(KERN_ERR "PCI memory remapping failed\n");
 		return -1;
 	}
 
@@ -901,7 +901,7 @@ islpci_setup(struct pci_dev *pdev)
 
 	if (register_netdev(ndev)) {
 		DEBUG(SHOW_ERROR_MESSAGES,
-		      "ERROR: register_netdev() failed \n");
+		      "ERROR: register_netdev() failed\n");
 		goto do_islpci_free_memory;
 	}
 
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 872b647..af9e7fb 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -89,7 +89,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	u32 curr_frag;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_transmit \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_transmit\n");
 #endif
 
 	/* lock the driver code */
@@ -140,7 +140,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 			}
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			DEBUG(SHOW_TRACING, "memmove %p %p %i \n", skb->data,
+			DEBUG(SHOW_TRACING, "memmove %p %p %i\n", skb->data,
 			      src, skb->len);
 #endif
 		} else {
@@ -319,7 +319,7 @@ islpci_eth_receive(islpci_private *priv)
 	int discard = 0;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_receive \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_receive\n");
 #endif
 
 	/* the device has written an Ethernet frame in the data area
@@ -431,7 +431,7 @@ islpci_eth_receive(islpci_private *priv)
 		skb = dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2);
 		if (unlikely(skb == NULL)) {
 			/* error allocating an sk_buff structure elements */
-			DEBUG(SHOW_ERROR_MESSAGES, "Error allocating skb \n");
+			DEBUG(SHOW_ERROR_MESSAGES, "Error allocating skb\n");
 			break;
 		}
 		skb_reserve(skb, (4 - (long) skb->data) & 0x03);
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
index 69d2f88..89b0278 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -113,7 +113,7 @@ islpci_mgmt_rx_fill(struct net_device *ndev)
 	u32 curr = le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ]);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgmt_rx_fill \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgmt_rx_fill\n");
 #endif
 
 	while (curr - priv->index_mgmt_rx < ISL38XX_CB_MGMT_QSIZE) {
@@ -211,7 +211,7 @@ islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 	{
 		pimfor_header_t *h = buf.mem;
 		DEBUG(SHOW_PIMFOR_FRAMES,
-		      "PIMFOR: op %i, oid 0x%08lx, device %i, flags 0x%x length 0x%x \n",
+		      "PIMFOR: op %i, oid 0x%08lx, device %i, flags 0x%x length 0x%x\n",
 		      h->operation, oid, h->device_id, h->flags, length);
 
 		/* display the buffer contents for debugging */
@@ -279,7 +279,7 @@ islpci_mgt_receive(struct net_device *ndev)
 	u32 curr_frag;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_receive \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_receive\n");
 #endif
 
 	/* Only once per interrupt, determine fragment range to
@@ -338,7 +338,7 @@ islpci_mgt_receive(struct net_device *ndev)
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		DEBUG(SHOW_PIMFOR_FRAMES,
-		      "PIMFOR: op %i, oid 0x%08x, device %i, flags 0x%x length 0x%x \n",
+		      "PIMFOR: op %i, oid 0x%08x, device %i, flags 0x%x length 0x%x\n",
 		      header->operation, header->oid, header->device_id,
 		      header->flags, header->length);
 
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index 1187e61..07df70a 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -819,7 +819,7 @@ mgt_response_to_str(enum oid_num_t n, union oid_res_t *r, char *str)
 			k = snprintf(str, PRIV_STR_SIZE, "nr=%u\n", list->nr);
 			for (i = 0; i < list->nr; i++)
 				k += snprintf(str + k, PRIV_STR_SIZE - k,
-					      "bss[%u] : \nage=%u\nchannel=%u\n"
+					      "bss[%u] :\nage=%u\nchannel=%u\n"
 					      "capinfo=0x%X\nrates=0x%X\n"
 					      "basic_rates=0x%X\n",
 					      i, list->bsslist[i].age,
-- 
1.6.6.1

