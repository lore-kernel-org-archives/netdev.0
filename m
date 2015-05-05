From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 07/12] net: axienet: Fix comments blocks
Date: Tue,  5 May 2015 11:26:00 +0200
Message-ID: <d9252df148862a6ff385b14fbed66314148ef390.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: monstr@monstr.eu, linux-kernel@vger.kernel.org,
 =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
 Anirudha Sarangi <anirudh@xilinx.com>, John Linn <John.Linn@xilinx.com>,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

There is rule for network drivers with comments blocks
which is newly checked by checkpatch.pl script.
Let's fix it.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet.h      | 93 ++++++++++++-----------
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 34 +++++----
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c |  3 +-
 3 files changed, 71 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index 4e309440964a..2aa6857f930e 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -38,18 +38,21 @@
 #define XAE_OPTION_FLOW_CONTROL			(1 << 4)
 
 /* Strip FCS and PAD from incoming frames. Note: PAD from VLAN frames is not
- * stripped. Default: disabled (set) */
+ * stripped. Default: disabled (set)
+ */
 #define XAE_OPTION_FCS_STRIP			(1 << 5)
 
 /* Generate FCS field and add PAD automatically for outgoing frames.
- * Default: enabled (set) */
+ * Default: enabled (set)
+ */
 #define XAE_OPTION_FCS_INSERT			(1 << 6)
 
 /* Enable Length/Type error checking for incoming frames. When this option is
  * set, the MAC will filter frames that have a mismatched type/length field
  * and if XAE_OPTION_REPORT_RXERR is set, the user is notified when these
  * types of frames are encountered. When this option is cleared, the MAC will
- * allow these types of frames to be received. Default: enabled (set) */
+ * allow these types of frames to be received. Default: enabled (set)
+ */
 #define XAE_OPTION_LENTYPE_ERR			(1 << 7)
 
 /* Enable the transmitter. Default: enabled (set) */
@@ -159,12 +162,12 @@
 #define XAE_MDIO_MWD_OFFSET	0x00000508 /* MII Management Write Data */
 #define XAE_MDIO_MRD_OFFSET	0x0000050C /* MII Management Read Data */
 #define XAE_MDIO_MIS_OFFSET	0x00000600 /* MII Management Interrupt Status */
-#define XAE_MDIO_MIP_OFFSET	0x00000620 /* MII Mgmt Interrupt Pending
-					    * register offset */
-#define XAE_MDIO_MIE_OFFSET	0x00000640 /* MII Management Interrupt Enable
-					    * register offset */
-#define XAE_MDIO_MIC_OFFSET	0x00000660 /* MII Management Interrupt Clear
-					    * register offset. */
+/* MII Mgmt Interrupt Pending register offset */
+#define XAE_MDIO_MIP_OFFSET	0x00000620
+/* MII Management Interrupt Enable register offset */
+#define XAE_MDIO_MIE_OFFSET	0x00000640
+/* MII Management Interrupt Clear register offset. */
+#define XAE_MDIO_MIC_OFFSET	0x00000660
 #define XAE_UAW0_OFFSET		0x00000700 /* Unicast address word 0 */
 #define XAE_UAW1_OFFSET		0x00000704 /* Unicast address word 1 */
 #define XAE_FMI_OFFSET		0x00000708 /* Filter Mask Index */
@@ -176,18 +179,17 @@
 #define XAE_MCAST_TABLE_OFFSET	0x00020000 /* Multicast table address */
 
 /* Bit Masks for Axi Ethernet RAF register */
-#define XAE_RAF_MCSTREJ_MASK		0x00000002 /* Reject receive multicast
-						    * destination address */
-#define XAE_RAF_BCSTREJ_MASK		0x00000004 /* Reject receive broadcast
-						    * destination address */
+/* Reject receive multicast destination address */
+#define XAE_RAF_MCSTREJ_MASK		0x00000002
+/* Reject receive broadcast destination address */
+#define XAE_RAF_BCSTREJ_MASK		0x00000004
 #define XAE_RAF_TXVTAGMODE_MASK		0x00000018 /* Tx VLAN TAG mode */
 #define XAE_RAF_RXVTAGMODE_MASK		0x00000060 /* Rx VLAN TAG mode */
 #define XAE_RAF_TXVSTRPMODE_MASK	0x00000180 /* Tx VLAN STRIP mode */
 #define XAE_RAF_RXVSTRPMODE_MASK	0x00000600 /* Rx VLAN STRIP mode */
 #define XAE_RAF_NEWFNCENBL_MASK		0x00000800 /* New function mode */
