From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 6/9] net/tokenring: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:33 +0100
Message-ID: <1269453456-13599-6-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml109.kpnxchange.com ([195.121.3.13]:56334 "EHLO
	CPSMTPM-EML109.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932571Ab0CXR5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 13:57:44 -0400
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trailing spaces in files in /proc for lanstreamer.c and olympic.c
have been left as they are.

Signed-off-by: Frans Pop <elendil@planet.nl>
---

I've ignored the many, many (trailing) whitespace issues in 3c359.c
and olympic.c. Fixing them would drown out the actual changes.
---
 drivers/net/tokenring/3c359.c       |  100 +++++++++++++++++-----------------
 drivers/net/tokenring/lanstreamer.c |   46 ++++++++--------
 drivers/net/tokenring/olympic.c     |   62 +++++++++++-----------
 drivers/net/tokenring/tms380tr.c    |    4 +-
 4 files changed, 106 insertions(+), 106 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 0fb930f..7e70d00 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -76,7 +76,7 @@ static char version[] __devinitdata  =
 
 #define FW_NAME		"3com/3C359.bin"
 MODULE_AUTHOR("Mike Phillips <mikep@linuxtr.net>") ; 
-MODULE_DESCRIPTION("3Com 3C359 Velocity XL Token Ring Adapter Driver \n") ;
+MODULE_DESCRIPTION("3Com 3C359 Velocity XL Token Ring Adapter Driver\n") ;
 MODULE_FIRMWARE(FW_NAME);
 
 /* Module parameters */
@@ -162,19 +162,19 @@ static void print_tx_state(struct net_device *dev)
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	int i ; 
 
-	printk("tx_ring_head: %d, tx_ring_tail: %d, free_ent: %d \n",xl_priv->tx_ring_head, 
+	printk("tx_ring_head: %d, tx_ring_tail: %d, free_ent: %d\n",xl_priv->tx_ring_head, 
 		xl_priv->tx_ring_tail, xl_priv->free_ring_entries) ; 
-	printk("Ring    , Address ,   FSH  , DnNextPtr, Buffer, Buffer_Len \n"); 
+	printk("Ring    , Address ,   FSH  , DnNextPtr, Buffer, Buffer_Len\n"); 
 	for (i = 0; i < 16; i++) {
 		txd = &(xl_priv->xl_tx_ring[i]) ; 
-		printk("%d, %08lx, %08x, %08x, %08x, %08x \n", i, virt_to_bus(txd), 
+		printk("%d, %08lx, %08x, %08x, %08x, %08x\n", i, virt_to_bus(txd), 
 			txd->framestartheader, txd->dnnextptr, txd->buffer, txd->buffer_length ) ; 
 	}
 
-	printk("DNLISTPTR = %04x \n", readl(xl_mmio + MMIO_DNLISTPTR) ); 
+	printk("DNLISTPTR = %04x\n", readl(xl_mmio + MMIO_DNLISTPTR) ); 
 	
-	printk("DmaCtl = %04x \n", readl(xl_mmio + MMIO_DMA_CTRL) ); 
-	printk("Queue status = %0x \n",netif_running(dev) ) ; 
+	printk("DmaCtl = %04x\n", readl(xl_mmio + MMIO_DMA_CTRL) ); 
+	printk("Queue status = %0x\n",netif_running(dev) ) ; 
 }
 
 static void print_rx_state(struct net_device *dev)
@@ -185,19 +185,19 @@ static void print_rx_state(struct net_device *dev)
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	int i ; 
 
-	printk("rx_ring_tail: %d \n", xl_priv->rx_ring_tail) ; 
-	printk("Ring    , Address ,   FrameState  , UPNextPtr, FragAddr, Frag_Len \n"); 
+	printk("rx_ring_tail: %d\n", xl_priv->rx_ring_tail) ; 
+	printk("Ring    , Address ,   FrameState  , UPNextPtr, FragAddr, Frag_Len\n"); 
 	for (i = 0; i < 16; i++) { 
 		/* rxd = (struct xl_rx_desc *)xl_priv->rx_ring_dma_addr + (i * sizeof(struct xl_rx_desc)) ; */
 		rxd = &(xl_priv->xl_rx_ring[i]) ; 
-		printk("%d, %08lx, %08x, %08x, %08x, %08x \n", i, virt_to_bus(rxd), 
+		printk("%d, %08lx, %08x, %08x, %08x, %08x\n", i, virt_to_bus(rxd), 
 			rxd->framestatus, rxd->upnextptr, rxd->upfragaddr, rxd->upfraglen ) ; 
 	}
 
-	printk("UPLISTPTR = %04x \n", readl(xl_mmio + MMIO_UPLISTPTR) ); 
+	printk("UPLISTPTR = %04x\n", readl(xl_mmio + MMIO_UPLISTPTR) ); 
 	
-	printk("DmaCtl = %04x \n", readl(xl_mmio + MMIO_DMA_CTRL) ); 
-	printk("Queue status = %0x \n",netif_running(dev) ) ;
+	printk("DmaCtl = %04x\n", readl(xl_mmio + MMIO_DMA_CTRL) ); 
+	printk("Queue status = %0x\n",netif_running(dev) ) ;
 } 
 #endif
 
@@ -390,7 +390,7 @@ static int __devinit xl_init(struct net_device *dev)
 	struct xl_private *xl_priv = netdev_priv(dev);
 	int err;
 
-	printk(KERN_INFO "%s \n", version);
+	printk(KERN_INFO "%s\n", version);
 	printk(KERN_INFO "%s: I/O at %hx, MMIO at %p, using irq %d\n",
 		xl_priv->xl_card_name, (unsigned int)dev->base_addr ,xl_priv->xl_mmio, dev->irq);
 
@@ -462,7 +462,7 @@ static int xl_hw_reset(struct net_device *dev)
 	writel( (IO_WORD_READ | PMBAR),xl_mmio + MMIO_MAC_ACCESS_CMD);  
 
 #if XL_DEBUG
-	printk(KERN_INFO "Read from PMBAR = %04x \n", readw(xl_mmio + MMIO_MACDATA)) ; 
+	printk(KERN_INFO "Read from PMBAR = %04x\n", readw(xl_mmio + MMIO_MACDATA)) ; 
 #endif
 
 	if ( readw( (xl_mmio + MMIO_MACDATA))  & PMB_CPHOLD ) { 
@@ -590,9 +590,9 @@ static int xl_hw_reset(struct net_device *dev)
 #if XL_DEBUG
 	writel(IO_WORD_READ | SWITCHSETTINGS, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
 	if ( readw(xl_mmio + MMIO_MACDATA) & 2) { 
-		printk(KERN_INFO "Default ring speed 4 mbps \n") ;
+		printk(KERN_INFO "Default ring speed 4 mbps\n") ;
 	} else {
-		printk(KERN_INFO "Default ring speed 16 mbps \n") ; 
+		printk(KERN_INFO "Default ring speed 16 mbps\n") ; 
 	} 
 	printk(KERN_INFO "%s: xl_priv->srb = %04x\n",xl_priv->xl_card_name, xl_priv->srb);
 #endif
@@ -650,7 +650,7 @@ static int xl_open(struct net_device *dev)
 
 	if (open_err != 0) { /* Something went wrong with the open command */
 		if (open_err & 0x07) { /* Wrong speed, retry at different speed */
-			printk(KERN_WARNING "%s: Open Error, retrying at different ringspeed \n", dev->name) ; 
+			printk(KERN_WARNING "%s: Open Error, retrying at different ringspeed\n", dev->name) ; 
 			switchsettings = switchsettings ^ 2 ; 
 			xl_ee_write(dev,0x08,switchsettings) ; 
 			xl_hw_reset(dev) ; 
@@ -702,7 +702,7 @@ static int xl_open(struct net_device *dev)
 	}
 
 	if (i==0) { 
-		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers. Adapter disabled \n",dev->name) ; 
+		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers. Adapter disabled\n",dev->name) ; 
 		free_irq(dev->irq,dev) ; 
 		kfree(xl_priv->xl_tx_ring);
 		kfree(xl_priv->xl_rx_ring);
@@ -852,7 +852,7 @@ static int xl_open_hw(struct net_device *dev)
  
 		writel( (MEM_WORD_READ | 0xD0000 | xl_priv->srb) + 12, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
 		xl_priv->arb = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
-		printk(", ARB: %04x \n",xl_priv->arb ) ; 
+		printk(", ARB: %04x\n",xl_priv->arb ) ; 
 		writel( (MEM_WORD_READ | 0xD0000 | xl_priv->srb) + 14, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
 		vsoff = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
 
@@ -866,7 +866,7 @@ static int xl_open_hw(struct net_device *dev)
 			ver_str[i] = readb(xl_mmio + MMIO_MACDATA) ; 
 		}
 		ver_str[i] = '\0' ; 
-		printk(KERN_INFO "%s: Microcode version String: %s \n",dev->name,ver_str); 
+		printk(KERN_INFO "%s: Microcode version String: %s\n",dev->name,ver_str); 
 	} 	
 	
 	/*
@@ -990,7 +990,7 @@ static void xl_rx(struct net_device *dev)
 			skb = dev_alloc_skb(xl_priv->pkt_buf_sz) ; 
 
 			if (skb==NULL) { /* Still need to fix the rx ring */
-				printk(KERN_WARNING "%s: dev_alloc_skb failed in rx, single buffer \n",dev->name) ; 
+				printk(KERN_WARNING "%s: dev_alloc_skb failed in rx, single buffer\n",dev->name) ; 
 				adv_rx_ring(dev) ; 
 				dev->stats.rx_dropped++ ; 
 				writel(ACK_INTERRUPT | UPCOMPACK | LATCH_ACK , xl_mmio + MMIO_COMMAND) ; 
@@ -1091,7 +1091,7 @@ static irqreturn_t xl_interrupt(int irq, void *dev_id)
 	 */
 	if (intstatus == 0x0001) {  
 		writel(ACK_INTERRUPT | LATCH_ACK, xl_mmio + MMIO_COMMAND) ;
-		printk(KERN_INFO "%s: 00001 int received \n",dev->name) ;  
+		printk(KERN_INFO "%s: 00001 int received\n",dev->name) ;  
 	} else {  
 		if (intstatus &	(HOSTERRINT | SRBRINT | ARBCINT | UPCOMPINT | DNCOMPINT | HARDERRINT | (1<<8) | TXUNDERRUN | ASBFINT)) { 
 			
@@ -1102,9 +1102,9 @@ static irqreturn_t xl_interrupt(int irq, void *dev_id)
 			 */
 
 			if (intstatus & HOSTERRINT) {
-				printk(KERN_WARNING "%s: Host Error, performing global reset, intstatus = %04x \n",dev->name,intstatus) ; 
+				printk(KERN_WARNING "%s: Host Error, performing global reset, intstatus = %04x\n",dev->name,intstatus) ; 
 				writew( GLOBAL_RESET, xl_mmio + MMIO_COMMAND ) ;
-				printk(KERN_WARNING "%s: Resetting hardware: \n", dev->name); 
+				printk(KERN_WARNING "%s: Resetting hardware:\n", dev->name); 
 				netif_stop_queue(dev) ;
 				xl_freemem(dev) ; 
 				free_irq(dev->irq,dev); 	
@@ -1127,7 +1127,7 @@ static irqreturn_t xl_interrupt(int irq, void *dev_id)
 					Must put a timeout check here ! */
 					/* Empty Loop */
 				} 
-				printk(KERN_WARNING "%s: TX Underrun received \n",dev->name) ;
+				printk(KERN_WARNING "%s: TX Underrun received\n",dev->name) ;
 				writel(ACK_INTERRUPT | LATCH_ACK, xl_mmio + MMIO_COMMAND) ; 
 			} /* TxUnderRun */
 	
@@ -1156,13 +1156,13 @@ static irqreturn_t xl_interrupt(int irq, void *dev_id)
 				macstatus = readw(xl_mmio + MMIO_MACDATA) ; 
 				printk(KERN_WARNING "%s: MacStatusError, details: ", dev->name);
 				if (macstatus & (1<<14)) 
-					printk(KERN_WARNING "tchk error: Unrecoverable error \n") ; 
+					printk(KERN_WARNING "tchk error: Unrecoverable error\n") ; 
 				if (macstatus & (1<<3))
-					printk(KERN_WARNING "eint error: Internal watchdog timer expired \n") ;
+					printk(KERN_WARNING "eint error: Internal watchdog timer expired\n") ;
 				if (macstatus & (1<<2))
-					printk(KERN_WARNING "aint error: Host tried to perform invalid operation \n") ; 
+					printk(KERN_WARNING "aint error: Host tried to perform invalid operation\n") ; 
 				printk(KERN_WARNING "Instatus = %02x, macstatus = %02x\n",intstatus,macstatus) ; 
-				printk(KERN_WARNING "%s: Resetting hardware: \n", dev->name); 
+				printk(KERN_WARNING "%s: Resetting hardware:\n", dev->name); 
 				netif_stop_queue(dev) ;
 				xl_freemem(dev) ; 
 				free_irq(dev->irq,dev); 
@@ -1174,7 +1174,7 @@ static irqreturn_t xl_interrupt(int irq, void *dev_id)
 				return IRQ_HANDLED;
 			}
 		} else { 
-			printk(KERN_WARNING "%s: Received Unknown interrupt : %04x \n", dev->name, intstatus) ;
+			printk(KERN_WARNING "%s: Received Unknown interrupt : %04x\n", dev->name, intstatus) ;
 			writel(ACK_INTERRUPT | LATCH_ACK, xl_mmio + MMIO_COMMAND) ; 	
 		}
 	} 
@@ -1349,11 +1349,11 @@ static int xl_close(struct net_device *dev)
 
 	writel(MEM_BYTE_READ | 0xd0000 | xl_priv->srb, xl_mmio + MMIO_MAC_ACCESS_CMD);
 	if (readb(xl_mmio + MMIO_MACDATA) != CLOSE_NIC) { 
-		printk(KERN_INFO "%s: CLOSE_NIC did not get a CLOSE_NIC response \n",dev->name) ; 
+		printk(KERN_INFO "%s: CLOSE_NIC did not get a CLOSE_NIC response\n",dev->name) ; 
 	} else { 
 		writel((MEM_BYTE_READ | 0xd0000 | xl_priv->srb) +2, xl_mmio + MMIO_MAC_ACCESS_CMD) ;
 		if (readb(xl_mmio + MMIO_MACDATA)==0) { 
-			printk(KERN_INFO "%s: Adapter has been closed \n",dev->name) ;
+			printk(KERN_INFO "%s: Adapter has been closed\n",dev->name) ;
 			writew(ACK_INTERRUPT | SRBRACK | LATCH_ACK, xl_mmio + MMIO_COMMAND) ; 
 
 			xl_freemem(dev) ; 
@@ -1446,11 +1446,11 @@ static void xl_srb_bh(struct net_device *dev)
 		printk(KERN_INFO "%s: Command: %d - Invalid Command code\n",dev->name,srb_cmd) ; 
 		break ; 
 	case 4:
-		printk(KERN_INFO "%s: Command: %d - Adapter is closed, must be open for this command \n",dev->name,srb_cmd) ; 
+		printk(KERN_INFO "%s: Command: %d - Adapter is closed, must be open for this command\n",dev->name,srb_cmd) ; 
 		break ;
 	
 	case 6:
-		printk(KERN_INFO "%s: Command: %d - Options Invalid for command \n",dev->name,srb_cmd) ;
+		printk(KERN_INFO "%s: Command: %d - Options Invalid for command\n",dev->name,srb_cmd) ;
 		break ;
 
 	case 0: /* Successful command execution */ 
@@ -1471,11 +1471,11 @@ static void xl_srb_bh(struct net_device *dev)
 			break ; 
 		case SET_FUNC_ADDRESS:
 			if(xl_priv->xl_message_level) 
-				printk(KERN_INFO "%s: Functional Address Set \n",dev->name) ;  
+				printk(KERN_INFO "%s: Functional Address Set\n",dev->name) ;  
 			break ; 
 		case CLOSE_NIC:
 			if(xl_priv->xl_message_level)
-				printk(KERN_INFO "%s: Received CLOSE_NIC interrupt in interrupt handler \n",dev->name) ; 	
+				printk(KERN_INFO "%s: Received CLOSE_NIC interrupt in interrupt handler\n",dev->name) ; 	
 			break ; 
 		case SET_MULTICAST_MODE:
 			if(xl_priv->xl_message_level)
@@ -1484,9 +1484,9 @@ static void xl_srb_bh(struct net_device *dev)
 		case SET_RECEIVE_MODE:
 			if(xl_priv->xl_message_level) {  
 				if (xl_priv->xl_copy_all_options == 0x0004) 
-					printk(KERN_INFO "%s: Entering promiscuous mode \n", dev->name) ; 
+					printk(KERN_INFO "%s: Entering promiscuous mode\n", dev->name) ; 
 				else
-					printk(KERN_INFO "%s: Entering normal receive mode \n",dev->name) ; 
+					printk(KERN_INFO "%s: Entering normal receive mode\n",dev->name) ; 
 			}
 			break ; 
  
@@ -1556,20 +1556,20 @@ static void xl_arb_cmd(struct net_device *dev)
 			xl_freemem(dev) ; 
 			free_irq(dev->irq,dev);
 			
-			printk(KERN_WARNING "%s: Adapter has been closed \n", dev->name) ; 
+			printk(KERN_WARNING "%s: Adapter has been closed\n", dev->name) ; 
 		} /* If serious error */
 		
 		if (xl_priv->xl_message_level) { 
 			if (lan_status_diff & LSC_SIG_LOSS) 
-					printk(KERN_WARNING "%s: No receive signal detected \n", dev->name) ; 
+					printk(KERN_WARNING "%s: No receive signal detected\n", dev->name) ; 
 			if (lan_status_diff & LSC_HARD_ERR)
-					printk(KERN_INFO "%s: Beaconing \n",dev->name);
+					printk(KERN_INFO "%s: Beaconing\n",dev->name);
 			if (lan_status_diff & LSC_SOFT_ERR)
-					printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac Frame \n",dev->name);
+					printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac Frame\n",dev->name);
 			if (lan_status_diff & LSC_TRAN_BCN) 
 					printk(KERN_INFO "%s: We are tranmitting the beacon, aaah\n",dev->name);
 			if (lan_status_diff & LSC_SS) 
-					printk(KERN_INFO "%s: Single Station on the ring \n", dev->name);
+					printk(KERN_INFO "%s: Single Station on the ring\n", dev->name);
 			if (lan_status_diff & LSC_RING_REC)
 					printk(KERN_INFO "%s: Ring recovery ongoing\n",dev->name);
 			if (lan_status_diff & LSC_FDX_MODE)
@@ -1578,7 +1578,7 @@ static void xl_arb_cmd(struct net_device *dev)
 		
 		if (lan_status_diff & LSC_CO) { 
 				if (xl_priv->xl_message_level) 
-					printk(KERN_INFO "%s: Counter Overflow \n", dev->name);
+					printk(KERN_INFO "%s: Counter Overflow\n", dev->name);
 				/* Issue READ.LOG command */
 				xl_srb_cmd(dev, READ_LOG) ; 	
 		}
@@ -1594,7 +1594,7 @@ static void xl_arb_cmd(struct net_device *dev)
 	}  /* Lan.change.status */
 	else if ( arb_cmd == RECEIVE_DATA) { /* Received.Data */
 #if XL_DEBUG
-		printk(KERN_INFO "Received.Data \n") ; 
+		printk(KERN_INFO "Received.Data\n") ; 
 #endif 		
 		writel( ((MEM_WORD_READ | 0xD0000 | xl_priv->arb) + 6), xl_mmio + MMIO_MAC_ACCESS_CMD) ;
 		xl_priv->mac_buffer = swab16(readw(xl_mmio + MMIO_MACDATA)) ;
@@ -1629,7 +1629,7 @@ static void xl_arb_cmd(struct net_device *dev)
 		xl_asb_cmd(dev) ; 
 		
 	} else {
-		printk(KERN_WARNING "%s: Received unknown arb (xl_priv) command: %02x \n",dev->name,arb_cmd) ; 
+		printk(KERN_WARNING "%s: Received unknown arb (xl_priv) command: %02x\n",dev->name,arb_cmd) ; 
 	}
 
 	/* Acknowledge the arb interrupt */
@@ -1686,13 +1686,13 @@ static void xl_asb_bh(struct net_device *dev)
 	ret_code = readb(xl_mmio + MMIO_MACDATA) ; 
 	switch (ret_code) { 
 		case 0x01:
-			printk(KERN_INFO "%s: ASB Command, unrecognized command code \n",dev->name) ;
+			printk(KERN_INFO "%s: ASB Command, unrecognized command code\n",dev->name) ;
 			break ;
 		case 0x26:
-			printk(KERN_INFO "%s: ASB Command, unexpected receive buffer \n", dev->name) ; 
+			printk(KERN_INFO "%s: ASB Command, unexpected receive buffer\n", dev->name) ; 
 			break ; 
 		case 0x40:
-			printk(KERN_INFO "%s: ASB Command, Invalid Station ID \n", dev->name) ; 
+			printk(KERN_INFO "%s: ASB Command, Invalid Station ID\n", dev->name) ; 
 			break ;  
 	}
 	xl_priv->asb_queued = 0 ; 
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index dd028fe..01c780f 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -357,7 +357,7 @@ static int __devinit streamer_init_one(struct pci_dev *pdev,
 	pcr |= PCI_COMMAND_SERR;
 	pci_write_config_word (pdev, PCI_COMMAND, pcr);
 
-	printk("%s \n", version);
+	printk("%s\n", version);
 	printk("%s: %s. I/O at %hx, MMIO at %p, using irq %d\n",dev->name,
 		streamer_priv->streamer_card_name,
 		(unsigned int) dev->base_addr,
@@ -650,7 +650,7 @@ static int streamer_open(struct net_device *dev)
 #if STREAMER_DEBUG
 		writew(readw(streamer_mmio + LAPWWO),
 		       streamer_mmio + LAPA);
-		printk("srb open request: \n");
+		printk("srb open request:\n");
 		for (i = 0; i < 16; i++) {
 			printk("%x:", ntohs(readw(streamer_mmio + LAPDINC)));
 		}
@@ -700,7 +700,7 @@ static int streamer_open(struct net_device *dev)
 		if (srb_word != 0) {
 			if (srb_word == 0x07) {
 				if (!streamer_priv->streamer_ring_speed && open_finished) {	/* Autosense , first time around */
-					printk(KERN_WARNING "%s: Retrying at different ring speed \n",
+					printk(KERN_WARNING "%s: Retrying at different ring speed\n",
 					       dev->name);
 					open_finished = 0;
 				} else {
@@ -716,7 +716,7 @@ static int streamer_open(struct net_device *dev)
 					    ((error_code & 0x0f) == 0x0d))
 					{
 						printk(KERN_WARNING "%s: Tried to autosense ring speed with no monitors present\n", dev->name);
-						printk(KERN_WARNING "%s: Please try again with a specified ring speed \n", dev->name);
+						printk(KERN_WARNING "%s: Please try again with a specified ring speed\n", dev->name);
 						free_irq(dev->irq, dev);
 						return -EIO;
 					}
@@ -922,7 +922,7 @@ static void streamer_rx(struct net_device *dev)
 
 		if (rx_desc->status & 0x7E830000) {	/* errors */
 			if (streamer_priv->streamer_message_level) {
-				printk(KERN_WARNING "%s: Rx Error %x \n",
+				printk(KERN_WARNING "%s: Rx Error %x\n",
 				       dev->name, rx_desc->status);
 			}
 		} else {	/* received without errors */
@@ -935,7 +935,7 @@ static void streamer_rx(struct net_device *dev)
 
 			if (skb == NULL) 
 			{
-				printk(KERN_WARNING "%s: Not enough memory to copy packet to upper layers. \n",	dev->name);
+				printk(KERN_WARNING "%s: Not enough memory to copy packet to upper layers.\n",	dev->name);
 				dev->stats.rx_dropped++;
 			} else {	/* we allocated an skb OK */
 				if (buffer_cnt == 1) {
@@ -1363,7 +1363,7 @@ static void streamer_srb_bh(struct net_device *dev)
 		case 0x00:
 		        break;
 		case 0x01:
-			printk(KERN_WARNING "%s: Unrecognized srb command \n",dev->name);
+			printk(KERN_WARNING "%s: Unrecognized srb command\n",dev->name);
 			break;
 		case 0x04:
 			printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n", dev->name);
@@ -1391,13 +1391,13 @@ static void streamer_srb_bh(struct net_device *dev)
 		case 0x00:
 		        break;
 		case 0x01:
-			printk(KERN_WARNING "%s: Unrecognized srb command \n", dev->name);
+			printk(KERN_WARNING "%s: Unrecognized srb command\n", dev->name);
 			break;
 		case 0x04:
 			printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n", dev->name);
 			break;
 		case 0x39:	/* Must deal with this if individual multicast addresses used */
-			printk(KERN_INFO "%s: Group address not found \n", dev->name);
+			printk(KERN_INFO "%s: Group address not found\n", dev->name);
 			break;
 		default:
 			break;
@@ -1413,10 +1413,10 @@ static void streamer_srb_bh(struct net_device *dev)
 		switch (srb_word) {
 		case 0x00:
 			if (streamer_priv->streamer_message_level)
-				printk(KERN_INFO "%s: Functional Address Mask Set \n", dev->name);
+				printk(KERN_INFO "%s: Functional Address Mask Set\n", dev->name);
 			break;
 		case 0x01:
-			printk(KERN_WARNING "%s: Unrecognized srb command \n", dev->name);
+			printk(KERN_WARNING "%s: Unrecognized srb command\n", dev->name);
 			break;
 		case 0x04:
 			printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n", dev->name);
@@ -1447,7 +1447,7 @@ static void streamer_srb_bh(struct net_device *dev)
 			}
 			break;
 		case 0x01:
-			printk(KERN_WARNING "%s: Unrecognized srb command \n", dev->name);
+			printk(KERN_WARNING "%s: Unrecognized srb command\n", dev->name);
 			break;
 		case 0x04:
 			printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n", dev->name);
@@ -1466,7 +1466,7 @@ static void streamer_srb_bh(struct net_device *dev)
 				printk(KERN_INFO "%s: Read Source Routing Counters issued\n", dev->name);
 			break;
 		case 0x01:
-			printk(KERN_WARNING "%s: Unrecognized srb command \n", dev->name);
+			printk(KERN_WARNING "%s: Unrecognized srb command\n", dev->name);
 			break;
 		case 0x04:
 			printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n", dev->name);
@@ -1555,7 +1555,7 @@ static void streamer_arb_cmd(struct net_device *dev)
 					     (streamer_mmio + LAPDINC)));
 			}
 
-			printk("next %04x, fs %02x, len %04x \n", next,
+			printk("next %04x, fs %02x, len %04x\n", next,
 			       status, len);
 		}
 #endif
@@ -1592,7 +1592,7 @@ static void streamer_arb_cmd(struct net_device *dev)
 
 		mac_frame->protocol = tr_type_trans(mac_frame, dev);
 #if STREAMER_NETWORK_MONITOR
-		printk(KERN_WARNING "%s: Received MAC Frame, details: \n",
+		printk(KERN_WARNING "%s: Received MAC Frame, details:\n",
 		       dev->name);
 		mac_hdr = tr_hdr(mac_frame);
 		printk(KERN_WARNING
@@ -1668,15 +1668,15 @@ drop_frame:
 		/* If serious error */
 		if (streamer_priv->streamer_message_level) {
 			if (lan_status_diff & LSC_SIG_LOSS)
-				printk(KERN_WARNING "%s: No receive signal detected \n", dev->name);
+				printk(KERN_WARNING "%s: No receive signal detected\n", dev->name);
 			if (lan_status_diff & LSC_HARD_ERR) 
-				printk(KERN_INFO "%s: Beaconing \n", dev->name);
+				printk(KERN_INFO "%s: Beaconing\n", dev->name);
 			if (lan_status_diff & LSC_SOFT_ERR)
-				printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac Frame \n", dev->name);
+				printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac Frame\n", dev->name);
 			if (lan_status_diff & LSC_TRAN_BCN)
 				printk(KERN_INFO "%s: We are tranmitting the beacon, aaah\n", dev->name);
 			if (lan_status_diff & LSC_SS)
-				printk(KERN_INFO "%s: Single Station on the ring \n", dev->name);
+				printk(KERN_INFO "%s: Single Station on the ring\n", dev->name);
 			if (lan_status_diff & LSC_RING_REC)
 				printk(KERN_INFO "%s: Ring recovery ongoing\n", dev->name);
 			if (lan_status_diff & LSC_FDX_MODE)
@@ -1685,7 +1685,7 @@ drop_frame:
 
 		if (lan_status_diff & LSC_CO) {
 			if (streamer_priv->streamer_message_level)
-				printk(KERN_INFO "%s: Counter Overflow \n", dev->name);
+				printk(KERN_INFO "%s: Counter Overflow\n", dev->name);
 
 			/* Issue READ.LOG command */
 
@@ -1715,7 +1715,7 @@ drop_frame:
 		streamer_priv->streamer_lan_status = lan_status;
 	} /* Lan.change.status */
 	else
-		printk(KERN_WARNING "%s: Unknown arb command \n", dev->name);
+		printk(KERN_WARNING "%s: Unknown arb command\n", dev->name);
 }
 
 static void streamer_asb_bh(struct net_device *dev)
@@ -1746,10 +1746,10 @@ static void streamer_asb_bh(struct net_device *dev)
 		rc=ntohs(readw(streamer_mmio+LAPD)) >> 8;
 		switch (rc) {
 		case 0x01:
-			printk(KERN_WARNING "%s: Unrecognized command code \n", dev->name);
+			printk(KERN_WARNING "%s: Unrecognized command code\n", dev->name);
 			break;
 		case 0x26:
-			printk(KERN_WARNING "%s: Unrecognized buffer address \n", dev->name);
+			printk(KERN_WARNING "%s: Unrecognized buffer address\n", dev->name);
 			break;
 		case 0xFF:
 			/* Valid response, everything should be ok again */
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 3a25e04..3c4d23b 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -302,7 +302,7 @@ static int olympic_init(struct net_device *dev)
 	olympic_priv=netdev_priv(dev);
 	olympic_mmio=olympic_priv->olympic_mmio;
 
-	printk("%s \n", version);
+	printk("%s\n", version);
 	printk("%s. I/O at %hx, MMIO at %p, LAP at %p, using irq %d\n", olympic_priv->olympic_card_name, (unsigned int) dev->base_addr,olympic_priv->olympic_mmio, olympic_priv->olympic_lap, dev->irq);
 
 	writel(readl(olympic_mmio+BCTL) | BCTL_SOFTRESET,olympic_mmio+BCTL);
@@ -468,7 +468,7 @@ static int olympic_open(struct net_device *dev)
 #if OLYMPIC_DEBUG
 	printk("LAPWWO: %x, LAPA: %x\n",readw(olympic_mmio+LAPWWO), readl(olympic_mmio+LAPA));
 	printk("SISR Mask = %04x\n", readl(olympic_mmio+SISR_MASK));
-	printk("Before the open command \n");
+	printk("Before the open command\n");
 #endif	
 	do {
 		memset_io(init_srb,0,SRB_COMMAND_SIZE);
@@ -520,7 +520,7 @@ static int olympic_open(struct net_device *dev)
             			break;
         		}
 			if (time_after(jiffies, t + 10*HZ)) {
-				printk(KERN_WARNING "%s: SRB timed out. \n",dev->name) ; 
+				printk(KERN_WARNING "%s: SRB timed out.\n",dev->name) ; 
 				olympic_priv->srb_queued=0;
 				break ; 
 			} 
@@ -549,7 +549,7 @@ static int olympic_open(struct net_device *dev)
 			break;
 		case 0x07:
 			if (!olympic_priv->olympic_ring_speed && open_finished) { /* Autosense , first time around */
-				printk(KERN_WARNING "%s: Retrying at different ring speed \n", dev->name); 
+				printk(KERN_WARNING "%s: Retrying at different ring speed\n", dev->name); 
 				open_finished = 0 ;  
 				continue;
 			}
@@ -558,7 +558,7 @@ static int olympic_open(struct net_device *dev)
 
 			if (!olympic_priv->olympic_ring_speed && ((err & 0x0f) == 0x0d)) { 
 				printk(KERN_WARNING "%s: Tried to autosense ring speed with no monitors present\n",dev->name);
-				printk(KERN_WARNING "%s: Please try again with a specified ring speed \n",dev->name);
+				printk(KERN_WARNING "%s: Please try again with a specified ring speed\n",dev->name);
 			} else {
 				printk(KERN_WARNING "%s: %s - %s\n", dev->name,
 					open_maj_error[(err & 0xf0) >> 4],
@@ -759,7 +759,7 @@ static void olympic_rx(struct net_device *dev)
 		olympic_priv->rx_status_last_received++ ;
 		olympic_priv->rx_status_last_received &= (OLYMPIC_RX_RING_SIZE -1);
 #if OLYMPIC_DEBUG
-		printk("rx status: %x rx len: %x \n", le32_to_cpu(rx_status->status_buffercnt), le32_to_cpu(rx_status->fragmentcnt_framelen));
+		printk("rx status: %x rx len: %x\n", le32_to_cpu(rx_status->status_buffercnt), le32_to_cpu(rx_status->fragmentcnt_framelen));
 #endif
 		length = le32_to_cpu(rx_status->fragmentcnt_framelen) & 0xffff;
 		buffer_cnt = le32_to_cpu(rx_status->status_buffercnt) & 0xffff; 
@@ -774,15 +774,15 @@ static void olympic_rx(struct net_device *dev)
 			if (l_status_buffercnt & 0x3B000000) {
 				if (olympic_priv->olympic_message_level) {
 					if (l_status_buffercnt & (1<<29))  /* Rx Frame Truncated */
-						printk(KERN_WARNING "%s: Rx Frame Truncated \n",dev->name);
+						printk(KERN_WARNING "%s: Rx Frame Truncated\n",dev->name);
 					if (l_status_buffercnt & (1<<28)) /*Rx receive overrun */
-						printk(KERN_WARNING "%s: Rx Frame Receive overrun \n",dev->name);
+						printk(KERN_WARNING "%s: Rx Frame Receive overrun\n",dev->name);
 					if (l_status_buffercnt & (1<<27)) /* No receive buffers */
-						printk(KERN_WARNING "%s: No receive buffers \n",dev->name);
+						printk(KERN_WARNING "%s: No receive buffers\n",dev->name);
 					if (l_status_buffercnt & (1<<25)) /* Receive frame error detect */
-						printk(KERN_WARNING "%s: Receive frame error detect \n",dev->name);
+						printk(KERN_WARNING "%s: Receive frame error detect\n",dev->name);
 					if (l_status_buffercnt & (1<<24)) /* Received Error Detect */
-						printk(KERN_WARNING "%s: Received Error Detect \n",dev->name);
+						printk(KERN_WARNING "%s: Received Error Detect\n",dev->name);
 				} 
 				olympic_priv->rx_ring_last_received += i ; 
 				olympic_priv->rx_ring_last_received &= (OLYMPIC_RX_RING_SIZE -1) ; 
@@ -796,7 +796,7 @@ static void olympic_rx(struct net_device *dev)
 				}
 
 				if (skb == NULL) {
-					printk(KERN_WARNING "%s: Not enough memory to copy packet to upper layers. \n",dev->name) ;
+					printk(KERN_WARNING "%s: Not enough memory to copy packet to upper layers.\n",dev->name) ;
 					dev->stats.rx_dropped++;
 					/* Update counters even though we don't transfer the frame */
 					olympic_priv->rx_ring_last_received += i ; 
@@ -1101,7 +1101,7 @@ static int olympic_close(struct net_device *dev)
         	}
 
 		if (t == 0) { 
-			printk(KERN_WARNING "%s: SRB timed out. May not be fatal. \n",dev->name) ; 
+			printk(KERN_WARNING "%s: SRB timed out. May not be fatal.\n",dev->name) ; 
 		} 
 		olympic_priv->srb_queued=0;
     	}
@@ -1239,7 +1239,7 @@ static void olympic_srb_bh(struct net_device *dev)
 				case 0x00:
 					break ; 
 				case 0x01:
-					printk(KERN_WARNING "%s: Unrecognized srb command \n",dev->name) ; 
+					printk(KERN_WARNING "%s: Unrecognized srb command\n",dev->name) ; 
 					break ;
 				case 0x04:
 					printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n",dev->name); 
@@ -1266,13 +1266,13 @@ static void olympic_srb_bh(struct net_device *dev)
 				case 0x00:
 					break ; 
 				case 0x01:
-					printk(KERN_WARNING "%s: Unrecognized srb command \n",dev->name) ; 
+					printk(KERN_WARNING "%s: Unrecognized srb command\n",dev->name) ; 
 					break ; 
 				case 0x04:
 					printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n",dev->name) ; 
 					break ; 
 				case 0x39: /* Must deal with this if individual multicast addresses used */
-					printk(KERN_INFO "%s: Group address not found \n",dev->name); 
+					printk(KERN_INFO "%s: Group address not found\n",dev->name); 
 					break ;
 				default:
 					break ; 
@@ -1287,10 +1287,10 @@ static void olympic_srb_bh(struct net_device *dev)
 			switch (readb(srb+2)) { 
 				case 0x00:
 					if (olympic_priv->olympic_message_level)
-						printk(KERN_INFO "%s: Functional Address Mask Set \n",dev->name) ; 
+						printk(KERN_INFO "%s: Functional Address Mask Set\n",dev->name) ; 
 					break ;
 				case 0x01:
-					printk(KERN_WARNING "%s: Unrecognized srb command \n",dev->name) ; 
+					printk(KERN_WARNING "%s: Unrecognized srb command\n",dev->name) ; 
 					break ; 
 				case 0x04:
 					printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n",dev->name) ; 
@@ -1310,7 +1310,7 @@ static void olympic_srb_bh(struct net_device *dev)
 						printk(KERN_INFO "%s: Read Log issued\n",dev->name) ; 
 					break ; 
 				case 0x01:
-					printk(KERN_WARNING "%s: Unrecognized srb command \n",dev->name) ; 
+					printk(KERN_WARNING "%s: Unrecognized srb command\n",dev->name) ; 
 					break ; 
 				case 0x04:
 					printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n",dev->name) ; 
@@ -1328,7 +1328,7 @@ static void olympic_srb_bh(struct net_device *dev)
 						printk(KERN_INFO "%s: Read Source Routing Counters issued\n",dev->name) ; 
 					break ; 
 				case 0x01:
-					printk(KERN_WARNING "%s: Unrecognized srb command \n",dev->name) ; 
+					printk(KERN_WARNING "%s: Unrecognized srb command\n",dev->name) ; 
 					break ; 
 				case 0x04:
 					printk(KERN_WARNING "%s: Adapter must be open for this operation, doh!!\n",dev->name) ; 
@@ -1404,7 +1404,7 @@ static void olympic_arb_cmd(struct net_device *dev)
 			printk("Loc %d = %02x\n",i,readb(frame_data + i)); 
 		}
 
-		printk("next %04x, fs %02x, len %04x \n",readw(buf_ptr+offsetof(struct mac_receive_buffer,next)), readb(buf_ptr+offsetof(struct mac_receive_buffer,frame_status)), readw(buf_ptr+offsetof(struct mac_receive_buffer,buffer_length))); 
+		printk("next %04x, fs %02x, len %04x\n",readw(buf_ptr+offsetof(struct mac_receive_buffer,next)), readb(buf_ptr+offsetof(struct mac_receive_buffer,frame_status)), readw(buf_ptr+offsetof(struct mac_receive_buffer,buffer_length))); 
 }
 #endif 
 		mac_frame = dev_alloc_skb(frame_len) ; 
@@ -1426,7 +1426,7 @@ static void olympic_arb_cmd(struct net_device *dev)
 
 		if (olympic_priv->olympic_network_monitor) { 
 			struct trh_hdr *mac_hdr;
-			printk(KERN_WARNING "%s: Received MAC Frame, details: \n",dev->name);
+			printk(KERN_WARNING "%s: Received MAC Frame, details:\n",dev->name);
 			mac_hdr = tr_hdr(mac_frame);
 			printk(KERN_WARNING "%s: MAC Frame Dest. Addr: %pM\n",
 			       dev->name, mac_hdr->daddr);
@@ -1489,20 +1489,20 @@ drop_frame:
 			writel(readl(olympic_mmio+BCTL)&~(3<<13),olympic_mmio+BCTL);
 			netif_stop_queue(dev);
 			olympic_priv->srb = readw(olympic_priv->olympic_lap + LAPWWO) ; 
-			printk(KERN_WARNING "%s: Adapter has been closed \n", dev->name) ; 
+			printk(KERN_WARNING "%s: Adapter has been closed\n", dev->name) ; 
 		} /* If serious error */
 		
 		if (olympic_priv->olympic_message_level) { 
 			if (lan_status_diff & LSC_SIG_LOSS) 
-					printk(KERN_WARNING "%s: No receive signal detected \n", dev->name) ; 
+					printk(KERN_WARNING "%s: No receive signal detected\n", dev->name) ; 
 			if (lan_status_diff & LSC_HARD_ERR)
-					printk(KERN_INFO "%s: Beaconing \n",dev->name);
+					printk(KERN_INFO "%s: Beaconing\n",dev->name);
 			if (lan_status_diff & LSC_SOFT_ERR)
-					printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac Frame \n",dev->name);
+					printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac Frame\n",dev->name);
 			if (lan_status_diff & LSC_TRAN_BCN) 
 					printk(KERN_INFO "%s: We are tranmitting the beacon, aaah\n",dev->name);
 			if (lan_status_diff & LSC_SS) 
-					printk(KERN_INFO "%s: Single Station on the ring \n", dev->name);
+					printk(KERN_INFO "%s: Single Station on the ring\n", dev->name);
 			if (lan_status_diff & LSC_RING_REC)
 					printk(KERN_INFO "%s: Ring recovery ongoing\n",dev->name);
 			if (lan_status_diff & LSC_FDX_MODE)
@@ -1512,7 +1512,7 @@ drop_frame:
 		if (lan_status_diff & LSC_CO) { 
 					
 				if (olympic_priv->olympic_message_level) 
-					printk(KERN_INFO "%s: Counter Overflow \n", dev->name);
+					printk(KERN_INFO "%s: Counter Overflow\n", dev->name);
 					
 				/* Issue READ.LOG command */
 
@@ -1551,7 +1551,7 @@ drop_frame:
 	
 	}  /* Lan.change.status */
 	else
-		printk(KERN_WARNING "%s: Unknown arb command \n", dev->name);
+		printk(KERN_WARNING "%s: Unknown arb command\n", dev->name);
 }
 
 static void olympic_asb_bh(struct net_device *dev) 
@@ -1578,10 +1578,10 @@ static void olympic_asb_bh(struct net_device *dev)
 	if (olympic_priv->asb_queued == 2) { 
 		switch (readb(asb_block+2)) {
 			case 0x01:
-				printk(KERN_WARNING "%s: Unrecognized command code \n", dev->name);
+				printk(KERN_WARNING "%s: Unrecognized command code\n", dev->name);
 				break ;
 			case 0x26:
-				printk(KERN_WARNING "%s: Unrecognized buffer address \n", dev->name);
+				printk(KERN_WARNING "%s: Unrecognized buffer address\n", dev->name);
 				break ;
 			case 0xFF:
 				/* Valid response, everything should be ok again */
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index ee71bcf..b545e20 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1391,7 +1391,7 @@ static int tms380tr_bringup_diags(struct net_device *dev)
 			Status &= STS_MASK;
 
 			if(tms380tr_debug > 3)
-				printk(KERN_DEBUG " %04X \n", Status);
+				printk(KERN_DEBUG " %04X\n", Status);
 			/* BUD successfully completed */
 			if(Status == STS_INITIALIZE)
 				return (1);
@@ -1847,7 +1847,7 @@ static void tms380tr_chk_irq(struct net_device *dev)
 			break;
 
 		case DMA_WRITE_ABORT:
-			printk(KERN_INFO "%s: DMA write operation aborted: \n",
+			printk(KERN_INFO "%s: DMA write operation aborted:\n",
 				dev->name);
 			switch (AdapterCheckBlock[1])
 			{
-- 
1.6.6.1

