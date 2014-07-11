From: varkabhadram@gmail.com
Subject: [PATCH net-next 4/8] ethernet: amd: fix comment styles
Date: Fri, 11 Jul 2014 13:05:06 +0530
Message-ID: <1405064110-22579-5-git-send-email-varkabhadram@gmail.com>
References: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch fixes the comment style issues

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |  181 +++++++++++++++++------------------
 1 file changed, 86 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 2d3a55e..e2fb9e2 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -116,9 +116,8 @@ static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
 	{ 0, }
 
 };
-/*
-This function will read the PHY registers.
-*/
+
+/* This function will read the PHY registers. */
 static int amd8111e_read_phy(struct amd8111e_priv* lp, int phy_id, int reg, u32* val)
 {
 	void __iomem *mmio = lp->mmio;
@@ -146,9 +145,7 @@ err_phy_read:
 
 }
 
-/*
-This function will write into PHY registers.
-*/
+/* This function will write into PHY registers. */
 static int amd8111e_write_phy(struct amd8111e_priv* lp,int phy_id, int reg, u32 val)
 {
 	unsigned int repeat = REPEAT_CNT;
@@ -176,9 +173,8 @@ err_phy_write:
 	return -EINVAL;
 
 }
-/*
-This is the mii register read function provided to the mii interface.
-*/
+
+/* This is the mii register read function provided to the mii interface. */
 static int amd8111e_mdio_read(struct net_device * dev, int phy_id, int reg_num)
 {
 	struct amd8111e_priv* lp = netdev_priv(dev);
@@ -189,9 +185,7 @@ static int amd8111e_mdio_read(struct net_device * dev, int phy_id, int reg_num)
 
 }
 
