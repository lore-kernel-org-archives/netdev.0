From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 03/39] mv643xx_eth: shorten reg names
Date: Tue,  3 Jun 2008 13:02:18 +0200
Message-ID: <1212490974-23719-4-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48764 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756112AbYFCMAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:42 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shorten the various oversized register names in mv643xx_eth.c, to
increase readability.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  204 +++++++++++++++++++++------------------------
 1 files changed, 96 insertions(+), 108 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c04058c..9a9218f 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -76,38 +76,38 @@ static char mv643xx_driver_version[] = "1.0";
 /*
  * Registers shared between all ports.
  */
-#define PHY_ADDR_REG				0x0000
-#define SMI_REG					0x0004
-#define WINDOW_BASE(i)				(0x0200 + ((i) << 3))
-#define WINDOW_SIZE(i)				(0x0204 + ((i) << 3))
-#define WINDOW_REMAP_HIGH(i)			(0x0280 + ((i) << 2))
-#define WINDOW_BAR_ENABLE			0x0290
-#define WINDOW_PROTECT(i)			(0x0294 + ((i) << 4))
+#define PHY_ADDR			0x0000
+#define SMI_REG				0x0004
+#define WINDOW_BASE(w)			(0x0200 + ((w) << 3))
+#define WINDOW_SIZE(w)			(0x0204 + ((w) << 3))
+#define WINDOW_REMAP_HIGH(w)		(0x0280 + ((w) << 2))
+#define WINDOW_BAR_ENABLE		0x0290
+#define WINDOW_PROTECT(w)		(0x0294 + ((w) << 4))
 
 /*
  * Per-port registers.
  */
-#define PORT_CONFIG_REG(p)				(0x0400 + ((p) << 10))
-#define PORT_CONFIG_EXTEND_REG(p)			(0x0404 + ((p) << 10))
-#define MAC_ADDR_LOW(p)					(0x0414 + ((p) << 10))
-#define MAC_ADDR_HIGH(p)				(0x0418 + ((p) << 10))
-#define SDMA_CONFIG_REG(p)				(0x041c + ((p) << 10))
-#define PORT_SERIAL_CONTROL_REG(p)			(0x043c + ((p) << 10))
-#define PORT_STATUS_REG(p)				(0x0444 + ((p) << 10))
-#define TRANSMIT_QUEUE_COMMAND_REG(p)			(0x0448 + ((p) << 10))
-#define MAXIMUM_TRANSMIT_UNIT(p)			(0x0458 + ((p) << 10))
-#define INTERRUPT_CAUSE_REG(p)				(0x0460 + ((p) << 10))
-#define INTERRUPT_CAUSE_EXTEND_REG(p)			(0x0464 + ((p) << 10))
-#define INTERRUPT_MASK_REG(p)				(0x0468 + ((p) << 10))
-#define INTERRUPT_EXTEND_MASK_REG(p)			(0x046c + ((p) << 10))
-#define TX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0474 + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x060c + ((p) << 10))
-#define RECEIVE_QUEUE_COMMAND_REG(p)			(0x0680 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x06c0 + ((p) << 10))
-#define MIB_COUNTERS_BASE(p)				(0x1000 + ((p) << 7))
-#define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(p)	(0x1400 + ((p) << 10))
-#define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(p)		(0x1500 + ((p) << 10))
-#define DA_FILTER_UNICAST_TABLE_BASE(p)			(0x1600 + ((p) << 10))
+#define PORT_CONFIG(p)			(0x0400 + ((p) << 10))
+#define PORT_CONFIG_EXT(p)		(0x0404 + ((p) << 10))
+#define MAC_ADDR_LOW(p)			(0x0414 + ((p) << 10))
+#define MAC_ADDR_HIGH(p)		(0x0418 + ((p) << 10))
+#define SDMA_CONFIG(p)			(0x041c + ((p) << 10))
+#define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
+#define PORT_STATUS(p)			(0x0444 + ((p) << 10))
+#define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
+#define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
+#define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
+#define INT_MASK(p)			(0x0468 + ((p) << 10))
+#define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
+#define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
+#define RXQ_CURRENT_DESC_PTR(p)		(0x060c + ((p) << 10))
+#define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
+#define TXQ_CURRENT_DESC_PTR(p)		(0x06c0 + ((p) << 10))
+#define MIB_COUNTERS(p)			(0x1000 + ((p) << 7))
+#define SPECIAL_MCAST_TABLE(p)		(0x1400 + ((p) << 10))
+#define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
+#define UNICAST_TABLE(p)		(0x1600 + ((p) << 10))
 
 /* These macros describe Ethernet Port configuration reg (Px_cR) bits */
 #define UNICAST_NORMAL_MODE		(0 << 0)
