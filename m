From: Qinghuang Feng <qhfeng.kernel@gmail.com>
Subject: [PATCH 1/3] driver/net/*: remove redundant argument comments
Date: Sat, 22 Nov 2008 15:40:53 +0800
Message-ID: <4927b790.0e0d6e0a.65cc.ffffcb05@mx.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:1622 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbYKVHlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:41:06 -0500
Received: by ti-out-0910.google.com with SMTP id b6so794719tic.23
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 23:41:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove redundant argument comments in files of drivers/net/*

Signed-off-by: Qinghuang Feng <qhfeng.kernel@gmail.com>
---
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 91795f7..122539a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -345,7 +345,6 @@ no_buffers:
 /**
  * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
  * @adapter: address of board private structure
- * @rx_ring: pointer to receive ring structure
  * @cleaned_count: number of buffers to allocate this pass
  **/
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1cbae85..20d27e6 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1980,7 +1980,6 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 
 /**
  * igb_free_tx_resources - Free Tx Resources per Queue
- * @adapter: board private structure
  * @tx_ring: Tx descriptor ring for a specific queue
  *
  * Free all transmit software resources
@@ -2033,7 +2032,6 @@ static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
 
 /**
  * igb_clean_tx_ring - Free Tx Buffers
- * @adapter: board private structure
  * @tx_ring: ring to be cleaned
  **/
 static void igb_clean_tx_ring(struct igb_ring *tx_ring)
@@ -2080,7 +2078,6 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
 
 /**
  * igb_free_rx_resources - Free Rx Resources
- * @adapter: board private structure
  * @rx_ring: ring to clean the resources from
  *
  * Free all receive software resources
@@ -2120,7 +2117,6 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
 
 /**
  * igb_clean_rx_ring - Free Rx Buffers per Queue
- * @adapter: board private structure
  * @rx_ring: ring to free buffers from
  **/
 static void igb_clean_rx_ring(struct igb_ring *rx_ring)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 36f2bb6..b2a7ea8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1320,7 +1320,6 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
  * ixgbe_intr - legacy mode Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
  **/
 static irqreturn_t ixgbe_intr(int irq, void *data)
 {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index b37a498..a5c3c5c 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1174,7 +1174,6 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
  * ax_interrupt - handle the interrupts from an 8390
  * @irq: interrupt number
  * @dev_id: a pointer to the net_device
- * @regs: unused
  *
  * Handle the ether interface interrupts. We pull packets from
  * the 8390 via the card specific functions and fire them at the networking
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index fa3a460..8e8337e 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1630,7 +1630,6 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
  *	sis900_interrupt - sis900 interrupt handler
  *	@irq: the irq number
  *	@dev_instance: the client data object
- *	@regs: snapshot of processor context
  *
  *	The interrupt handler does all of the Rx thread work,
  *	and cleans up after the Tx thread
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index b6435d0..07599b4 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -672,7 +672,6 @@ write_hash:
 /**
  * spider_net_prepare_tx_descr - fill tx descriptor with skb data
  * @card: card structure
- * @descr: descriptor structure to fill out
  * @skb: packet to use
  *
  * returns 0 on success, <0 on failure.
@@ -867,7 +866,6 @@ spider_net_release_tx_chain(struct spider_net_card *card, int brutal)
 /**
  * spider_net_kick_tx_dma - enables TX DMA processing
  * @card: card structure
- * @descr: descriptor address to enable TX processing at
  *
  * This routine will start the transmit DMA running if
  * it is not already running. This routine ned only be
@@ -1637,7 +1635,6 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
  * spider_net_interrupt - interrupt handler for spider_net
  * @irq: interrupt number
  * @ptr: pointer to net_device
- * @regs: PU registers
  *
  * returns IRQ_HANDLED, if interrupt was for driver, or IRQ_NONE, if no
  * interrupt found raised by card.
@@ -2419,7 +2416,6 @@ spider_net_undo_pci_setup(struct spider_net_card *card)
 
 /**
  * spider_net_setup_pci_dev - sets up the device in terms of PCI operations
- * @card: card structure
  * @pdev: PCI device
  *
  * Returns the card structure or NULL if any errors occur