-#define XAE_RAF_EMULTIFLTRENBL_MASK	0x00001000 /* Exteneded Multicast
-						    * Filtering mode
-						    */
+/* Exteneded Multicast Filtering mode */
+#define XAE_RAF_EMULTIFLTRENBL_MASK	0x00001000
 #define XAE_RAF_STATSRST_MASK		0x00002000 /* Stats. Counter Reset */
 #define XAE_RAF_RXBADFRMEN_MASK		0x00004000 /* Recv Bad Frame Enable */
 #define XAE_RAF_TXVTAGMODE_SHIFT	3 /* Tx Tag mode shift bits */
@@ -197,15 +199,16 @@
 
 /* Bit Masks for Axi Ethernet TPF and IFGP registers */
 #define XAE_TPF_TPFV_MASK		0x0000FFFF /* Tx pause frame value */
-#define XAE_IFGP0_IFGP_MASK		0x0000007F /* Transmit inter-frame
-						    * gap adjustment value */
+/* Transmit inter-frame gap adjustment value */
+#define XAE_IFGP0_IFGP_MASK		0x0000007F
 
 /* Bit Masks for Axi Ethernet IS, IE and IP registers, Same masks apply
- * for all 3 registers. */
-#define XAE_INT_HARDACSCMPLT_MASK	0x00000001 /* Hard register access
-						    * complete */
-#define XAE_INT_AUTONEG_MASK		0x00000002 /* Auto negotiation
-						    * complete */
+ * for all 3 registers.
+ */
+/* Hard register access complete */
+#define XAE_INT_HARDACSCMPLT_MASK	0x00000001
+/* Auto negotiation complete */
+#define XAE_INT_AUTONEG_MASK		0x00000002
 #define XAE_INT_RXCMPIT_MASK		0x00000004 /* Rx complete */
 #define XAE_INT_RXRJECT_MASK		0x00000008 /* Rx frame rejected */
 #define XAE_INT_RXFIFOOVR_MASK		0x00000010 /* Rx fifo overrun */
@@ -215,10 +218,9 @@
 #define XAE_INT_PHYRSTCMPLT_MASK	0x00000100 /* Phy Reset complete */
 #define XAE_INT_ALL_MASK		0x0000003F /* All the ints */
 
+/* INT bits that indicate receive errors */
 #define XAE_INT_RECV_ERROR_MASK				\
-	(XAE_INT_RXRJECT_MASK | XAE_INT_RXFIFOOVR_MASK) /* INT bits that
-							 * indicate receive
-							 * errors */
+	(XAE_INT_RXRJECT_MASK | XAE_INT_RXFIFOOVR_MASK)
 
 /* Bit masks for Axi Ethernet VLAN TPID Word 0 register */
 #define XAE_TPID_0_MASK		0x0000FFFF /* TPID 0 */
@@ -231,27 +233,28 @@
 /* Bit masks for Axi Ethernet RCW1 register */
 #define XAE_RCW1_RST_MASK	0x80000000 /* Reset */
 #define XAE_RCW1_JUM_MASK	0x40000000 /* Jumbo frame enable */
-#define XAE_RCW1_FCS_MASK	0x20000000 /* In-Band FCS enable
-					    * (FCS not stripped) */
+/* In-Band FCS enable (FCS not stripped) */
+#define XAE_RCW1_FCS_MASK	0x20000000
 #define XAE_RCW1_RX_MASK	0x10000000 /* Receiver enable */
 #define XAE_RCW1_VLAN_MASK	0x08000000 /* VLAN frame enable */
-#define XAE_RCW1_LT_DIS_MASK	0x02000000 /* Length/type field valid check
-					    * disable */
-#define XAE_RCW1_CL_DIS_MASK	0x01000000 /* Control frame Length check
-					    * disable */
-#define XAE_RCW1_PAUSEADDR_MASK 0x0000FFFF /* Pause frame source address
-					    * bits [47:32]. Bits [31:0] are
-					    * stored in register RCW0 */
+/* Length/type field valid check disable */
+#define XAE_RCW1_LT_DIS_MASK	0x02000000
+/* Control frame Length check disable */
+#define XAE_RCW1_CL_DIS_MASK	0x01000000
+/* Pause frame source address bits [47:32]. Bits [31:0] are
+ * stored in register RCW0
+ */
+#define XAE_RCW1_PAUSEADDR_MASK 0x0000FFFF
 
 /* Bit masks for Axi Ethernet TC register */
 #define XAE_TC_RST_MASK		0x80000000 /* Reset */
 #define XAE_TC_JUM_MASK		0x40000000 /* Jumbo frame enable */