@@ -592,7 +592,7 @@ static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
 static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
 					unsigned int queues)
 {
-	wrl(mp, RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
+	wrl(mp, RXQ_COMMAND(mp->port_num), queues);
 }
 
 static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
@@ -601,14 +601,14 @@ static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
 	u32 queues;
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	queues = rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
+	queues = rdl(mp, RXQ_COMMAND(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		wrl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
+		wrl(mp, RXQ_COMMAND(port_num), (queues << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
+		while (rdl(mp, RXQ_COMMAND(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
@@ -618,7 +618,7 @@ static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
 static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
 					unsigned int queues)
 {
-	wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
+	wrl(mp, TXQ_COMMAND(mp->port_num), queues);
 }
 
 static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
@@ -627,19 +627,18 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
 	u32 queues;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	queues = rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
+	queues = rdl(mp, TXQ_COMMAND(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
+		wrl(mp, TXQ_COMMAND(port_num), (queues << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
+		while (rdl(mp, TXQ_COMMAND(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 
 		/* Wait for Tx FIFO to empty */
-		while (rdl(mp, PORT_STATUS_REG(port_num)) &
-							ETH_PORT_TX_FIFO_EMPTY)
+		while (rdl(mp, PORT_STATUS(port_num)) & ETH_PORT_TX_FIFO_EMPTY)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
@@ -946,15 +945,15 @@ static int mv643xx_poll(struct napi_struct *napi, int budget)
 #endif
 
 	work_done = 0;
-	if ((rdl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+	if ((rdl(mp, RXQ_CURRENT_DESC_PTR(port_num)))
 	    != (u32) mp->rx_used_desc_q)
 		work_done = mv643xx_eth_receive_queue(dev, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
-		wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
-		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+		wrl(mp, INT_CAUSE(port_num), 0);
+		wrl(mp, INT_CAUSE_EXT(port_num), 0);
+		wrl(mp, INT_MASK(port_num), ETH_INT_UNMASK_ALL);
 	}
 
 	return work_done;
@@ -1290,12 +1289,12 @@ static void eth_clear_mib_counters(struct mv643xx_private *mp)
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
 									i += 4)
-		rdl(mp, MIB_COUNTERS_BASE(port_num) + i);
+		rdl(mp, MIB_COUNTERS(port_num) + i);
 }
 
 static inline u32 read_mib(struct mv643xx_private *mp, int offset)
 {
-	return rdl(mp, MIB_COUNTERS_BASE(mp->port_num) + offset);
+	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
 }
 
 static void eth_update_mib_counters(struct mv643xx_private *mp)
@@ -1528,16 +1527,13 @@ static void eth_port_init_mac_tables(struct mv643xx_private *mp)
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		wrl(mp, DA_FILTER_UNICAST_TABLE_BASE(port_num) +
-					table_index, 0);
+		wrl(mp, UNICAST_TABLE(port_num) + table_index, 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
-					table_index, 0);
+		wrl(mp, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
-					table_index, 0);
+		wrl(mp, OTHER_MCAST_TABLE(port_num) + table_index, 0);
 	}
 }
 
@@ -1585,7 +1581,7 @@ static void eth_port_uc_addr_set(struct mv643xx_private *mp,
 	wrl(mp, MAC_ADDR_HIGH(port_num), mac_h);
 
 	/* Accept frames with this address */
-	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
+	table = UNICAST_TABLE(port_num);
 	eth_port_set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
 }
 
@@ -1654,7 +1650,7 @@ static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 
 	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
 	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
-		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num);
+		table = SPECIAL_MCAST_TABLE(port_num);
 		eth_port_set_filter_table_entry(mp, table, p_addr[5]);
 		return;
 	}
@@ -1727,7 +1723,7 @@ static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 	for (i = 0; i < 8; i++)
 		crc_result = crc_result | (crc[i] << i);
 
-	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num);
+	table = OTHER_MCAST_TABLE(port_num);
 	eth_port_set_filter_table_entry(mp, table, crc_result);
 }
 
@@ -1757,7 +1753,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			wrl(mp, SPECIAL_MCAST_TABLE(eth_port_num) + table_index, 0x01010101);
 
 			/* Set all entries in DA filter other multicast
 			 * table (Ex_dFOMT)
@@ -1767,7 +1763,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			wrl(mp, OTHER_MCAST_TABLE(eth_port_num) + table_index, 0x01010101);
 		}
 		return;
 	}
@@ -1777,12 +1773,10 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 	 */
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-				(eth_port_num) + table_index, 0);
+		wrl(mp, SPECIAL_MCAST_TABLE(eth_port_num) + table_index, 0);
 
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE
-				(eth_port_num) + table_index, 0);
+		wrl(mp, OTHER_MCAST_TABLE(eth_port_num) + table_index, 0);
 	}
 
 	/* Get pointer to net_device multicast list and add each one... */
@@ -1806,12 +1800,12 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 config_reg;
 
-	config_reg = rdl(mp, PORT_CONFIG_REG(mp->port_num));
+	config_reg = rdl(mp, PORT_CONFIG(mp->port_num));
 	if (dev->flags & IFF_PROMISC)
 		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
 	else
 		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
-	wrl(mp, PORT_CONFIG_REG(mp->port_num), config_reg);
+	wrl(mp, PORT_CONFIG(mp->port_num), config_reg);
 
 	eth_port_set_multicast_list(dev);
 }
@@ -2042,7 +2036,7 @@ static void mv643xx_eth_update_pscr(struct net_device *dev,
 	u32 o_pscr, n_pscr;
 	unsigned int queues;
 
-	o_pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
+	o_pscr = rdl(mp, PORT_SERIAL_CONTROL(port_num));
 	n_pscr = o_pscr;
 
 	/* clear speed, duplex and rx buffer size fields */
@@ -2065,14 +2059,14 @@ static void mv643xx_eth_update_pscr(struct net_device *dev,
 
 	if (n_pscr != o_pscr) {
 		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL(port_num), n_pscr);
 		else {
 			queues = mv643xx_eth_port_disable_tx(mp);
 
 			o_pscr &= ~SERIAL_PORT_ENABLE;
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL(port_num), o_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL(port_num), n_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL(port_num), n_pscr);
 			if (queues)
 				mv643xx_eth_port_enable_tx(mp, queues);
 		}
@@ -2098,14 +2092,11 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = rdl(mp, INTERRUPT_CAUSE_REG(port_num)) &
-						ETH_INT_UNMASK_ALL;
+	eth_int_cause = rdl(mp, INT_CAUSE(port_num)) & ETH_INT_UNMASK_ALL;
 	if (eth_int_cause & ETH_INT_CAUSE_EXT) {
-		eth_int_cause_ext = rdl(mp,
-			INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
-						ETH_INT_UNMASK_ALL_EXT;
-		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num),
-							~eth_int_cause_ext);
+		eth_int_cause_ext = rdl(mp, INT_CAUSE_EXT(port_num))
+						& ETH_INT_UNMASK_ALL_EXT;
+		wrl(mp, INT_CAUSE_EXT(port_num), ~eth_int_cause_ext);
 	}
 
 	/* PHY status changed */
@@ -2131,10 +2122,10 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 #ifdef MV643XX_NAPI
 	if (eth_int_cause & ETH_INT_CAUSE_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+		wrl(mp, INT_MASK(port_num), ETH_INT_MASK_ALL);
 
 		/* wait for previous write to complete */
-		rdl(mp, INTERRUPT_MASK_REG(port_num));
+		rdl(mp, INT_MASK(port_num));
 
 		netif_rx_schedule(dev, &mp->napi);
 	}
@@ -2224,28 +2215,26 @@ static void eth_port_start(struct net_device *dev)
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
-	wrl(mp, TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	wrl(mp, TXQ_CURRENT_DESC_PTR(port_num),
 		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
-	wrl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	wrl(mp, RXQ_CURRENT_DESC_PTR(port_num),
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
 	eth_port_uc_addr_set(mp, dev->dev_addr);
 
 	/* Assign port configuration and command. */
-	wrl(mp, PORT_CONFIG_REG(port_num),
-			  PORT_CONFIG_DEFAULT_VALUE);
+	wrl(mp, PORT_CONFIG(port_num), PORT_CONFIG_DEFAULT_VALUE);
 
-	wrl(mp, PORT_CONFIG_EXTEND_REG(port_num),
-			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+	wrl(mp, PORT_CONFIG_EXT(port_num), PORT_CONFIG_EXTEND_DEFAULT_VALUE);
 
-	pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
+	pscr = rdl(mp, PORT_SERIAL_CONTROL(port_num));
 
 	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, PORT_SERIAL_CONTROL(port_num), pscr);
 
 	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 		DISABLE_AUTO_NEG_SPEED_GMII    |
@@ -2253,20 +2242,19 @@ static void eth_port_start(struct net_device *dev)
 		DO_NOT_FORCE_LINK_FAIL	   |
 		SERIAL_PORT_CONTROL_RESERVED;
 
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, PORT_SERIAL_CONTROL(port_num), pscr);
 
 	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, PORT_SERIAL_CONTROL(port_num), pscr);
 
 	/* Assign port SDMA configuration */
-	wrl(mp, SDMA_CONFIG_REG(port_num),
-			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
+	wrl(mp, SDMA_CONFIG(port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
 	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
 
 	/* Disable port bandwidth limits by clearing MTU register */
-	wrl(mp, MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+	wrl(mp, TX_BW_MTU(port_num), 0);
 
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
@@ -2305,9 +2293,9 @@ static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
 	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	wrl(mp, SDMA_CONFIG_REG(port_num),
+	wrl(mp, SDMA_CONFIG(port_num),
 		((coal & 0x3fff) << 8) |
-		(rdl(mp, SDMA_CONFIG_REG(port_num))
+		(rdl(mp, SDMA_CONFIG(port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -2342,7 +2330,7 @@ static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
 	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set TX Coalescing mechanism */
-	wrl(mp, TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
+	wrl(mp, TX_FIFO_URGENT_THRESHOLD(mp->port_num), coal << 4);
 
 	return coal;
 }
@@ -2401,10 +2389,10 @@ static int mv643xx_eth_open(struct net_device *dev)
 	int err;
 
 	/* Clear any pending ethernet port interrupts */
-	wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
-	wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	wrl(mp, INT_CAUSE(port_num), 0);
+	wrl(mp, INT_CAUSE_EXT(port_num), 0);
 	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num));
+	rdl(mp, INT_CAUSE_EXT(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
@@ -2510,10 +2498,10 @@ static int mv643xx_eth_open(struct net_device *dev)
 		eth_port_set_tx_coal(mp, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
-	wrl(mp, INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
+	wrl(mp, INT_MASK_EXT(port_num), ETH_INT_UNMASK_ALL_EXT);
 
 	/* Unmask RX buffer and TX end interrupt */
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	wrl(mp, INT_MASK(port_num), ETH_INT_UNMASK_ALL);
 
 	return 0;
 
@@ -2557,11 +2545,11 @@ static void eth_port_reset(struct mv643xx_private *mp)
 	eth_clear_mib_counters(mp);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data = rdl(mp, PORT_SERIAL_CONTROL(port_num));
 	reg_data &= ~(SERIAL_PORT_ENABLE		|
 			DO_NOT_FORCE_LINK_FAIL	|
 			FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+	wrl(mp, PORT_SERIAL_CONTROL(port_num), reg_data);
 }
 
 /*
@@ -2580,9 +2568,9 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	wrl(mp, INT_MASK(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+	rdl(mp, INT_MASK(port_num));
 
 #ifdef MV643XX_NAPI
 	napi_disable(&mp->napi);
@@ -2685,13 +2673,13 @@ static void mv643xx_netpoll(struct net_device *netdev)
 	struct mv643xx_private *mp = netdev_priv(netdev);
 	int port_num = mp->port_num;
 
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	wrl(mp, INT_MASK(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+	rdl(mp, INT_MASK(port_num));
 
 	mv643xx_eth_int_handler(netdev->irq, netdev);
 
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	wrl(mp, INT_MASK(port_num), ETH_INT_UNMASK_ALL);
 }
 #endif
 
@@ -2835,10 +2823,10 @@ static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
 	u32 reg_data;
 	int addr_shift = 5 * mp->port_num;
 
-	reg_data = rdl(mp, PHY_ADDR_REG);
+	reg_data = rdl(mp, PHY_ADDR);
 	reg_data &= ~(0x1f << addr_shift);
 	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	wrl(mp, PHY_ADDR_REG, reg_data);
+	wrl(mp, PHY_ADDR, reg_data);
 }
 
 /*
@@ -2861,7 +2849,7 @@ static int ethernet_phy_get(struct mv643xx_private *mp)
 {
 	unsigned int reg_data;
 
-	reg_data = rdl(mp, PHY_ADDR_REG);
+	reg_data = rdl(mp, PHY_ADDR);
 
 	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
@@ -3139,8 +3127,8 @@ static void mv643xx_eth_shutdown(struct platform_device *pdev)
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mp, INTERRUPT_MASK_REG(port_num), 0);
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+	wrl(mp, INT_MASK(port_num), 0);
+	rdl(mp, INT_MASK(port_num));
 
 	eth_port_reset(mp);
 }
-- 
1.5.3.4