-/*
-This is the mii register write function provided to the mii interface.
-*/
+/* This is the mii register write function provided to the mii interface. */
 static void amd8111e_mdio_write(struct net_device * dev, int phy_id, int reg_num, int val)
 {
 	struct amd8111e_priv* lp = netdev_priv(dev);
@@ -199,9 +193,9 @@ static void amd8111e_mdio_write(struct net_device * dev, int phy_id, int reg_num
 	amd8111e_write_phy(lp, phy_id, reg_num, val);
 }
 
-/*
-This function will set PHY speed. During initialization sets the original speed to 100 full.
-*/
+/* This function will set PHY speed. During initialization sets
+ * the original speed to 100 full
+ */
 static void amd8111e_set_ext_phy(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -240,10 +234,9 @@ static void amd8111e_set_ext_phy(struct net_device *dev)
 
 }
 
-/*
-This function will unmap skb->data space and will free
-all transmit and receive skbuffs.
-*/
+/* This function will unmap skb->data space and will free
+ * all transmit and receive skbuffs.
+ */
 static int amd8111e_free_skbs(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -274,9 +267,9 @@ static int amd8111e_free_skbs(struct net_device *dev)
 	return 0;
 }
 
-/*
-This will set the receive buffer length corresponding to the mtu size of networkinterface.
-*/
+/* This will set the receive buffer length corresponding
+ * to the mtu size of networkinterface.
+ */
 static inline void amd8111e_set_rx_buff_len(struct net_device* dev)
 {
 	struct amd8111e_priv* lp = netdev_priv(dev);
@@ -284,8 +277,8 @@ static inline void amd8111e_set_rx_buff_len(struct net_device* dev)
 
 	if (mtu > ETH_DATA_LEN){
 		/* MTU + ethernet header + FCS
-		+ optional VLAN tag + skb reserve space 2 */
-
+		 * + optional VLAN tag + skb reserve space 2
+		 */
 		lp->rx_buff_len = mtu + ETH_HLEN + 10;
 		lp->options |= OPTION_JUMBO_ENABLE;
 	} else{
@@ -294,8 +287,10 @@ static inline void amd8111e_set_rx_buff_len(struct net_device* dev)
 	}
 }
 
-/*
-This function will free all the previously allocated buffers, determine new receive buffer length  and will allocate new receive buffers. This function also allocates and initializes both the transmitter and receive hardware descriptors.
+/* This function will free all the previously allocated buffers,
+ * determine new receive buffer length  and will allocate new receive buffers.
+ * This function also allocates and initializes both the transmitter
+ * and receive hardware descriptors.
  */
 static int amd8111e_init_ring(struct net_device *dev)
 {
@@ -376,7 +371,10 @@ err_free_tx_ring:
 err_no_mem:
 	return -ENOMEM;
 }
-/* This function will set the interrupt coalescing according to the input arguments */
+
+/* This function will set the interrupt coalescing according
+ * to the input arguments
+ */
 static int amd8111e_set_coalesce(struct net_device * dev, enum coal_mode cmod)
 {
 	unsigned int timeout;
@@ -435,9 +433,7 @@ static int amd8111e_set_coalesce(struct net_device * dev, enum coal_mode cmod)
 
 }
 
-/*
-This function initializes the device registers  and starts the device.
-*/
+/* This function initializes the device registers  and starts the device. */
 static int amd8111e_restart(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -513,9 +509,8 @@ static int amd8111e_restart(struct net_device *dev)
 	readl(mmio+CMD0);
 	return 0;
 }
-/*
-This function clears necessary the device registers.
-*/
+
+/* This function clears necessary the device registers. */
 static void amd8111e_init_hw_default( struct amd8111e_priv* lp)
 {
 	unsigned int reg_val;
@@ -604,9 +599,8 @@ static void amd8111e_init_hw_default( struct amd8111e_priv* lp)
 
 }
 
-/*
-This function disables the interrupt and clears all the pending
-interrupts in INT0
+/* This function disables the interrupt and clears all the pending
+ * interrupts in INT0
  */
 static void amd8111e_disable_interrupt(struct amd8111e_priv* lp)
 {
@@ -624,9 +618,7 @@ static void amd8111e_disable_interrupt(struct amd8111e_priv* lp)
 
 }
 
-/*
-This function stops the chip.
-*/
+/* This function stops the chip. */
 static void amd8111e_stop_chip(struct amd8111e_priv* lp)
 {
 	writel(RUN, lp->mmio + CMD0);
@@ -635,9 +627,7 @@ static void amd8111e_stop_chip(struct amd8111e_priv* lp)
 	readl(lp->mmio + CMD0);
 }
 
-/*
-This function frees the  transmiter and receiver descriptor rings.
-*/
+/* This function frees the  transmiter and receiver descriptor rings. */
 static void amd8111e_free_ring(struct amd8111e_priv* lp)
 {
 	/* Free transmit and receive descriptor rings */
@@ -658,9 +648,10 @@ static void amd8111e_free_ring(struct amd8111e_priv* lp)
 
 }
 
-/*
-This function will free all the transmit skbs that are actually transmitted by the device. It will check the ownership of the skb before freeing the skb.
-*/
+/* This function will free all the transmit skbs that are actually
+ * transmitted by the device. It will check the ownership of the
+ * skb before freeing the skb.
+ */
 static int amd8111e_tx(struct net_device *dev)
 {
 	struct amd8111e_priv* lp = netdev_priv(dev);
@@ -723,21 +714,20 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 		goto rx_not_empty;
 
 	do{
-		/* process receive packets until we use the quota*/
-		/* If we own the next entry, it's a new packet. Send it up. */
+		/* process receive packets until we use the quota.
+		 * If we own the next entry, it's a new packet. Send it up.
+		 */
 		while(1) {
 			status = le16_to_cpu(lp->rx_ring[rx_index].rx_flags);
 			if (status & OWN_BIT)
 				break;
 
-			/*
-			 * There is a tricky error noted by John Murphy,
+			/* There is a tricky error noted by John Murphy,
 			 * <murf@perftech.com> to Russ Nelson: Even with
 			 * full-sized * buffers it's possible for a
 			 * jabber packet to use two buffers, with only
 			 * the last correctly noting the error.
 			 */
-
 			if(status & ERR_BIT) {
 				/* reseting flags */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
@@ -770,7 +760,8 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
 			if (!new_skb) {
 				/* if allocation fail,
-				   ignore that pkt and go to next one */
+				 * ignore that pkt and go to next one
+				 */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
 				lp->drv_rx_errors++;
 				goto err_next_pkt;
@@ -811,8 +802,8 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			rx_index = (++lp->rx_idx) & RX_RING_DR_MOD_MASK;
 		}
 		/* Check the interrupt status register for more packets in the
-		   mean time. Process them since we have not used up our quota.*/
-
+		 * mean time. Process them since we have not used up our quota.
+		 */
 		intr0 = readl(mmio + INT0);
 		/*Ack receive packets */
 		writel(intr0 & RINT0,mmio + INT0);
@@ -832,9 +823,7 @@ rx_not_empty:
 	return num_rx_pkt;
 }
 
-/*
-This function will indicate the link status to the kernel.
-*/
+/* This function will indicate the link status to the kernel. */
 static int amd8111e_link_change(struct net_device* dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -877,9 +866,8 @@ static int amd8111e_link_change(struct net_device* dev)
 
 	return 0;
 }
-/*
-This function reads the mib counters.
-*/
+
+/* This function reads the mib counters. */
 static int amd8111e_read_mib(void __iomem *mmio, u8 MIB_COUNTER)
 {
 	unsigned int  status;
@@ -897,8 +885,7 @@ static int amd8111e_read_mib(void __iomem *mmio, u8 MIB_COUNTER)
 	return data;
 }
 
-/*
- * This function reads the mib registers and returns the hardware statistics.
+/* This function reads the mib registers and returns the hardware statistics.
  * It updates previous internal driver statistics with new values.
  */
 static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
@@ -994,9 +981,10 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 
 	return new_stats;
 }
+
 /* This function recalculate the interrupt coalescing  mode on every interrupt
-according to the datarate and the packet rate.
-*/
+ * according to the datarate and the packet rate.
+ */
 static int amd8111e_calc_coalesce(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -1128,9 +1116,10 @@ static int amd8111e_calc_coalesce(struct net_device *dev)
 	return 0;
 
 }
-/*
-This is device interrupt function. It handles transmit, receive,link change and hardware timer interrupts.
-*/
+
+/* This is device interrupt function. It handles transmit,
+ * receive,link change and hardware timer interrupts.
+ */
 static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 {
 
@@ -1207,9 +1196,10 @@ static void amd8111e_poll(struct net_device *dev)
 #endif
 
 
-/*
-This function closes the network interface and updates the statistics so that most recent statistics will be available after the interface is down.
-*/
+/* This function closes the network interface and updates
+ * the statistics so that most recent statistics will be
+ * available after the interface is down.
+ */
 static int amd8111e_close(struct net_device * dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -1240,8 +1230,10 @@ static int amd8111e_close(struct net_device * dev)
 	lp->opened = 0;
 	return 0;
 }
-/* This function opens new interface.It requests irq for the device, initializes the device,buffers and descriptors, and starts the device.
-*/
+
+/* This function opens new interface.It requests irq for the device,
+ * initializes the device,buffers and descriptors, and starts the device.
+ */
 static int amd8111e_open(struct net_device * dev )
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -1277,9 +1269,10 @@ static int amd8111e_open(struct net_device * dev )
 
 	return 0;
 }
-/*
-This function checks if there is any transmit  descriptors available to queue more packet.
-*/
+
+/* This function checks if there is any transmit  descriptors
+ * available to queue more packet.
+ */
 static int amd8111e_tx_queue_avail(struct amd8111e_priv* lp )
 {
 	int tx_index = lp->tx_idx & TX_BUFF_MOD_MASK;
@@ -1289,10 +1282,12 @@ static int amd8111e_tx_queue_avail(struct amd8111e_priv* lp )
 		return 0;
 
 }
-/*
-This function will queue the transmit packets to the descriptors and will trigger the send operation. It also initializes the transmit descriptors with buffer physical address, byte count, ownership to hardware etc.
-*/
 
+/* This function will queue the transmit packets to the
+ * descriptors and will trigger the send operation. It also
+ * initializes the transmit descriptors with buffer physical address,
+ * byte count, ownership to hardware etc.
+ */
 static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
 				       struct net_device * dev)
 {
@@ -1340,9 +1335,7 @@ static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
 	spin_unlock_irqrestore(&lp->lock, flags);
 	return NETDEV_TX_OK;
 }
-/*
-This function returns all the memory mapped registers of the device.
-*/
+/* This function returns all the memory mapped registers of the device. */
 static void amd8111e_read_regs(struct amd8111e_priv *lp, u32 *buf)
 {
 	void __iomem *mmio = lp->mmio;
@@ -1363,10 +1356,9 @@ static void amd8111e_read_regs(struct amd8111e_priv *lp, u32 *buf)
 }
 
 
-/*
-This function sets promiscuos mode, all-multi mode or the multicast address
-list to the device.
-*/
+/* This function sets promiscuos mode, all-multi mode or the multicast address
+ * list to the device.
+ */
 static void amd8111e_set_multicast_list(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
@@ -1503,10 +1495,10 @@ static const struct ethtool_ops ops = {
 	.set_wol = amd8111e_set_wol,
 };
 
-/*
-This function handles all the  ethtool ioctls. It gives driver info, gets/sets driver speed, gets memory mapped register values, forces auto negotiation, sets/gets WOL options for ethtool application.
-*/
-
+/* This function handles all the  ethtool ioctls. It gives driver info,
+ * gets/sets driver speed, gets memory mapped register values, forces
+ * auto negotiation, sets/gets WOL options for ethtool application.
+ */
 static int amd8111e_ioctl(struct net_device * dev , struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(ifr);
@@ -1561,9 +1553,9 @@ static int amd8111e_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-/*
-This function changes the mtu of the device. It restarts the device  to initialize the descriptor with new receive buffers.
-*/
+/* This function changes the mtu of the device. It restarts the device  to
+ * initialize the descriptor with new receive buffers.
+ */
 static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -1574,7 +1566,8 @@ static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 
 	if (!netif_running(dev)) {
 		/* new_mtu will be used
-		   when device starts netxt time */
+		 * when device starts netxt time
+		 */
 		dev->mtu = new_mtu;
 		return 0;
 	}
@@ -1614,8 +1607,7 @@ static int amd8111e_enable_link_change(struct amd8111e_priv* lp)
 	return 0;
 }
 
-/*
- * This function is called when a packet transmission fails to complete
+/* This function is called when a packet transmission fails to complete
  * within a reasonable period, on the assumption that an interrupt have
  * failed or the interface is locked up. This function will reinitialize
  * the hardware.
@@ -1925,7 +1917,6 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	}
 
 	/*  display driver and device information */
-
     	chip_version = (readl(lp->mmio + CHIPID) & 0xf0000000)>>28;
 	dev_info(&pdev->dev, "AMD-8111e Driver Version: %s\n", MODULE_VERS);
 	dev_info(&pdev->dev, "[ Rev %x ] PCI 10/100BaseT Ethernet %pM\n",
-- 
1.7.9.5