-#define XAE_TC_FCS_MASK		0x20000000 /* In-Band FCS enable
-					    * (FCS not generated) */
+/* In-Band FCS enable (FCS not generated) */
+#define XAE_TC_FCS_MASK		0x20000000
 #define XAE_TC_TX_MASK		0x10000000 /* Transmitter enable */
 #define XAE_TC_VLAN_MASK	0x08000000 /* VLAN frame enable */
-#define XAE_TC_IFG_MASK		0x02000000 /* Inter-frame gap adjustment
-					    * enable */
+/* Inter-frame gap adjustment enable */
+#define XAE_TC_IFG_MASK		0x02000000
 
 /* Bit masks for Axi Ethernet FCC register */
 #define XAE_FCC_FCRX_MASK	0x20000000 /* Rx flow control enable */
@@ -301,10 +304,10 @@
 #define XAE_MDIO_INT_MIIM_RDY_MASK	0x00000001 /* MIIM Interrupt */
 
 /* Bit masks for Axi Ethernet UAW1 register */
-#define XAE_UAW1_UNICASTADDR_MASK	0x0000FFFF /* Station address bits
-						    * [47:32]; Station address
-						    * bits [31:0] are stored in
-						    * register UAW0 */
+/* Station address bits [47:32]; Station address
+ * bits [31:0] are stored in register UAW0
+ */
+#define XAE_UAW1_UNICASTADDR_MASK	0x0000FFFF
 
 /* Bit masks for Axi Ethernet FMI register */
 #define XAE_FMI_PM_MASK			0x80000000 /* Promis. mode enable */
@@ -320,8 +323,8 @@
 #define XAE_PHY_TYPE_SGMII		4
 #define XAE_PHY_TYPE_1000BASE_X		5
 
-#define XAE_MULTICAST_CAM_TABLE_NUM	4 /* Total number of entries in the
-					   * hardware multicast table. */
+ /* Total number of entries in the hardware multicast table. */
+#define XAE_MULTICAST_CAM_TABLE_NUM	4
 
 /* Axi Ethernet Synthesis features */
 #define XAE_FEATURE_PARTIAL_RX_CSUM	(1 << 0)
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 39bb2e93cc65..ddaa07a0bf51 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -198,9 +198,7 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 	lp->tx_bd_tail = 0;
 	lp->rx_bd_ci = 0;
 
-	/*
-	 * Allocate the Tx and Rx buffer descriptors.
-	 */
+	/* Allocate the Tx and Rx buffer descriptors. */
 	lp->tx_bd_v = dma_zalloc_coherent(ndev->dev.parent,
 					  sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 					  &lp->tx_bd_p, GFP_KERNEL);
@@ -263,7 +261,8 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 	axienet_dma_out32(lp, XAXIDMA_TX_CR_OFFSET, cr);
 
 	/* Populate the tail pointer and bring the Rx Axi DMA engine out of
-	 * halted state. This will make the Rx side ready for reception.*/
+	 * halted state. This will make the Rx side ready for reception.
+	 */
 	axienet_dma_out32(lp, XAXIDMA_RX_CDESC_OFFSET, lp->rx_bd_p);
 	cr = axienet_dma_in32(lp, XAXIDMA_RX_CR_OFFSET);
 	axienet_dma_out32(lp, XAXIDMA_RX_CR_OFFSET,
@@ -273,7 +272,8 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 
 	/* Write to the RS (Run-stop) bit in the Tx channel control register.
 	 * Tx channel is now ready to run. But only after we write to the
-	 * tail pointer register that the Tx channel will start transmitting */
+	 * tail pointer register that the Tx channel will start transmitting.
+	 */
 	axienet_dma_out32(lp, XAXIDMA_TX_CDESC_OFFSET, lp->tx_bd_p);
 	cr = axienet_dma_in32(lp, XAXIDMA_TX_CR_OFFSET);
 	axienet_dma_out32(lp, XAXIDMA_TX_CR_OFFSET,
@@ -354,7 +354,8 @@ static void axienet_set_multicast_list(struct net_device *ndev)
 	    netdev_mc_count(ndev) > XAE_MULTICAST_CAM_TABLE_NUM) {
 		/* We must make the kernel realize we had to move into
 		 * promiscuous mode. If it was a promiscuous mode request
-		 * the flag is already set. If not we set it. */
+		 * the flag is already set. If not we set it.
+		 */
 		ndev->flags |= IFF_PROMISC;
 		reg = axienet_ior(lp, XAE_FMI_OFFSET);
 		reg |= XAE_FMI_PM_MASK;
@@ -438,7 +439,8 @@ static void __axienet_device_reset(struct axienet_local *lp,
 	/* Reset Axi DMA. This would reset Axi Ethernet core as well. The reset
 	 * process of Axi DMA takes a while to complete as all pending
 	 * commands/transfers will be flushed or completed during this
-	 * reset process. */
+	 * reset process.
+	 */
 	axienet_dma_out32(lp, offset, XAXIDMA_CR_RESET_MASK);
 	timeout = DELAY_OF_ONE_MILLISEC;
 	while (axienet_dma_in32(lp, offset) & XAXIDMA_CR_RESET_MASK) {
@@ -499,7 +501,8 @@ static void axienet_device_reset(struct net_device *ndev)
 	axienet_iow(lp, XAE_FCC_OFFSET, XAE_FCC_FCRX_MASK);
 
 	/* Sync default options with HW but leave receiver and
-	 * transmitter disabled.*/
+	 * transmitter disabled.
+	 */
 	axienet_setoptions(ndev, lp->options &
 			   ~(XAE_OPTION_TXEN | XAE_OPTION_RXEN));
 	axienet_set_mac_address(ndev, NULL);
@@ -919,7 +922,8 @@ static int axienet_open(struct net_device *ndev)
 	/* Disable the MDIO interface till Axi Ethernet Reset is completed.
 	 * When we do an Axi Ethernet reset, it resets the complete core
 	 * including the MDIO. If MDIO is not disabled when the reset
-	 * process is started, MDIO will be broken afterwards. */
+	 * process is started, MDIO will be broken afterwards.
+	 */
 	axienet_iow(lp, XAE_MDIO_MC_OFFSET,
 		    (mdio_mcreg & (~XAE_MDIO_MC_MDIOEN_MASK)));
 	axienet_device_reset(ndev);
@@ -1365,7 +1369,8 @@ static void axienet_dma_err_handler(unsigned long data)
 	/* Disable the MDIO interface till Axi Ethernet Reset is completed.
 	 * When we do an Axi Ethernet reset, it resets the complete core
 	 * including the MDIO. So if MDIO is not disabled when the reset
-	 * process is started, MDIO will be broken afterwards. */
+	 * process is started, MDIO will be broken afterwards.
+	 */
 	axienet_iow(lp, XAE_MDIO_MC_OFFSET, (mdio_mcreg &
 		    ~XAE_MDIO_MC_MDIOEN_MASK));
 
@@ -1436,7 +1441,8 @@ static void axienet_dma_err_handler(unsigned long data)
 	axienet_dma_out32(lp, XAXIDMA_TX_CR_OFFSET, cr);
 
 	/* Populate the tail pointer and bring the Rx Axi DMA engine out of
-	 * halted state. This will make the Rx side ready for reception.*/
+	 * halted state. This will make the Rx side ready for reception.
+	 */
 	axienet_dma_out32(lp, XAXIDMA_RX_CDESC_OFFSET, lp->rx_bd_p);
 	cr = axienet_dma_in32(lp, XAXIDMA_RX_CR_OFFSET);
 	axienet_dma_out32(lp, XAXIDMA_RX_CR_OFFSET,
@@ -1446,7 +1452,8 @@ static void axienet_dma_err_handler(unsigned long data)
 
 	/* Write to the RS (Run-stop) bit in the Tx channel control register.
 	 * Tx channel is now ready to run. But only after we write to the
-	 * tail pointer register that the Tx channel will start transmitting */
+	 * tail pointer register that the Tx channel will start transmitting
+	 */
 	axienet_dma_out32(lp, XAXIDMA_TX_CDESC_OFFSET, lp->tx_bd_p);
 	cr = axienet_dma_in32(lp, XAXIDMA_TX_CR_OFFSET);
 	axienet_dma_out32(lp, XAXIDMA_TX_CR_OFFSET,
@@ -1462,7 +1469,8 @@ static void axienet_dma_err_handler(unsigned long data)
 	axienet_iow(lp, XAE_FCC_OFFSET, XAE_FCC_FCRX_MASK);
 
 	/* Sync default options with HW but leave receiver and
-	 * transmitter disabled.*/
+	 * transmitter disabled.
+	 */
 	axienet_setoptions(ndev, lp->options &
 			   ~(XAE_OPTION_TXEN | XAE_OPTION_RXEN));
 	axienet_set_mac_address(ndev, NULL);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
index fce557518b7d..315136db37c9 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -183,7 +183,8 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)
 	clk_div = (host_clock / (MAX_MDIO_FREQ * 2)) - 1;
 	/* If there is any remainder from the division of
 	 * fHOST / (MAX_MDIO_FREQ * 2), then we need to add
-	 * 1 to the clock divisor or we will surely be above 2.5 MHz */
+	 * 1 to the clock divisor or we will surely be above 2.5 MHz
+	 */
 	if (host_clock % (MAX_MDIO_FREQ * 2))
 		clk_div++;
 
-- 
2.3.5
