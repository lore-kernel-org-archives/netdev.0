From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 1/8] S2io: cosmetic changes
Date: Wed, 13 Oct 2004 18:13:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003e01c4b18b$0578cd70$6c10100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_003F_01C4B150.5919F570"
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_003F_01C4B150.5919F570
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi All,
This is the first patch in the 8 part series. I'll be sending
the remaining immediately following this patch.

This first patch contains cosmetic changes such as indentation, 
change in comment styles, variable name changes etc.

Randy, we'll implement your comment about C99 syntax along with
all the other comments received, in the next submission.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>


------=_NextPart_000_003F_01C4B150.5919F570
Content-Type: application/octet-stream;
	name="s2io_cosmetic.patch1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2io_cosmetic.patch1"

diff -urN vanilla-linux/drivers/net/s2io.c =
linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-06 11:31:09.552305224 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-06 13:03:08.087360376 -0700
@@ -69,7 +69,7 @@
=20
 /* S2io Driver name & version. */
 static char s2io_driver_name[] =3D "s2io";
-static char s2io_driver_version[] =3D "Version 1.0";
+static char s2io_driver_version[] =3D "Version 1.7.5.1";
=20
 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT =
| \
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
@@ -99,45 +99,45 @@
 };
=20
 static char ethtool_stats_keys[][ETH_GSTRING_LEN] =3D {
-	"tmac_frms",
-	"tmac_data_octets",
-	"tmac_drop_frms",
-	"tmac_mcst_frms",
-	"tmac_bcst_frms",
-	"tmac_pause_ctrl_frms",
-	"tmac_any_err_frms",
-	"tmac_vld_ip_octets",
-	"tmac_vld_ip",
-	"tmac_drop_ip",
-	"tmac_icmp",
-	"tmac_rst_tcp",
-	"tmac_tcp",
-	"tmac_udp",
-	"rmac_vld_frms",
-	"rmac_data_octets",
-	"rmac_fcs_err_frms",
-	"rmac_drop_frms",
-	"rmac_vld_mcst_frms",
-	"rmac_vld_bcst_frms",
-	"rmac_in_rng_len_err_frms",
-	"rmac_long_frms",
-	"rmac_pause_ctrl_frms",
-	"rmac_discarded_frms",
-	"rmac_usized_frms",
-	"rmac_osized_frms",
-	"rmac_frag_frms",
-	"rmac_jabber_frms",
-	"rmac_ip",
-	"rmac_ip_octets",
-	"rmac_hdr_err_ip",
-	"rmac_drop_ip",
-	"rmac_icmp",
-	"rmac_tcp",
-	"rmac_udp",
-	"rmac_err_drp_udp",
-	"rmac_pause_cnt",
-	"rmac_accepted_ip",
-	"rmac_err_tcp",
+	{"tmac_frms"},
+	{"tmac_data_octets"},
+	{"tmac_drop_frms"},
+	{"tmac_mcst_frms"},
+	{"tmac_bcst_frms"},
+	{"tmac_pause_ctrl_frms"},
+	{"tmac_any_err_frms"},
+	{"tmac_vld_ip_octets"},
+	{"tmac_vld_ip"},
+	{"tmac_drop_ip"},
+	{"tmac_icmp"},
+	{"tmac_rst_tcp"},
+	{"tmac_tcp"},
+	{"tmac_udp"},
+	{"rmac_vld_frms"},
+	{"rmac_data_octets"},
+	{"rmac_fcs_err_frms"},
+	{"rmac_drop_frms"},
+	{"rmac_vld_mcst_frms"},
+	{"rmac_vld_bcst_frms"},
+	{"rmac_in_rng_len_err_frms"},
+	{"rmac_long_frms"},
+	{"rmac_pause_ctrl_frms"},
+	{"rmac_discarded_frms"},
+	{"rmac_usized_frms"},
+	{"rmac_osized_frms"},
+	{"rmac_frag_frms"},
+	{"rmac_jabber_frms"},
+	{"rmac_ip"},
+	{"rmac_ip_octets"},
+	{"rmac_hdr_err_ip"},
+	{"rmac_drop_ip"},
+	{"rmac_icmp"},
+	{"rmac_tcp"},
+	{"rmac_udp"},
+	{"rmac_err_drp_udp"},
+	{"rmac_pause_cnt"},
+	{"rmac_accepted_ip"},
+	{"rmac_err_tcp"},
 };
=20
 #define S2IO_STAT_LEN sizeof(ethtool_stats_keys)/ ETH_GSTRING_LEN
@@ -147,7 +147,8 @@
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
=20
=20
-/* Constants to be programmed into the Xena's registers to configure
+/*=20
+ * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
  */
=20
@@ -188,7 +189,9 @@
 	END_SIGN
 };
=20
-/* Constants for Fixing the MacAddress problem seen mostly on
+
+/*=20
+ * Constants for Fixing the MacAddress problem seen mostly on
  * Alpha machines.
  */
 static u64 fix_mac[] =3D {
@@ -209,7 +212,6 @@
 	END_SIGN
 };
=20
-
 /* Module Loadable parameters. */
 static u32 ring_num;
 static u32 frame_len[MAX_RX_RINGS];
@@ -218,7 +220,7 @@
 static u32 fifo_len[MAX_TX_FIFOS];
 static u32 rx_prio;
 static u32 tx_prio;
-static u8 latency_timer =3D 0;
+static u8 latency_timer;
=20
 /*=20
  * S2IO device table.
@@ -241,17 +243,15 @@
       remove:__devexit_p(s2io_rem_nic),
 };
=20
-/* =20
- *  Input Arguments:=20
- *  Device private variable.
- *  Return Value:=20
- *  SUCCESS on success and an appropriate -ve value on failure.
- *  Description:=20
- *  The function allocates the all memory areas shared=20
- *  between the NIC and the driver. This includes Tx descriptors,=20
- *  Rx descriptors and the statistics block.
+/**
+ * init_shared_mem - Allocation and Initialization of Memory
+ * @nic: Device private variable.
+ * Description: The function allocates all the memory areas shared=20
+ * between the NIC and the driver. This includes Tx descriptors,=20
+ * Rx descriptors and the statistics block.
  */
-static int initSharedMem(struct s2io_nic *nic)
+
+static int init_shared_mem(struct s2io_nic *nic)
 {
 	u32 size;
 	void *tmp_v_addr, *tmp_v_addr_next;
@@ -269,8 +269,8 @@
=20
 	/* Allocation and initialization of TXDLs in FIOFs */
 	size =3D 0;
-	for (i =3D 0; i < config->TxFIFONum; i++) {
-		size +=3D config->TxCfg[i].FifoLen;
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
+		size +=3D config->tx_cfg[i].fifo_len;
 	}
 	if (size > MAX_AVAILABLE_TXDS) {
 		DBG_PRINT(ERR_DBG, "%s: Total number of Tx FIFOs ",
@@ -279,7 +279,7 @@
 		DBG_PRINT(ERR_DBG, "that can be used\n");
 		return FAILURE;
 	}
-	size *=3D (sizeof(TxD_t) * config->MaxTxDs);
+	size *=3D (sizeof(TxD_t) * config->max_txds);
=20
 	mac_control->txd_list_mem =3D pci_alloc_consistent
 	    (nic->pdev, size, &mac_control->txd_list_mem_phy);
@@ -295,61 +295,60 @@
 	DBG_PRINT(INIT_DBG, "%s:List Mem PHY: 0x%llx\n", dev->name,
 		  (unsigned long long) tmp_p_addr);
=20
-	for (i =3D 0; i < config->TxFIFONum; i++) {
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
 		mac_control->txdl_start_phy[i] =3D tmp_p_addr;
 		mac_control->txdl_start[i] =3D (TxD_t *) tmp_v_addr;
 		mac_control->tx_curr_put_info[i].offset =3D 0;
 		mac_control->tx_curr_put_info[i].fifo_len =3D
-		    config->TxCfg[i].FifoLen - 1;
+		    config->tx_cfg[i].fifo_len - 1;
 		mac_control->tx_curr_get_info[i].offset =3D 0;
 		mac_control->tx_curr_get_info[i].fifo_len =3D
-		    config->TxCfg[i].FifoLen - 1;
+		    config->tx_cfg[i].fifo_len - 1;
=20
 		tmp_p_addr +=3D
-		    (config->TxCfg[i].FifoLen * (sizeof(TxD_t)) *
-		     config->MaxTxDs);
+		    (config->tx_cfg[i].fifo_len * (sizeof(TxD_t)) *
+		     config->max_txds);
 		tmp_v_addr +=3D
-		    (config->TxCfg[i].FifoLen * (sizeof(TxD_t)) *
-		     config->MaxTxDs);
+		    (config->tx_cfg[i].fifo_len * (sizeof(TxD_t)) *
+		     config->max_txds);
 	}
=20
 	/* Allocation and initialization of RXDs in Rings */
 	size =3D 0;
-	for (i =3D 0; i < config->RxRingNum; i++) {
-		if (config->RxCfg[i].NumRxd % (MAX_RXDS_PER_BLOCK + 1)) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
+		if (config->rx_cfg[i].num_rxd % (MAX_RXDS_PER_BLOCK + 1)) {
 			DBG_PRINT(ERR_DBG, "%s: RxD count of ", dev->name);
 			DBG_PRINT(ERR_DBG, "Ring%d is not a multiple of ",
 				  i);
 			DBG_PRINT(ERR_DBG, "RxDs per Block");
 			return FAILURE;
 		}
-		size +=3D config->RxCfg[i].NumRxd;
+		size +=3D config->rx_cfg[i].num_rxd;
 		nic->block_count[i] =3D
-		    config->RxCfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);
+		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
 		nic->pkt_cnt[i] =3D
-		    config->RxCfg[i].NumRxd - nic->block_count[i];
+		    config->rx_cfg[i].num_rxd - nic->block_count[i];
 	}
-	size =3D (size * (sizeof(RxD_t)));
-	mac_control->rxd_ring_mem_sz =3D size;
=20
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		mac_control->rx_curr_get_info[i].block_index =3D 0;
 		mac_control->rx_curr_get_info[i].offset =3D 0;
 		mac_control->rx_curr_get_info[i].ring_len =3D
-		    config->RxCfg[i].NumRxd - 1;
+		    config->rx_cfg[i].num_rxd - 1;
 		mac_control->rx_curr_put_info[i].block_index =3D 0;
 		mac_control->rx_curr_put_info[i].offset =3D 0;
 		mac_control->rx_curr_put_info[i].ring_len =3D
-		    config->RxCfg[i].NumRxd - 1;
+		    config->rx_cfg[i].num_rxd - 1;
 		blk_cnt =3D
-		    config->RxCfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);
+		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
 		/*  Allocating all the Rx blocks */
 		for (j =3D 0; j < blk_cnt; j++) {
 			size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
 			tmp_v_addr =3D pci_alloc_consistent(nic->pdev, size,
 							  &tmp_p_addr);
 			if (tmp_v_addr =3D=3D NULL) {
-				/* In case of failure, freeSharedMem()=20
+				/*
+				 * In case of failure, free_shared_mem()=20
 				 * is called, which should free any=20
 				 * memory that was alloced till the=20
 				 * failure happened.
@@ -390,7 +389,8 @@
 	    (nic->pdev, size, &mac_control->stats_mem_phy);
=20
 	if (!mac_control->stats_mem) {
-		/* In case of failure, freeSharedMem() is called, which=20
+		/*=20
+		 * In case of failure, free_shared_mem() is called, which=20
 		 * should free any memory that was alloced till the=20
 		 * failure happened.
 		 */
@@ -399,7 +399,7 @@
 	mac_control->stats_mem_sz =3D size;
=20
 	tmp_v_addr =3D mac_control->stats_mem;
-	mac_control->StatsInfo =3D (StatInfo_t *) tmp_v_addr;
+	mac_control->stats_info =3D (StatInfo_t *) tmp_v_addr;
 	memset(tmp_v_addr, 0, size);
=20
 	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
@@ -408,16 +408,14 @@
 	return SUCCESS;
 }
=20
-/* =20
- *  Input Arguments:=20
- *  Device peivate variable.
- *  Return Value:=20
- *  NONE
- *  Description:=20
- *  This function is to free all memory locations allocated by
- *  the initSharedMem() function and return it to the kernel.
+/** =20
+ * free_shared_mem - Free the allocated Memory=20
+ * @nic:  Device private variable.
+ * Description: This function is to free all memory locations allocated =
by
+ * the init_shared_mem() function and return it to the kernel.
  */
-static void freeSharedMem(struct s2io_nic *nic)
+
+static void free_shared_mem(struct s2io_nic *nic)
 {
 	int i, j, blk_cnt, size;
 	void *tmp_v_addr;
@@ -440,7 +438,7 @@
 	}
=20
 	size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		blk_cnt =3D nic->block_count[i];
 		for (j =3D 0; j < blk_cnt; j++) {
 			tmp_v_addr =3D nic->rx_blocks[i][j].block_virt_addr;
@@ -452,6 +450,7 @@
 		}
 	}
=20
+
 	if (mac_control->stats_mem) {
 		pci_free_consistent(nic->pdev,
 				    mac_control->stats_mem_sz,
@@ -460,16 +459,16 @@
 	}
 }
=20
-/* =20
- *  Input Arguments:=20
- *  device peivate variable
- *  Return Value:=20
- *  SUCCESS on success and '-1' on failure (endian settings incorrect).
- *  Description:=20
- *  The function sequentially configures every block=20
+/** =20
+ *  init_nic - Initialization of hardware=20
+ *  @nic: device peivate variable
+ *  Description: The function sequentially configures every block=20
  *  of the H/W from their reset values.=20
+ *  Return Value:  SUCCESS on success and=20
+ *  '-1' on failure (endian settings incorrect).
  */
-static int initNic(struct s2io_nic *nic)
+
+static int init_nic(struct s2io_nic *nic)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	struct net_device *dev =3D nic->dev;
@@ -485,11 +484,13 @@
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
=20
-	/*  Set proper endian settings and verify the same by=20
-	 *  reading the PIF Feed-back register.
+	/*=20
+	 * Set proper endian settings and verify the same by=20
+	 * reading the PIF Feed-back register.
 	 */
 #ifdef  __BIG_ENDIAN
-	/* The device by default set to a big endian format, so=20
+	/*
+	 * The device by default set to a big endian format, so=20
 	 * a big endian driver need not set anything.
 	 */
 	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
@@ -510,7 +511,8 @@
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
 	writeq(val64, &bar0->swapper_ctrl);
 #else
-	/* Initially we enable all bits to make it accessible by=20
+	/*=20
+	 * Initially we enable all bits to make it accessible by=20
 	 * the driver, then we selectively enable only those bits=20
 	 * that we want to set.
 	 */
@@ -537,8 +539,9 @@
 	writeq(val64, &bar0->swapper_ctrl);
 #endif
=20
-	/* Verifying if endian settings are accurate by reading=20
-	 * a feedback register.
+	/*=20
+	 * Verifying if endian settings are accurate by=20
+	 * reading a feedback register.
 	 */
 	val64 =3D readq(&bar0->pif_rd_swapper_fb);
 	if (val64 !=3D 0x0123456789ABCDEFULL) {
@@ -573,8 +576,9 @@
 	val64 =3D dev->mtu;
 	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
=20
-	/* Configuring the XAUI Interface of Xena.=20
-	 *****************************************
+	/*=20
+	 * Configuring the XAUI Interface of Xena.=20
+	 * ***************************************
 	 * To Configure the Xena's XAUI, one has to write a series=20
 	 * of 64 bit values into two registers in a particular=20
 	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined=20
@@ -625,13 +629,13 @@
 	writeq(val64, &bar0->tx_fifo_partition_3);
=20
=20
-	for (i =3D 0, j =3D 0; i < config->TxFIFONum; i++) {
+	for (i =3D 0, j =3D 0; i < config->tx_fifo_num; i++) {
 		val64 |=3D
-		    vBIT(config->TxCfg[i].FifoLen - 1, ((i * 32) + 19),
-			 13) | vBIT(config->TxCfg[i].FifoPriority,
+		    vBIT(config->tx_cfg[i].fifo_len - 1, ((i * 32) + 19),
+			 13) | vBIT(config->tx_cfg[i].fifo_priority,
 				    ((i * 32) + 5), 3);
=20
-		if (i =3D=3D (config->TxFIFONum - 1)) {
+		if (i =3D=3D (config->tx_fifo_num - 1)) {
 			if (i % 2 =3D=3D 0)
 				i++;
 		}
@@ -675,56 +679,59 @@
=20
 	/* Rx DMA intialization. */
 	val64 =3D 0;
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		val64 |=3D
-		    vBIT(config->RxCfg[i].RingPriority, (5 + (i * 8)), 3);
+		    vBIT(config->rx_cfg[i].ring_priority, (5 + (i * 8)),
+			 3);
 	}
 	writeq(val64, &bar0->rx_queue_priority);
=20
-	/* Allocating equal share of memory to all the configured=20
-	 * Rings.
+	/*=20
+	 * Allocating equal share of memory to all the=20
+	 * configured Rings.
 	 */
 	val64 =3D 0;
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		switch (i) {
 		case 0:
-			mem_share =3D (64 / config->RxRingNum +
-				     64 % config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num +
+				     64 % config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q0_SZ(mem_share);
 			continue;
 		case 1:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q1_SZ(mem_share);
 			continue;
 		case 2:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q2_SZ(mem_share);
 			continue;
 		case 3:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q3_SZ(mem_share);
 			continue;
 		case 4:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q4_SZ(mem_share);
 			continue;
 		case 5:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q5_SZ(mem_share);
 			continue;
 		case 6:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q6_SZ(mem_share);
 			continue;
 		case 7:
-			mem_share =3D (64 / config->RxRingNum);
+			mem_share =3D (64 / config->rx_ring_num);
 			val64 |=3D RX_QUEUE_CFG_Q7_SZ(mem_share);
 			continue;
 		}
 	}
 	writeq(val64, &bar0->rx_queue_cfg);
=20
-	/* Initializing the Tx round robin registers to 0.
+	/*=20
+	 * Initializing the Tx round robin registers to 0.
 	 * Filling Tx and Rx round robin registers as per the=20
 	 * number of FIFOs and Rings is still TODO.
 	 */
@@ -734,13 +741,15 @@
 	writeq(0, &bar0->tx_w_round_robin_3);
 	writeq(0, &bar0->tx_w_round_robin_4);
=20
-	/* Disable Rx steering. Hard coding all packets be steered to
+	/*=20
+	 * TODO
+	 * Disable Rx steering. Hard coding all packets be steered to
 	 * Queue 0 for now.=20
-	 * TODO*/
+	 */
 	if (rx_prio) {
 		u64 def =3D 0x8000000000000000ULL, tmp;
 		for (i =3D 0; i < MAX_RX_RINGS; i++) {
-			tmp =3D (u64) (def >> (i % config->RxRingNum));
+			tmp =3D (u64) (def >> (i % config->rx_ring_num));
 			val64 |=3D (u64) (tmp >> (i * 8));
 		}
 		writeq(val64, &bar0->rts_qos_steering);
@@ -763,14 +772,16 @@
 	val64 =3D SET_UPDT_PERIOD(8) | STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
 	writeq(val64, &bar0->stat_cfg);
=20
-	/* Initializing the sampling rate for the device to calculate the
+	/*=20
+	 * Initializing the sampling rate for the device to calculate the
 	 * bandwidth utilization.
 	 */
 	val64 =3D MAC_TX_LINK_UTIL_VAL(0x5) | MAC_RX_LINK_UTIL_VAL(0x5);
 	writeq(val64, &bar0->mac_link_util);
=20
=20
-	/* Initializing the Transmit and Receive Traffic Interrupt=20
+	/*=20
+	 * Initializing the Transmit and Receive Traffic Interrupt=20
 	 * Scheme.
 	 */
 	/* TTI Initialization */
@@ -787,7 +798,8 @@
 	val64 =3D TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
 	writeq(val64, &bar0->tti_command_mem);
=20
-	/* Once the operation completes, the Strobe bit of the command
+	/*=20
+	 * Once the operation completes, the Strobe bit of the command
 	 * register will be reset. We poll for this particular condition
 	 * We wait for a maximum of 500ms for the operation to complete,
 	 * if it's not complete by then we return error.
@@ -821,7 +833,8 @@
 	val64 =3D RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;
 	writeq(val64, &bar0->rti_command_mem);
=20
-	/* Once the operation completes, the Strobe bit of the command
+	/*=20
+	 * Once the operation completes, the Strobe bit of the command
 	 * register will be reset. We poll for this particular condition
 	 * We wait for a maximum of 500ms for the operation to complete,
 	 * if it's not complete by then we return error.
@@ -842,7 +855,8 @@
 		schedule_timeout(HZ / 20);
 	}
=20
-	/* Initializing proper values as Pause threshold into all=20
+	/*=20
+	 * Initializing proper values as Pause threshold into all=20
 	 * the 8 Queues on Rx side.
 	 */
 	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q0q3);
@@ -861,19 +875,18 @@
 	return SUCCESS;
 }
=20
-/* =20
- *  Input Arguments:=20
- *  device private variable,
- *  A mask indicating which Intr block must be modified and,
- *  A flag indicating whether to enable or disable the Intrs.
- *  Return Value:=20
- *  NONE.
- *  Description:=20
- *  This function will either disable or enable the interrupts=20
+/** =20
+ *  en_dis_able_nic_intrs - Enable or Disable the interrupts=20
+ *  @nic: device private variable,
+ *  @mask: A mask indicating which Intr block must be modified and,
+ *  @flag: A flag indicating whether to enable or disable the Intrs.
+ *  Description: This function will either disable or enable the =
interrupts
  *  depending on the flag argument. The mask argument can be used to=20
  *  enable/disable any Intr block.=20
+ *  Return Value: NONE.
  */
-static void en_dis_able_NicIntrs(struct s2io_nic *nic, u16 mask, int =
flag)
+
+static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int =
flag)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	register u64 val64 =3D 0, temp64 =3D 0;
@@ -887,15 +900,20 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/*  Disabled all PCIX, Flash, MDIO, IIC and GPIO
-			 *  interrupts for now.=20
-			 * TODO */
+			/* =20
+			 * Disabled all PCIX, Flash, MDIO, IIC and GPIO
+			 * interrupts for now.=20
+			 * TODO=20
+			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
-			/*  No MSI Support is available presently, so TTI and
+			/*=20
+			 * No MSI Support is available presently, so TTI and
 			 * RTI interrupts are also disabled.
 			 */
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable PIC Intrs in the general intr mask register=20
+			/* =20
+			 * Disable PIC Intrs in the general=20
+			 * intr mask register=20
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
@@ -907,24 +925,34 @@
 	/*  DMA Interrupts */
 	/*  Enabling/Disabling Tx DMA interrupts */
 	if (mask & TX_DMA_INTR) {
-		/*  Enable TxDMA Intrs in the general intr mask register */
+		/* Enable TxDMA Intrs in the general intr mask register */
 		val64 =3D TXDMA_INT_M;
 		if (flag =3D=3D ENABLE_INTRS) {
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* Disable all interrupts other than PFC interrupt in=20
-			 * DMA level.
+			/*=20
+			 * Keep all interrupts other than PFC interrupt=20
+			 * and PCC interrupt disabled in DMA level.
 			 */
-			val64 =3D DISABLE_ALL_INTRS & (~TXDMA_PFC_INT_M);
+			val64 =3D DISABLE_ALL_INTRS & ~(TXDMA_PFC_INT_M |
+						      TXDMA_PCC_INT_M);
 			writeq(val64, &bar0->txdma_int_mask);
-			/* Enable only the MISC error 1 interrupt in PFC block=20
+			/*=20
+			 * Enable only the MISC error 1 interrupt in PFC block=20
 			 */
 			val64 =3D DISABLE_ALL_INTRS & (~PFC_MISC_ERR_1);
 			writeq(val64, &bar0->pfc_err_mask);
+			/*=20
+			 * Enable only the FB_ECC error interrupt in PCC block=20
+			 */
+			val64 =3D DISABLE_ALL_INTRS & (~PCC_FB_ECC_ERR);
+			writeq(val64, &bar0->pcc_err_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable TxDMA Intrs in the general intr mask=20
-			 *  register */
+			/*=20
+			 * Disable TxDMA Intrs in the general intr mask=20
+			 * register=20
+			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->txdma_int_mask);
 			writeq(DISABLE_ALL_INTRS, &bar0->pfc_err_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
@@ -941,12 +969,16 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* All RxDMA block interrupts are disabled for now=20
-			 * TODO */
+			/*=20
+			 * All RxDMA block interrupts are disabled for now=20
+			 * TODO=20
+			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable RxDMA Intrs in the general intr mask=20
-			 *  register */
+			/* =20
+			 * Disable RxDMA Intrs in the general intr mask=20
+			 * register=20
+			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
 			val64 |=3D temp64;
@@ -962,9 +994,11 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* All MAC block error interrupts are disabled for now=20
+			/*=20
+			 * All MAC block error interrupts are disabled for now=20
 			 * except the link status change interrupt.
-			 * TODO*/
+			 * TODO
+			 */
 			val64 =3D MAC_INT_STATUS_RMAC_INT;
 			temp64 =3D readq(&bar0->mac_int_mask);
 			temp64 &=3D ~((u64) val64);
@@ -974,7 +1008,8 @@
 			val64 &=3D ~((u64) RMAC_LINK_STATE_CHANGE_INT);
 			writeq(val64, &bar0->mac_rmac_err_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable MAC Intrs in the general intr mask register=20
+			/* =20
+			 * Disable MAC Intrs in the general intr mask register=20
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->mac_int_mask);
 			writeq(DISABLE_ALL_INTRS,
@@ -993,11 +1028,14 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* All XGXS block error interrupts are disabled for now
-			 *  TODO */
+			/*=20
+			 * All XGXS block error interrupts are disabled for now
+			 * TODO=20
+			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable MC Intrs in the general intr mask register=20
+			/* =20
+			 * Disable MC Intrs in the general intr mask register=20
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
@@ -1013,11 +1051,14 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* All MC block error interrupts are disabled for now
-			 * TODO */
+			/*=20
+			 * All MC block error interrupts are disabled for now
+			 * TODO=20
+			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable MC Intrs in the general intr mask register
+			/*
+			 * Disable MC Intrs in the general intr mask register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
@@ -1034,15 +1075,15 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			/* Enable all the Tx side interrupts */
-			writeq(0x0, &bar0->tx_traffic_mask);	/* '0' Enables=20
-								 * all 64 TX=20
-								 * interrupt=20
-								 * levels.
-								 */
+			/*=20
+			 * Enable all the Tx side interrupts
+			 * writing 0 Enables all 64 TX interrupt levels=20
+			 */
+			writeq(0x0, &bar0->tx_traffic_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable Tx Traffic Intrs in the general intr mask=20
-			 *  register.
+			/*=20
+			 * Disable Tx Traffic Intrs in the general intr mask=20
+			 * register.
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->tx_traffic_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
@@ -1058,14 +1099,12 @@
 			temp64 =3D readq(&bar0->general_int_mask);
 			temp64 &=3D ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
-			writeq(0x0, &bar0->rx_traffic_mask);	/* '0' Enables=20
-								 * all 8 RX=20
-								 * interrupt=20
-								 * levels.
-								 */
+			/* writing 0 Enables all 8 RX interrupt levels */
+			writeq(0x0, &bar0->rx_traffic_mask);
 		} else if (flag =3D=3D DISABLE_INTRS) {
-			/*  Disable Rx Traffic Intrs in the general intr mask=20
-			 *  register.
+			/* =20
+			 * Disable Rx Traffic Intrs in the general intr mask=20
+			 * register.
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rx_traffic_mask);
 			temp64 =3D readq(&bar0->general_int_mask);
@@ -1075,17 +1114,19 @@
 	}
 }
=20
-/* =20
- *  Input Arguments:=20
- *   val64 - Value read from adapter status register.
- *   flag - indicates if the adapter enable bit was ever written once =
before.
- *  Return Value:=20
- *   void.
- *  Description:=20
- *   Returns whether the H/W is ready to go or not. Depending on =
whether=20
- *   adapter enable bit was written or not the comparison differs and =
the=20
- *   calling function passes the input argument flag to indicate this.
+/** =20
+ *  verify_xena_quiescence - Checks whether the H/W is ready=20
+ *  @val64 :  Value read from adapter status register.
+ *  @flag : indicates if the adapter enable bit was ever written once
+ *  before.
+ *  Description: Returns whether the H/W is ready to go or not. =
Depending
+ *  on whether adapter enable bit was written or not the comparison=20
+ *  differs and the calling function passes the input argument flag to
+ *  indicate this.
+ *  Return: 1 If xena is quiescence=20
+ *          0 If Xena is not quiescence
  */
+
 static int verify_xena_quiescence(u64 val64, int flag)
 {
 	int ret =3D 0;
@@ -1122,11 +1163,15 @@
 	return ret;
 }
=20
-/*=20
+/**
+ * fix_mac_address -  Fix for Mac addr problem on Alpha platforms
+ * @sp: Pointer to device specifc structure
+ * Description :=20
  * New procedure to clear mac address reading  problems on Alpha =
platforms
  *
  */
-void FixMacAddress(nic_t * sp)
+
+void fix_mac_address(nic_t * sp)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	u64 val64;
@@ -1138,19 +1183,20 @@
 	}
 }
=20
-/* =20
- *  Input Arguments:=20
- *  device private variable.
- *  Return Value:=20
- *  SUCCESS on success and -1 on failure.
+/**
+ *  start_nic - Turns the device on  =20
+ *  @nic : device private variable.
  *  Description:=20
- *  This function actually turns the device on. Before this=20
- *  function is called, all Registers are configured from their reset =
states=20
+ *  This function actually turns the device on. Before this  function =
is=20
+ *  called,all Registers are configured from their reset states=20
  *  and shared memory is allocated but the NIC is still quiescent. On=20
  *  calling this function, the device interrupts are cleared and the =
NIC is
  *  literally switched on by writing into the adapter control register.
+ *  Return Value:=20
+ *  SUCCESS on success and -1 on failure.
  */
-static int startNic(struct s2io_nic *nic)
+
+static int start_nic(struct s2io_nic *nic)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	struct net_device *dev =3D nic->dev;
@@ -1164,7 +1210,7 @@
 	config =3D &nic->config;
=20
 	/*  PRC Initialization and configuration */
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		writeq((u64) nic->rx_blocks[i][0].block_dma_addr,
 		       &bar0->prc_rxd0_n[i]);
=20
@@ -1173,7 +1219,8 @@
 		writeq(val64, &bar0->prc_ctrl_n[i]);
 	}
=20
-	/* Enabling MC-RLDRAM. After enabling the device, we timeout
+	/*=20
+	 * Enabling MC-RLDRAM. After enabling the device, we timeout
 	 * for around 100ms, which is approximately the time required
 	 * for the device to be ready for operation.
 	 */
@@ -1190,14 +1237,16 @@
 	val64 &=3D ~ADAPTER_ECC_EN;
 	writeq(val64, &bar0->adapter_control);
=20
-	/* Clearing any possible Link state change interrupts that=20
+	/*=20
+	 * Clearing any possible Link state change interrupts that=20
 	 * could have popped up just before Enabling the card.
 	 */
 	val64 =3D readq(&bar0->mac_rmac_err_reg);
 	if (val64)
 		writeq(val64, &bar0->mac_rmac_err_reg);
=20
-	/* Verify if the device is ready to be enabled, if so enable=20
+	/*=20
+	 * Verify if the device is ready to be enabled, if so enable=20
 	 * it.
 	 */
 	val64 =3D readq(&bar0->adapter_status);
@@ -1211,9 +1260,10 @@
 	/*  Enable select interrupts */
 	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |
 	    RX_MAC_INTR;
-	en_dis_able_NicIntrs(nic, interruptible, ENABLE_INTRS);
+	en_dis_able_nic_intrs(nic, interruptible, ENABLE_INTRS);
=20
-	/* With some switches, link might be already up at this point.
+	/*=20
+	 * With some switches, link might be already up at this point.
 	 * Because of this weird behavior, when we enable laser,=20
 	 * we may not get link. We need to handle this. We cannot=20
 	 * figure out which switch is misbehaving. So we are forced to=20
@@ -1240,82 +1290,72 @@
 	 * force link down. Since link is already up, we will get
 	 * link state change interrupt after this reset
 	 */
-	writeq(0x8007051500000000ULL, &bar0->dtx_control);
+	writeq(0x80010515001E0000ULL, &bar0->dtx_control);
 	val64 =3D readq(&bar0->dtx_control);
-	writeq(0x80070515000000E0ULL, &bar0->dtx_control);
+	udelay(50);
+	writeq(0x80010515001E00E0ULL, &bar0->dtx_control);
 	val64 =3D readq(&bar0->dtx_control);
+	udelay(50);
 	writeq(0x80070515001F00E4ULL, &bar0->dtx_control);
 	val64 =3D readq(&bar0->dtx_control);
+	udelay(50);
=20
 	return SUCCESS;
 }
=20
-/* =20
- *  Input Arguments:=20
- *   nic - device private variable.
- *  Return Value:=20
- *   void.
+/**=20
+ *  free_tx_buffers - Free all queued Tx buffers=20
+ *  @nic : device private variable.
  *  Description:=20
- *   Free all queued Tx buffers.
- */
-void freeTxBuffers(struct s2io_nic *nic)
+ *  Free all queued Tx buffers.
+ *  Return Value: void=20
+*/
+
+void free_tx_buffers(struct s2io_nic *nic)
 {
 	struct net_device *dev =3D nic->dev;
 	struct sk_buff *skb;
 	TxD_t *txdp;
 	int i, j;
-#if DEBUG_ON
-	int cnt =3D 0;
-#endif
 	mac_info_t *mac_control;
 	struct config_param *config;
+	int cnt =3D 0;
=20
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
=20
-	for (i =3D 0; i < config->TxFIFONum; i++) {
-		for (j =3D 0; j < config->TxCfg[i].FifoLen - 1; j++) {
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
+		for (j =3D 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
 			txdp =3D mac_control->txdl_start[i] +
-			    (config->MaxTxDs * j);
-
-			if (!(txdp->Control_1 & TXD_LIST_OWN_XENA)) {
-				/* If owned by host, ignore */
-				continue;
-			}
+		    		(config->max_txds * j);
 			skb =3D
 			    (struct sk_buff *) ((unsigned long) txdp->
 						Host_Control);
 			if (skb =3D=3D NULL) {
-				DBG_PRINT(ERR_DBG, "%s: NULL skb ",
-					  dev->name);
-				DBG_PRINT(ERR_DBG, "in Tx Int\n");
-				return;
+				memset(txdp, 0, sizeof(TxD_t));
+				continue;
 			}
-#if DEBUG_ON
-			cnt++;
-#endif
 			dev_kfree_skb(skb);
 			memset(txdp, 0, sizeof(TxD_t));
+			cnt++;
 		}
-#if DEBUG_ON
 		DBG_PRINT(INTR_DBG,
 			  "%s:forcibly freeing %d skbs on FIFO%d\n",
 			  dev->name, cnt, i);
-#endif
 	}
 }
=20
-/* =20
- *  Input Arguments:=20
- *   nic - device private variable.
- *  Return Value:=20
+/** =20
+ *   stop_nic -  To stop the nic =20
+ *   @nic ; device private variable.
+ *   Description:=20
+ *   This function does exactly the opposite of what the start_nic()=20
+ *   function does. This function is called to stop the device.
+ *   Return Value:
  *   void.
- *  Description:=20
- *   This function does exactly the opposite of what the startNic()=20
- *   function does. This function is called to stop=20
- *   the device.
  */
-static void stopNic(struct s2io_nic *nic)
+
+static void stop_nic(struct s2io_nic *nic)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	register u64 val64 =3D 0;
@@ -1326,24 +1366,23 @@
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
=20
-/*  Disable all interrupts */
+	/*  Disable all interrupts */
 	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |
 	    RX_MAC_INTR;
-	en_dis_able_NicIntrs(nic, interruptible, DISABLE_INTRS);
+	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
=20
-/*  Disable PRCs */
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	/*  Disable PRCs */
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		val64 =3D readq(&bar0->prc_ctrl_n[i]);
 		val64 &=3D ~((u64) PRC_CTRL_RC_ENABLED);
 		writeq(val64, &bar0->prc_ctrl_n[i]);
 	}
 }
=20
-/* =20
- *  Input Arguments:=20
- *  device private variable
- *  Return Value:=20
- *  SUCCESS on success or an appropriate -ve value on failure.
+/** =20
+ *  fill_rx_buffers - Allocates the Rx side skbs=20
+ *  @nic:  device private variable
+ *  @ring_no: ring number=20
  *  Description:=20
  *  The function allocates Rx side skbs and puts the physical
  *  address of these buffers into the RxD buffer pointers, so that the =
NIC
@@ -1354,9 +1393,13 @@
  *  3. Five buffer modes.
  *  Each mode defines how many fragments the received frame will be =
split=20
  *  up into by the NIC. The frame is split into L3 header, L4 Header,=20
- *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload =
itself=20
- *  is split into 3 fragments. As of now only single buffer mode is =
supported.
+ *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload =
itself
+ *  is split into 3 fragments. As of now only single buffer mode is
+ *  supported.
+ *   Return Value:
+ *  SUCCESS on success or an appropriate -ve value on failure.
  */
+
 int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 {
 	struct net_device *dev =3D nic->dev;
@@ -1392,7 +1435,8 @@
 		off1 =3D mac_control->rx_curr_get_info[ring_no].offset;
 		offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1) + off;
 		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;
-
+		offset =3D block_no * (MAX_RXDS_PER_BLOCK) + off;
+		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK) + off1;
 		rxdp =3D nic->rx_blocks[ring_no][block_no].
 		    block_virt_addr + off;
 		if ((offset =3D=3D offset1) && (rxdp->Host_Control)) {
@@ -1400,7 +1444,6 @@
 			DBG_PRINT(INTR_DBG, " info equated\n");
 			goto end;
 		}
-
 		if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {
 			mac_control->rx_curr_put_info[ring_no].
 			    block_index++;
@@ -1412,8 +1455,6 @@
 			off %=3D (MAX_RXDS_PER_BLOCK + 1);
 			mac_control->rx_curr_put_info[ring_no].offset =3D
 			    off;
-			/*rxdp =3D nic->rx_blocks[ring_no][block_no].
-			   block_virt_addr + off; */
 			rxdp =3D (RxD_t *) ((unsigned long) rxdp->Control_2);
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
 				  dev->name, rxdp);
@@ -1450,15 +1491,16 @@
 	return SUCCESS;
 }
=20
-/* =20
- *  Input Arguments:=20
- *  device private variable.
- *  Return Value:=20
- *  NONE.
+/**
+ *  free_rx_buffers - Frees all Rx buffers  =20
+ *  @sp: device private variable.
  *  Description:=20
  *  This function will free all Rx buffers allocated by host.
+ *  Return Value:
+ *  NONE.
  */
-static void freeRxBuffers(struct s2io_nic *sp)
+
+static void free_rx_buffers(struct s2io_nic *sp)
 {
 	struct net_device *dev =3D sp->dev;
 	int i, j, blk =3D 0, off, buf_cnt =3D 0;
@@ -1470,8 +1512,8 @@
 	mac_control =3D &sp->mac_control;
 	config =3D &sp->config;
=20
-	for (i =3D 0; i < config->RxRingNum; i++) {
-		for (j =3D 0, blk =3D 0; j < config->RxCfg[i].NumRxd; j++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
+		for (j =3D 0, blk =3D 0; j < config->rx_cfg[i].num_rxd; j++) {
 			off =3D j % (MAX_RXDS_PER_BLOCK + 1);
 			rxdp =3D sp->rx_blocks[i][blk].block_virt_addr + off;
=20
@@ -1510,18 +1552,19 @@
 	}
 }
=20
-/*
- *  Input Argument:=20
- *   dev - pointer to the device structure.
- *   budget - The number of packets that were budgeted to be processed =
during
- *   one pass through the 'Poll" function.
- *  Return value:
- *   0 on success and 1 if there are No Rx packets to be processed.
- *  Description:
- *   Comes into picture only if NAPI support has been incorporated. It =
does
- *   the same thing that rxIntrHandler does, but not in a interrupt =
context
- *   also It will process only a given number of packets.
+/**
+ * s2io_poll - Rx interrupt handler for NAPI support
+ * @dev : pointer to the device structure.
+ * @budget : The number of packets that were budgeted to be processed=20
+ * during  one pass through the 'Poll" function.
+ * Description:
+ * Comes into picture only if NAPI support has been incorporated. It =
does
+ * the same thing that rx_intr_handler does, but not in a interrupt =
context
+ * also It will process only a given number of packets.
+ * Return value:
+ * 0 on success and 1 if there are No Rx packets to be processed.
  */
+
 #ifdef CONFIG_S2IO_NAPI
 static int s2io_poll(struct net_device *dev, int *budget)
 {
@@ -1546,7 +1589,7 @@
 	val64 =3D readq(&bar0->rx_traffic_int);
 	writeq(val64, &bar0->rx_traffic_int);
=20
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		if (--pkts_to_process < 0) {
 			goto no_rx;
 		}
@@ -1589,7 +1632,7 @@
 					 HEADER_802_2_SIZE +
 					 HEADER_SNAP_SIZE,
 					 PCI_DMA_FROMDEVICE);
-			rxOsmHandler(nic, val16, rxdp, i);
+			rx_osm_handler(nic, val16, rxdp, i);
 			pkt_cnt++;
 			offset_info.offset++;
 			offset_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);
@@ -1603,38 +1646,39 @@
 	if (!pkt_cnt)
 		pkt_cnt =3D 1;
=20
-	for (i =3D 0; i < config->RxRingNum; i++)
+	for (i =3D 0; i < config->rx_ring_num; i++)
 		fill_rx_buffers(nic, i);
=20
 	dev->quota -=3D pkt_cnt;
 	*budget -=3D pkt_cnt;
 	netif_rx_complete(dev);
=20
-/* Re enable the Rx interrupts. */
-	en_dis_able_NicIntrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);
+	/* Re enable the Rx interrupts. */
+	en_dis_able_nic_intrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);
 	return 0;
=20
       no_rx:
-	for (i =3D 0; i < config->RxRingNum; i++)
+	for (i =3D 0; i < config->rx_ring_num; i++)
 		fill_rx_buffers(nic, i);
 	dev->quota -=3D pkt_cnt;
 	*budget -=3D pkt_cnt;
 	return 1;
 }
 #else
-/* =20
- *  Input Arguments:=20
- *  device private variable.
- *  Return Value:=20
- *  NONE.
+/** =20
+ *  rx_intr_handler - Rx interrupt handler
+ *  @nic: device private variable.
  *  Description:=20
- * If the interrupt is because of a received frame or if the=20
- *  receive ring contains fresh as yet un-processed frames, this =
function is
+ *  If the interrupt is because of a received frame or if the=20
+ *  receive ring contains fresh as yet un-processed frames,this =
function is
  *  called. It picks out the RxD at which place the last Rx processing =
had=20
  *  stopped and sends the skb to the OSM's Rx handler and then =
increments=20
  *  the offset.
+ *  Return Value:
+ *  NONE.
  */
-static void rxIntrHandler(struct s2io_nic *nic)
+
+static void rx_intr_handler(struct s2io_nic *nic)
 {
 	struct net_device *dev =3D (struct net_device *) nic->dev;
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
@@ -1643,24 +1687,21 @@
 	struct sk_buff *skb;
 	u16 val16, cksum;
 	register u64 val64 =3D 0;
-	int i, block_no;
+	int i, block_no, pkt_cnt =3D 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
=20
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
=20
-#if DEBUG_ON
-	nic->rxint_cnt++;
-#endif
-
-/* rx_traffic_int reg is an R1 register, hence we read and write back=20
- * the samevalue in the register to clear it.
- */
+	/*=20
+	 * rx_traffic_int reg is an R1 register, hence we read and write back=20
+	 * the samevalue in the register to clear it.
+	 */
 	val64 =3D readq(&bar0->rx_traffic_int);
 	writeq(val64, &bar0->rx_traffic_int);
=20
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		offset_info =3D mac_control->rx_curr_get_info[i];
 		block_no =3D offset_info.block_index;
 		rxdp =3D nic->rx_blocks[i][block_no].block_virt_addr +
@@ -1698,7 +1739,7 @@
 					 HEADER_802_2_SIZE +
 					 HEADER_SNAP_SIZE,
 					 PCI_DMA_FROMDEVICE);
-			rxOsmHandler(nic, val16, rxdp, i);
+			rx_osm_handler(nic, val16, rxdp, i);
 			offset_info.offset++;
 			offset_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);
 			rxdp =3D
@@ -1706,23 +1747,24 @@
 			    offset_info.offset;
 			mac_control->rx_curr_get_info[i].offset =3D
 			    offset_info.offset;
+			pkt_cnt++;
 		}
 	}
 }
 #endif
-
-/* =20
- *  Input Arguments:=20
- *  device private variable
- *  Return Value:=20
- *  NONE
+/** =20
+ *  tx_intr_handler - Transmit interrupt handler
+ *  @nic : device private variable
  *  Description:=20
  *  If an interrupt was raised to indicate DMA complete of the=20
- *  Tx packet, this function is called. It identifies the last TxD =
whose buffer
- *  was freed and frees all skbs whose data have already DMA'ed into =
the NICs
- *  internal memory.
+ *  Tx packet, this function is called. It identifies the last TxD=20
+ *  whose buffer was freed and frees all skbs whose data have already=20
+ *  DMA'ed into the NICs internal memory.
+ *  Return Value:
+ *  NONE
  */
-static void txIntrHandler(struct s2io_nic *nic)
+
+static void tx_intr_handler(struct s2io_nic *nic)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	struct net_device *dev =3D (struct net_device *) nic->dev;
@@ -1734,25 +1776,22 @@
 	u16 j, frg_cnt;
 	mac_info_t *mac_control;
 	struct config_param *config;
-#if DEBUG_ON
-	int cnt =3D 0;
-	nic->txint_cnt++;
-#endif
=20
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
=20
-	/* tx_traffic_int reg is an R1 register, hence we read and write=20
+	/*=20
+	 * tx_traffic_int reg is an R1 register, hence we read and write=20
 	 * back the samevalue in the register to clear it.
 	 */
 	val64 =3D readq(&bar0->tx_traffic_int);
 	writeq(val64, &bar0->tx_traffic_int);
=20
-	for (i =3D 0; i < config->TxFIFONum; i++) {
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
 		offset_info =3D mac_control->tx_curr_get_info[i];
 		offset_info1 =3D mac_control->tx_curr_put_info[i];
 		txdlp =3D mac_control->txdl_start[i] +
-		    (config->MaxTxDs * offset_info.offset);
+		    (config->max_txds * offset_info.offset);
 		while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
 		       (offset_info.offset !=3D offset_info1.offset) &&
 		       (txdlp->Host_Control)) {
@@ -1797,28 +1836,20 @@
 				txdlp =3D temp;
 			}
 			memset(txdlp, 0,
-			       (sizeof(TxD_t) * config->MaxTxDs));
+			       (sizeof(TxD_t) * config->max_txds));
=20
 			/* Updating the statistics block */
 			nic->stats.tx_packets++;
 			nic->stats.tx_bytes +=3D skb->len;
-#if DEBUG_ON
-			nic->txpkt_bytes +=3D skb->len;
-			cnt++;
-#endif
 			dev_kfree_skb_irq(skb);
=20
 			offset_info.offset++;
 			offset_info.offset %=3D offset_info.fifo_len + 1;
 			txdlp =3D mac_control->txdl_start[i] +
-			    (config->MaxTxDs * offset_info.offset);
+			    (config->max_txds * offset_info.offset);
 			mac_control->tx_curr_get_info[i].offset =3D
 			    offset_info.offset;
 		}
-#if DEBUG_ON
-		DBG_PRINT(INTR_DBG, "%s: freed %d Tx Pkts\n", dev->name,
-			  cnt);
-#endif
 	}
=20
 	spin_lock(&nic->tx_lock);
@@ -1827,55 +1858,53 @@
 	spin_unlock(&nic->tx_lock);
 }
=20
-/* =20
- *  Input Arguments:=20
- *  device private variable
- *  Return Value:=20
+/** =20
+ *  alarm_intr_handler - Alarm Interrrupt handler
+ *  @nic: device private variable
+ *  Description: If the interrupt was neither because of Rx packet or =
Tx=20
+ *  complete, this function is called. If the interrupt was to indicate
+ *  a loss of link, the OSM link status handler is invoked for any =
other=20
+ *  alarm interrupt the block that raised the interrupt is displayed=20
+ *  and a H/W reset is issued.
+ *  Return Value:
  *  NONE
- *  Description:=20
- *  If the interrupt was neither because of Rx packet or Tx=20
- *  complete, this function is called. If the interrupt was to indicate =
a loss
- *  of link, the OSM link status handler is invoked for any other alarm =

- *  interrupt the block that raised the interrupt is displayed and a =
H/W reset=20
- *  is issued.
- */
-static void alarmIntrHandler(struct s2io_nic *nic)
+*/
+
+static void alarm_intr_handler(struct s2io_nic *nic)
 {
 	struct net_device *dev =3D (struct net_device *) nic->dev;
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	register u64 val64 =3D 0, err_reg =3D 0;
=20
-
 	/* Handling link status change error Intr */
 	err_reg =3D readq(&bar0->mac_rmac_err_reg);
 	if (err_reg & RMAC_LINK_STATE_CHANGE_INT) {
 		schedule_work(&nic->set_link_task);
 	}
=20
-	/* Handling SERR errors by stopping device Xmit queue and forcing=20
-	 * a H/W reset.
-	 */
+	/* In case of a serious error, the device will be Reset. */
 	val64 =3D readq(&bar0->serr_source);
 	if (val64 & SERR_SOURCE_ANY) {
 		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
 		DBG_PRINT(ERR_DBG, "serious error!!\n");
 		netif_stop_queue(dev);
 	}
-/* Other type of interrupts are not being handled now,  TODO*/
+
+	/* Other type of interrupts are not being handled now,  TODO */
 }
=20
-/*
- *  Input Argument:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
+/**=20
+ *  wait_for_cmd_complete - waits for a command to complete.
+ *  @sp : private member of the device structure, which is a pointer to =
the=20
+ *  s2io_nic structure.
+ *  Description: Function that waits for a command to Write into RMAC=20
+ *  ADDR DATA registers to be completed and returns either success or=20
+ *  error depending on whether the command was complete or not.=20
  *  Return value:
  *   SUCCESS on success and FAILURE on failure.
- *  Description:
- *   Function that waits for a command to Write into RMAC ADDR DATA =
registers=20
- *   to be completed and returns either success or error depending on =
whether=20
- *   the command was complete or not.=20
  */
-int waitForCmdComplete(nic_t * sp)
+
+int wait_for_cmd_complete(nic_t * sp)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	int ret =3D FAILURE, cnt =3D 0;
@@ -1900,17 +1929,16 @@
 	return ret;
 }
=20
-/*
- *  Input Argument:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
+/**=20
+ *  s2io_reset - Resets the card.=20
+ *  @sp : private member of the device structure.
+ *  Description: Function to Reset the card. This function then also
+ *  restores the previously saved PCI configuration space registers as=20
+ *  the card reset also resets the configuration space.
  *  Return value:
- *   void.
- *  Description:
- *   Function to Reset the card. This function then also restores the =
previously
- *   saved PCI configuration space registers as the card reset also =
resets the
- *   Configration space.
+ *  void.
  */
+
 void s2io_reset(nic_t * sp)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
@@ -1920,7 +1948,8 @@
 	val64 =3D SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
=20
-	/* At this stage, if the PCI write is indeed completed, the=20
+	/*=20
+	 * At this stage, if the PCI write is indeed completed, the=20
 	 * card is reset and so is the PCI Config space of the device.=20
 	 * So a read cannot be issued at this stage on any of the=20
 	 * registers to ensure the write into "sw_reset" register
@@ -1954,29 +1983,31 @@
 	sp->device_enabled_once =3D FALSE;
 }
=20
-/*
- *  Input Argument:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
+/**
+ *  s2io_set_swapper - to set the swapper controle on the card=20
+ *  @sp : private member of the device structure,=20
+ *  pointer to the s2io_nic structure.
+ *  Description: Function to set the swapper control on the card=20
+ *  correctly depending on the 'endianness' of the system.
  *  Return value:
  *  SUCCESS on success and FAILURE on failure.
- *  Description:
- * Function to set the swapper control on the card correctly depending =
on the
- * 'endianness' of the system.
  */
+
 int s2io_set_swapper(nic_t * sp)
 {
 	struct net_device *dev =3D sp->dev;
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	u64 val64;
=20
-/*  Set proper endian settings and verify the same by reading the PIF=20
- *  Feed-back register.
- */
+	/*=20
+	 * Set proper endian settings and verify the same by reading
+	 * the PIF Feed-back register.
+	 */
 #ifdef  __BIG_ENDIAN
-/* The device by default set to a big endian format, so a big endian=20
- * driver need not set anything.
- */
+	/*=20
+	 * The device by default set to a big endian format, so a=20
+	 * big endian driver need not set anything.
+	 */
 	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
 	val64 =3D (SWAPPER_CTRL_PIF_R_FE |
 		 SWAPPER_CTRL_PIF_R_SE |
@@ -1995,9 +2026,11 @@
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
 	writeq(val64, &bar0->swapper_ctrl);
 #else
-/* Initially we enable all bits to make it accessible by the driver,
- * then we selectively enable only those bits that we want to set.
- */
+	/*=20
+	 * Initially we enable all bits to make it accessible by the
+	 * driver, then we selectively enable only those bits that=20
+	 * we want to set.
+	 */
 	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
 	val64 =3D (SWAPPER_CTRL_PIF_R_FE |
 		 SWAPPER_CTRL_PIF_R_SE |
@@ -2021,9 +2054,10 @@
 	writeq(val64, &bar0->swapper_ctrl);
 #endif
=20
-/*  Verifying if endian settings are accurate by reading a feedback
- *  register.
- */
+	/*=20
+	 * Verifying if endian settings are accurate by reading a=20
+	 * feedback register.
+	 */
 	val64 =3D readq(&bar0->pif_rd_swapper_fb);
 	if (val64 !=3D 0x0123456789ABCDEFULL) {
 		/* Endian settings are incorrect, calls for another dekko. */
@@ -2041,17 +2075,18 @@
  * Functions defined below concern the OS part of the driver *
  * ********************************************************* */
=20
-/*
- *  Input Argument:=20
- *  dev - pointer to the device structure.
- *  Return value:
- *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h
- *   file on failure.
+/** =20
+ *  s2io-open - open entry point of the driver
+ *  @dev : pointer to the device structure.
  *  Description:
  *  This function is the open entry point of the driver. It mainly =
calls a
  *  function to allocate Rx buffers and inserts them into the buffer
  *  descriptors and then enables the Rx part of the NIC.=20
+ *  Return value:
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h
+ *   file on failure.
  */
+
 int s2io_open(struct net_device *dev)
 {
 	nic_t *sp =3D dev->priv;
@@ -2060,18 +2095,21 @@
 	struct config_param *config;
=20
=20
-/* Make sure you have link off by default every time Nic is =
initialized*/
+	/*=20
+	 * Make sure you have link off by default every time=20
+	 * Nic is initialized
+	 */
 	netif_carrier_off(dev);
 	sp->last_link_state =3D LINK_DOWN;
=20
-/*  Initialize the H/W I/O registers */
-	if (initNic(sp) !=3D 0) {
+	/* Initialize the H/W I/O registers */
+	if (init_nic(sp) !=3D 0) {
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
 			  dev->name);
 		return -ENODEV;
 	}
=20
-/*  After proper initialization of H/W, register ISR */
+	/* After proper initialization of H/W, register ISR */
 	err =3D
 	    request_irq((int) sp->irq, s2io_isr, SA_SHIRQ, sp->name, dev);
 	if (err) {
@@ -2087,38 +2125,39 @@
 	}
=20
=20
-/*  Setting its receive mode */
+	/* Setting its receive mode */
 	s2io_set_multicast(dev);
=20
-/*  Initializing the Rx buffers. For now we are considering only 1 Rx =
ring
- * and initializing buffers into 1016 RxDs or 8 Rx blocks
- */
+	/*=20
+	 * Initializing the Rx buffers. For now we are considering only 1=20
+	 * Rx ring and initializing buffers into 1016 RxDs or 8 Rx blocks
+	 */
 	mac_control =3D &sp->mac_control;
 	config =3D &sp->config;
=20
-	for (i =3D 0; i < config->RxRingNum; i++) {
+	for (i =3D 0; i < config->rx_ring_num; i++) {
 		if ((ret =3D fill_rx_buffers(sp, i))) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
 				  dev->name);
 			s2io_reset(sp);
 			free_irq(dev->irq, dev);
-			freeRxBuffers(sp);
+			free_rx_buffers(sp);
 			return -ENOMEM;
 		}
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
 			  atomic_read(&sp->rx_bufs_left[i]));
 	}
=20
-/*  Enable tasklet for the device */
+	/* Enable tasklet for the device */
 	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
=20
-/*  Enable Rx Traffic and interrupts on the NIC */
-	if (startNic(sp)) {
+	/* Enable Rx Traffic and interrupts on the NIC */
+	if (start_nic(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Starting NIC failed\n", dev->name);
 		tasklet_kill(&sp->task);
 		s2io_reset(sp);
 		free_irq(dev->irq, dev);
-		freeRxBuffers(sp);
+		free_rx_buffers(sp);
 		return -ENODEV;
 	}
=20
@@ -2128,18 +2167,19 @@
 	return 0;
 }
=20
-/*
- *  Input Argument/s:=20
- *  dev - device pointer.
- *  Return value:
- *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h
- *  file on failure.
+/**
+ *  s2io_close -close entry point of the driver
+ *  @dev : device pointer.
  *  Description:
  *  This is the stop entry point of the driver. It needs to undo =
exactly
- *  whatever was done by the open entry point, thus it's usually =
referred to
- *  as the close function. Among other things this function mainly =
stops the
+ *  whatever was done by the open entry point,thus it's usually =
referred to
+ *  as the close function.Among other things this function mainly stops =
the
  *  Rx side of the NIC and frees all the Rx buffers in the Rx rings.
+ *  Return value:
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h
+ *  file on failure.
  */
+
 int s2io_close(struct net_device *dev)
 {
 	nic_t *sp =3D dev->priv;
@@ -2150,19 +2190,22 @@
 	spin_lock(&sp->isr_lock);
 	netif_stop_queue(dev);
=20
-/* disable Tx and Rx traffic on the NIC */
-	stopNic(sp);
+	/* disable Tx and Rx traffic on the NIC */
+	stop_nic(sp);
=20
 	spin_unlock(&sp->isr_lock);
=20
-/* If the device tasklet is running, wait till its done before killing =
it */
+	/*=20
+	 * If the device tasklet is running, wait till its done=20
+	 * before killing it=20
+	 */
 	while (atomic_read(&(sp->tasklet_status))) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(HZ / 10);
 	}
 	tasklet_kill(&sp->task);
=20
-/* Check if the device is Quiescent and then Reset the NIC */
+	/* Check if the device is Quiescent and then Reset the NIC */
 	do {
 		val64 =3D readq(&bar0->adapter_status);
 		if (verify_xena_quiescence(val64, sp->device_enabled_once)) {
@@ -2182,32 +2225,33 @@
 	} while (1);
 	s2io_reset(sp);
=20
-/*  Free the Registered IRQ */
+	/*  Free the Registered IRQ */
 	free_irq(dev->irq, dev);
=20
-/* Free all Tx Buffers waiting for transmission */
-	freeTxBuffers(sp);
+	/* Free all Tx Buffers waiting for transmission */
+	free_tx_buffers(sp);
=20
-/*  Free all Rx buffers allocated by host */
-	freeRxBuffers(sp);
+	/*  Free all Rx buffers allocated by host */
+	free_rx_buffers(sp);
=20
 	sp->device_close_flag =3D TRUE;	/* Device is shut down. */
=20
 	return 0;
 }
=20
-/*
- *  Input Argument/s:=20
- *  skb - the socket buffer containing the Tx data.
- *  dev - device pointer.
- *  Return value:
- *  '0' on success & 1 on failure.=20
- *  NOTE: when device cant queue the pkt, just the trans_start variable =
will
- *  not be upadted.
- *  Description:
+/**
+ *  s2io_xmit - Tx entry point of te driver
+ *  @skb : the socket buffer containing the Tx data.
+ *  @dev : device pointer.
+ *  Description :
  *  This function is the Tx entry point of the driver. S2IO NIC =
supports
  *  certain protocol assist features on Tx side, namely  CSO, S/G, LSO.
+ *  NOTE: when device cant queue the pkt,just the trans_start variable =
will
+ *  not be upadted.
+ *  Return value:
+ *  0 on success & 1 on failure.
  */
+
 int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	nic_t *sp =3D dev->priv;
@@ -2221,6 +2265,7 @@
 #endif
 	mac_info_t *mac_control;
 	struct config_param *config;
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
=20
 	mac_control =3D &sp->mac_control;
 	config =3D &sp->config;
@@ -2232,14 +2277,14 @@
 	/* Multi FIFO Tx is disabled for now. */
 	if (!queue && tx_prio) {
 		u8 x =3D (skb->data)[5];
-		queue =3D x % config->TxFIFONum;
+		queue =3D x % config->tx_fifo_num;
 	}
=20
=20
 	off =3D (u16) mac_control->tx_curr_put_info[queue].offset;
 	off1 =3D (u16) mac_control->tx_curr_get_info[queue].offset;
-	txd_len =3D mac_control->txdl_len;
-	txdp =3D mac_control->txdl_start[queue] + (config->MaxTxDs * off);
+	txd_len =3D config->max_txds;
+	txdp =3D mac_control->txdl_start[queue] + (config->max_txds * off);
=20
 	queue_len =3D mac_control->tx_curr_put_info[queue].fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
@@ -2250,7 +2295,6 @@
 		spin_unlock_irqrestore(&sp->tx_lock, flags);
 		return 0;
 	}
-
 #ifdef NETIF_F_TSO
 	mss =3D skb_shinfo(skb)->tso_size;
 	if (mss) {
@@ -2271,7 +2315,7 @@
 		     TXD_TX_CKO_UDP_EN);
 	}
=20
-	txdp->Control_2 |=3D config->TxIntrType;
+	txdp->Control_2 |=3D config->tx_intr_type;
=20
 	txdp->Control_1 |=3D (TXD_BUFFER0_SIZE(frg_len) |
 			    TXD_GATHER_CODE_FIRST);
@@ -2301,15 +2345,18 @@
 #endif
 	writeq(val64, &tx_fifo->List_Control);
=20
+	/* Perform a PCI read to flush previous writes */
+	val64 =3D readq(&bar0->general_int_status);
+
 	off++;
 	off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;
 	mac_control->tx_curr_put_info[queue].offset =3D off;
=20
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (((off + 1) % queue_len) =3D=3D off1) {
-		DBG_PRINT(TX_DBG,=20
-		  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
-		  off, off1);
+		DBG_PRINT(TX_DBG,
+			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
+			  off, off1);
 		netif_stop_queue(dev);
 	}
=20
@@ -2319,21 +2366,20 @@
 	return 0;
 }
=20
-/*
- *  Input Argument/s:=20
- *  irq: the irq of the device.
- *  dev_id: a void pointer to the dev structure of the NIC.
- *  ptregs: pointer to the registers pushed on the stack.
+/**
+ *  s2io_isr - ISR handler of the device .
+ *  @irq: the irq of the device.
+ *  @dev_id: a void pointer to the dev structure of the NIC.
+ *  @pt_regs: pointer to the registers pushed on the stack.
+ *  Description:  This function is the ISR handler of the device. It=20
+ *  identifies the reason for the interrupt and calls the relevant=20
+ *  service routines. As a contongency measure, this ISR allocates the=20
+ *  recv buffers, if their numbers are below the panic value which is
+ *  presently set to 25% of the original number of rcv buffers =
allocated.
  *  Return value:
- *  void.
- *  Description:
- *  This function is the ISR handler of the device. It identifies the =
reason=20
- *  for the interrupt and calls the relevant service routines.
- *  As a contongency measure, this ISR allocates the recv buffers, if =
their=20
- *  numbers are below the panic value which is presently set to 25% of =
the
- *  original number of rcv buffers allocated.
+ *   IRQ_HANDLED: will be returned if IRQ was handled by this routine=20
+ *   IRQ_NONE: will be returned if interrupt is not from our device
  */
-
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs =
*regs)
 {
 	struct net_device *dev =3D (struct net_device *) dev_id;
@@ -2348,7 +2394,8 @@
=20
 	spin_lock(&sp->isr_lock);
=20
-	/* Identify the cause for interrupt and call the appropriate
+	/*=20
+	 * Identify the cause for interrupt and call the appropriate
 	 * interrupt handler. Causes for the interrupt could be;
 	 * 1. Rx of packet.
 	 * 2. Tx complete.
@@ -2362,30 +2409,28 @@
 		spin_unlock(&sp->isr_lock);
 		return IRQ_NONE;
 	}
-	/* Mask the interrupts on the NIC */
+
+	/* Mask the Interrupts on the NIC. */
 	general_mask =3D readq(&bar0->general_int_mask);
 	writeq(0xFFFFFFFFFFFFFFFFULL, &bar0->general_int_mask);
=20
-#if DEBUG_ON
-	sp->int_cnt++;
-#endif
-
 	/* If Intr is because of Tx Traffic */
 	if (reason & GEN_INTR_TXTRAFFIC) {
-		txIntrHandler(sp);
+		tx_intr_handler(sp);
 	}
=20
 	/* If Intr is because of an error */
 	if (reason & (GEN_ERROR_INTR))
-		alarmIntrHandler(sp);
+		alarm_intr_handler(sp);
=20
 #ifdef CONFIG_S2IO_NAPI
 	if (reason & GEN_INTR_RXTRAFFIC) {
 		if (netif_rx_schedule_prep(dev)) {
-			en_dis_able_NicIntrs(sp, RX_TRAFFIC_INTR,
-					     DISABLE_INTRS);
-			/* We retake the snap shot of the general interrupt=20
-			 * register.
+			en_dis_able_nic_intrs(sp, RX_TRAFFIC_INTR,
+					      DISABLE_INTRS);
+			/*=20
+			 * Here we take a snap shot of the general=20
+			 * Intr Register.
 			 */
 			general_mask =3D readq(&bar0->general_int_mask);
 			__netif_rx_schedule(dev);
@@ -2394,66 +2439,72 @@
 #else
 	/* If Intr is because of Rx Traffic */
 	if (reason & GEN_INTR_RXTRAFFIC) {
-		rxIntrHandler(sp);
+		rx_intr_handler(sp);
 	}
 #endif
=20
-/* If the Rx buffer count is below the panic threshold then reallocate =
the
- * buffers from the interrupt handler itself, else schedule a tasklet =
to=20
- * reallocate the buffers.
- */
+	/*=20
+	 * If the Rx buffer count is below the panic threshold then=20
+	 * reallocate the buffers from the interrupt handler itself,=20
+	 * else schedule a tasklet to reallocate the buffers.
+	 */
 #if 1
 	{
-	int i;
+		int i;
+
+		for (i =3D 0; i < config->rx_ring_num; i++) {
+			int rxb_size =3D atomic_read(&sp->rx_bufs_left[i]);
+			int level =3D rx_buffer_level(sp, rxb_size, i);
+
+			if ((level =3D=3D PANIC) && (!TASKLET_IN_USE)) {
+				int ret;
=20
-	for (i =3D 0; i < config->RxRingNum; i++) {
-		int rxb_size =3D atomic_read(&sp->rx_bufs_left[i]);
-		int level =3D rx_buffer_level(sp, rxb_size, i);
-
-		if ((level =3D=3D PANIC) && (!TASKLET_IN_USE)) {
-			int ret;
-
-			DBG_PRINT(ERR_DBG, "%s: Rx BD hit ", dev->name);
-			DBG_PRINT(ERR_DBG, "PANIC levels\n");
-			if ((ret =3D fill_rx_buffers(sp, i)) =3D=3D -ENOMEM) {
-				DBG_PRINT(ERR_DBG, "%s:Out of memory",
+				DBG_PRINT(INTR_DBG, "%s: Rx BD hit ",
 					  dev->name);
-				DBG_PRINT(ERR_DBG, " in ISR!!\n");
-				writeq(general_mask,
-				       &bar0->general_int_mask);
-				spin_unlock(&sp->isr_lock);
-				return IRQ_HANDLED;
+				DBG_PRINT(INTR_DBG, "PANIC levels\n");
+				if ((ret =3D
+				     fill_rx_buffers(sp, i)) =3D=3D -ENOMEM) {
+					DBG_PRINT(ERR_DBG,
+						  "%s:Out of memory",
+						  dev->name);
+					DBG_PRINT(ERR_DBG, " in ISR!!\n");
+					writeq(general_mask,
+					       &bar0->general_int_mask);
+					spin_unlock(&sp->isr_lock);
+					return IRQ_HANDLED;
+				}
+				clear_bit(0,
+					  (unsigned long *) (&sp->
+							     tasklet_status));
+			} else if ((level =3D=3D LOW)
+				   && (!atomic_read(&sp->tasklet_status))) {
+				tasklet_schedule(&sp->task);
 			}
-			clear_bit(0,
-				  (unsigned long *) (&sp->tasklet_status));
-		} else if ((level =3D=3D LOW)
-			   && (!atomic_read(&sp->tasklet_status))) {
-			tasklet_schedule(&sp->task);
-		}
=20
-	}
+		}
=20
 	}
 #else
 	tasklet_schedule(&sp->task);
 #endif
=20
-	/* Unmask all the previously enabled interrupts on the NIC */
+	/* Unmask all previously enabled interrupts on the NIC. */
 	writeq(general_mask, &bar0->general_int_mask);
=20
 	spin_unlock(&sp->isr_lock);
 	return IRQ_HANDLED;
 }
=20
-/*
- *  Input Argument/s:=20
- *  dev - pointer to the device structure.
- *  Return value:
- *  pointer to the updated net_device_stats structure.
+/**
+ *  s2io_get_stats - Updates the device statistics structure.=20
+ *  @dev : pointer to the device structure.
  *  Description:
  *  This function updates the device statistics structure in the =
s2io_nic=20
  *  structure and returns a pointer to the same.
+ *  Return value:
+ *  pointer to the updated net_device_stats structure.
  */
+
 struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
 	nic_t *sp =3D dev->priv;
@@ -2463,27 +2514,28 @@
 	mac_control =3D &sp->mac_control;
 	config =3D &sp->config;
=20
-	sp->stats.tx_errors =3D mac_control->StatsInfo->tmac_any_err_frms;
-	sp->stats.rx_errors =3D mac_control->StatsInfo->rmac_drop_frms;
-	sp->stats.multicast =3D mac_control->StatsInfo->rmac_vld_mcst_frms;
+	sp->stats.tx_errors =3D mac_control->stats_info->tmac_any_err_frms;
+	sp->stats.rx_errors =3D mac_control->stats_info->rmac_drop_frms;
+	sp->stats.multicast =3D mac_control->stats_info->rmac_vld_mcst_frms;
 	sp->stats.rx_length_errors =3D
-	    mac_control->StatsInfo->rmac_long_frms;
+	    mac_control->stats_info->rmac_long_frms;
=20
 	return (&sp->stats);
 }
=20
-/*
- *  Input Argument/s:=20
- *  dev - pointer to the device structure
- *  Return value:
- *  void.
+/**
+ *  s2io_set_multicast - entry point for multicast address =
enable/disable.
+ *  @dev : pointer to the device structure
  *  Description:
  *  This function is a driver entry point which gets called by the =
kernel=20
  *  whenever multicast addresses must be enabled/disabled. This also =
gets=20
  *  called to set/reset promiscuous mode. Depending on the deivce flag, =
we
  *  determine, if multicast address must be enabled or if promiscuous =
mode
  *  is to be disabled etc.
+ *  Return value:
+ *  void.
  */
+
 static void s2io_set_multicast(struct net_device *dev)
 {
 	int i, j, prev_cnt;
@@ -2506,7 +2558,7 @@
 		    RMAC_ADDR_CMD_MEM_OFFSET(MAC_MC_ALL_MC_ADDR_OFFSET);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
-		waitForCmdComplete(sp);
+		wait_for_cmd_complete(sp);
=20
 		sp->m_cast_flg =3D 1;
 		sp->all_multi_pos =3D MAC_MC_ALL_MC_ADDR_OFFSET;
@@ -2519,7 +2571,7 @@
 		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
-		waitForCmdComplete(sp);
+		wait_for_cmd_complete(sp);
=20
 		sp->m_cast_flg =3D 0;
 		sp->all_multi_pos =3D 0;
@@ -2582,7 +2634,7 @@
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
=20
 			/* Wait for command completes */
-			if (waitForCmdComplete(sp)) {
+			if (wait_for_cmd_complete(sp)) {
 				DBG_PRINT(ERR_DBG, "%s: Adding ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
@@ -2609,7 +2661,7 @@
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
=20
 			/* Wait for command completes */
-			if (waitForCmdComplete(sp)) {
+			if (wait_for_cmd_complete(sp)) {
 				DBG_PRINT(ERR_DBG, "%s: Adding ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
@@ -2619,17 +2671,16 @@
 	}
 }
=20
-/*
- *  Input Argument/s:=20
- *  dev - pointer to the device structure.
- *  new_mac - a uchar pointer to the new mac address which is to be =
set.
- *  Return value:
- *  SUCCESS on success and an appropriate (-)ve integer as defined in =
errno.h
- *  file on failure.
- *  Description:
- *  This procedure will program the Xframe to receive frames with new
- *  Mac Address
+/**
+ *  s2io_set_mac_addr - Programs the Xframe mac address=20
+ *  @dev : pointer to the device structure.
+ *  @addr: a uchar pointer to the new mac address which is to be set.
+ *  Description : This procedure will program the Xframe to receive=20
+ *  frames with new Mac Address
+ *  Return value: SUCCESS on success and an appropriate (-)ve integer=20
+ *  as defined in errno.h file on failure.
  */
+
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr)
 {
 	nic_t *sp =3D dev->priv;
@@ -2655,7 +2706,7 @@
 	    RMAC_ADDR_CMD_MEM_OFFSET(0);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 	/* Wait till command completes */
-	if (waitForCmdComplete(sp)) {
+	if (wait_for_cmd_complete(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: set_mac_addr failed\n", dev->name);
 		return FAILURE;
 	}
@@ -2663,18 +2714,18 @@
 	return SUCCESS;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  info - pointer to the structure with parameters given by ethtool to =
set
- *  link information.
- * Return value:
- *  0 on success.
+/**
+ * s2io_ethtool_sset - Sets different link parameters.=20
+ * @sp : private member of the device structure, which is a pointer to =
the  * s2io_nic structure.
+ * @info: pointer to the structure with parameters given by ethtool to =
set
+ * link information.
  * Description:
- *  The function sets different link parameters provided by the user =
onto=20
- *  the NIC.
- */
+ * The function sets different link parameters provided by the user =
onto=20
+ * the NIC.
+ * Return value:
+ * 0 on success.
+*/
+
 static int s2io_ethtool_sset(struct net_device *dev,
 			     struct ethtool_cmd *info)
 {
@@ -2690,17 +2741,18 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  info - pointer to the structure with parameters given by ethtool to =
return
- *  link information.
- * Return value:
- *  void
+/**
+ * s2io_ethtol_gset - Return link specific information.=20
+ * @sp : private member of the device structure, pointer to the
+ *      s2io_nic structure.
+ * @info : pointer to the structure with parameters given by ethtool
+ * to return link information.
  * Description:
- *  Returns link specefic information like speed, duplex etc.. to =
ethtool.
+ * Returns link specific information like speed, duplex etc.. to =
ethtool.
+ * Return value :
+ * return 0 on success.
  */
+
 int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 {
 	nic_t *sp =3D dev->priv;
@@ -2721,17 +2773,18 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  info - pointer to the structure with parameters given by ethtool to =
return
- *  driver information.
+/**
+ * s2io_ethtool_gdrvinfo - Returns driver specific information.=20
+ * @sp : private member of the device structure, which is a pointer to =
the=20
+ * s2io_nic structure.
+ * @info : pointer to the structure with parameters given by ethtool to
+ * return driver information.
+ * Description:
+ * Returns driver specefic information like name, version etc.. to =
ethtool.
  * Return value:
  *  void
- * Description:
- *  Returns driver specefic information like name, version etc.. to =
ethtool.
  */
+
 static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 				  struct ethtool_drvinfo *info)
 {
@@ -2748,19 +2801,20 @@
 	info->n_stats =3D S2IO_STAT_LEN;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  regs - pointer to the structure with parameters given by ethtool =
for=20
+/**
+ *  s2io_ethtool_gregs - dumps the entire space of Xfame into the =
buffer.
+ *  @sp: private member of the device structure, which is a pointer to =
the=20
+ *  s2io_nic structure.
+ *  @regs : pointer to the structure with parameters given by ethtool =
for=20
  *  dumping the registers.
- *  reg_space - The input argumnet into which all the registers are =
dumped.
- * Return value:
- *  void
- * Description:
- *  Dumps the entire register space of xFrame NIC into the user given =
buffer=20
- *  area.
- */
+ *  @reg_space: The input argumnet into which all the registers are =
dumped.
+ *  Description:
+ *  Dumps the entire register space of xFrame NIC into the user given
+ *  buffer area.
+ * Return value :
+ * void .
+*/
+
 static void s2io_ethtool_gregs(struct net_device *dev,
 			       struct ethtool_regs *regs, void *space)
 {
@@ -2778,17 +2832,15 @@
 	}
 }
=20
-/*
- * Input Argument/s:=20
- *  data - address of the private member of the device structure, which =

+/**
+ *  s2io_phy_id  - timer function that alternates adapter LED.
+ *  @data : address of the private member of the device structure, =
which=20
  *  is a pointer to the s2io_nic structure, provided as an u32.
- * Return value:
- *  void
- * Description:
- *  This is actually the timer function that alternates the adapter LED =
bit
- *  of the adapter control bit to set/reset every time on invocation.
- *  The timer is set for 1/2 a second, hence tha NIC blinks once every =
second.
- */
+ * Description: This is actually the timer function that alternates the =

+ * adapter LED bit of the adapter control bit to set/reset every time =
on=20
+ * invocation. The timer is set for 1/2 a second, hence tha NIC blinks=20
+ *  once every second.
+*/
 static void s2io_phy_id(unsigned long data)
 {
 	nic_t *sp =3D (nic_t *) data;
@@ -2810,20 +2862,21 @@
 	mod_timer(&sp->id_timer, jiffies + HZ / 2);
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  id - pointer to the structure with identification parameters given =
by=20
- *  ethtool.
+/**
+ * s2io_ethtool_idnic - To physically identify the nic on the system.
+ * @sp : private member of the device structure, which is a pointer to =
the
+ * s2io_nic structure.
+ * @id : pointer to the structure with identification parameters given =
by=20
+ * ethtool.
+ * Description: Used to physically identify the NIC on the system.
+ * The Link LED will blink for a time specified by the user for=20
+ * identification.
+ * NOTE: The Link has to be Up to be able to blink the LED. Hence=20
+ * identification is possible only if it's link is up.
  * Return value:
- *  int , returns '0' on success
- * Description:
- *  Used to physically identify the NIC on the system. The Link LED =
will blink
- *  for a time specified by the user for identification.
- *  NOTE: The Link has to be Up to be able to blink the LED. Hence=20
- *  identification is possible only if it's link is up.
+ * int , returns 0 on success
  */
+
 static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 {
 	u64 val64 =3D 0;
@@ -2856,15 +2909,14 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  ep - pointer to the structure with pause parameters given by =
ethtool.
+/**
+ * s2io_ethtool_getpause_data -Pause frame frame generation and =
reception.
+ * @sp : private member of the device structure, which is a pointer to =
the  * s2io_nic structure.
+ * @ep : pointer to the structure with pause parameters given by =
ethtool.
+ * Description:
+ * Returns the Pause frame generation and reception capability of the =
NIC.
  * Return value:
  *  void
- * Description:
- *  Returns the Pause frame generation and reception capability of the =
NIC.
  */
 static void s2io_ethtool_getpause_data(struct net_device *dev,
 				       struct ethtool_pauseparam *ep)
@@ -2881,17 +2933,18 @@
 	ep->autoneg =3D FALSE;
 }
=20
-/*
- * Input Argument/s:=20
- * sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- * ep - pointer to the structure with pause parameters given by =
ethtool.
- * Return value:
- * int, returns '0' on Success
+/**
+ * s2io_ethtool-setpause_data -  set/reset pause frame generation.
+ * @sp : private member of the device structure, which is a pointer to =
the=20
+ *      s2io_nic structure.
+ * @ep : pointer to the structure with pause parameters given by =
ethtool.
  * Description:
- * It can be used to set or reset Pause frame generation or reception =
support=20
- * of the NIC.
+ * It can be used to set or reset Pause frame generation or reception
+ * support of the NIC.
+ * Return value:
+ * int, returns 0 on Success
  */
+
 int s2io_ethtool_setpause_data(struct net_device *dev,
 			       struct ethtool_pauseparam *ep)
 {
@@ -2912,21 +2965,24 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  off - offset at which the data must be written
- * Return value:
- *  -1 on failure and the value read from the Eeprom if successful.
+/**
+ * read_eeprom - reads 4 bytes of data from user given offset.
+ * @sp : private member of the device structure, which is a pointer to =
the=20
+ *      s2io_nic structure.
+ * @off : offset at which the data must be written
+ * @data : Its an output parameter where the data read at the given
+ * 	offset is stored.
  * Description:
- *  Will read 4 bytes of data from the user given offset and return the =

- *  read data.
+ * Will read 4 bytes of data from the user given offset and return the=20
+ * read data.
  * NOTE: Will allow to read only part of the EEPROM visible through the
- * 	 I2C bus.
+ *   I2C bus.
+ * Return value:
+ *  -1 on failure and 0 on success.
  */
+
 #define S2IO_DEV_ID		5
-static u32 readEeprom(nic_t * sp, int off)
+static u32 read_eeprom(nic_t * sp, int off)
 {
 	u32 data =3D -1, exit_cnt =3D 0;
 	u64 val64;
@@ -2951,21 +3007,22 @@
 	return data;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  off - offset at which the data must be written
- *  data - The data that is to be written
- *  cnt - Number of bytes of the data that are actually to be written =
into=20
+/**
+ *  write_eeprom - actually writes the relevant part of the data value.
+ *  @sp : private member of the device structure, which is a pointer to =
the
+ *       s2io_nic structure.
+ *  @off : offset at which the data must be written
+ *  @data : The data that is to be written
+ *  @cnt : Number of bytes of the data that are actually to be written =
into=20
  *  the Eeprom. (max of 3)
- * Return value:
- *  '0' on success, -1 on failure.
  * Description:
  *  Actually writes the relevant part of the data value into the Eeprom
  *  through the I2C bus.
+ * Return value:
+ *  0 on success, -1 on failure.
  */
-static int writeEeprom(nic_t * sp, int off, u32 data, int cnt)
+
+static int write_eeprom(nic_t * sp, int off, u32 data, int cnt)
 {
 	int exit_cnt =3D 0, ret =3D -1;
 	u64 val64;
@@ -2991,39 +3048,19 @@
 	return ret;
 }
=20
-/*=20
- * A helper function used to invert the 4 byte u32 data field
- * byte by byte. This will be used by the Read Eeprom function
- * for display purposes.
- */
-u32 inv(u32 data)
-{
-	static u32 ret =3D 0;
-
-	if (data) {
-		u8 c =3D data;
-		ret =3D ((ret << 8) + c);
-		data >>=3D 8;
-		inv(data);
-	}
-
-	return ret;
-}
-
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  eeprom - pointer to the user level structure provided by ethtool,=20
- *   containing all relevant information.
- *  data_buf - user defined value to be written into Eeprom.
- * Return value:
- *  int  '0' on success
- * Description:
- *  Reads the values stored in the Eeprom at given offset for a given =
length.
- *  Stores these values int the input argument data buffer 'data_buf' =
and
- *  returns these to the caller (ethtool.)
+/**
+ *  s2io_ethtool_geeprom  - reads the value stored in the Eeprom.
+ *  @sp : private member of the device structure, which is a pointer to =
the *       s2io_nic structure.
+ *  @eeprom : pointer to the user level structure provided by ethtool,=20
+ *  containing all relevant information.
+ *  @data_buf : user defined value to be written into Eeprom.
+ *  Description: Reads the values stored in the Eeprom at given offset
+ *  for a given length. Stores these values int the input argument data
+ *  buffer 'data_buf' and returns these to the caller (ethtool.)
+ *  Return value:
+ *  int  0 on success
  */
+
 int s2io_ethtool_geeprom(struct net_device *dev,
 			 struct ethtool_eeprom *eeprom, u8 * data_buf)
 {
@@ -3036,30 +3073,31 @@
 		eeprom->len =3D XENA_EEPROM_SPACE - eeprom->offset;
=20
 	for (i =3D 0; i < eeprom->len; i +=3D 4) {
-		data =3D readEeprom(sp, eeprom->offset + i);
+		data =3D read_eeprom(sp, eeprom->offset + i);
 		if (data < 0) {
 			DBG_PRINT(ERR_DBG, "Read of EEPROM failed\n");
 			return -EFAULT;
 		}
-		valid =3D inv(data);
+		valid =3D INV(data);
 		memcpy((data_buf + i), &valid, 4);
 	}
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  eeprom - pointer to the user level structure provided by ethtool,=20
- *   containing all relevant information.
- *  data_buf - user defined value to be written into Eeprom.
- * Return value:
- *  '0' on success, -EFAULT on failure.
- * Description:
+/**
+ *  s2io_ethtool_seeprom - tries to write the user provided value in =
Eeprom
+ *  @sp : private member of the device structure, which is a pointer to =
the
+ *  s2io_nic structure.
+ *  @eeprom : pointer to the user level structure provided by ethtool,=20
+ *  containing all relevant information.
+ *  @data_buf ; user defined value to be written into Eeprom.
+ *  Description:
  *  Tries to write the user provided value in the Eeprom, at the offset
  *  given by the user.
+ *  Return value:
+ *  0 on success, -EFAULT on failure.
  */
+
 static int s2io_ethtool_seeprom(struct net_device *dev,
 				struct ethtool_eeprom *eeprom,
 				u8 * data_buf)
@@ -3083,7 +3121,7 @@
 		} else
 			valid =3D data;
=20
-		if (writeEeprom(sp, (eeprom->offset + cnt), valid, 0)) {
+		if (write_eeprom(sp, (eeprom->offset + cnt), valid, 0)) {
 			DBG_PRINT(ERR_DBG,
 				  "ETHTOOL_WRITE_EEPROM Err: Cannot ");
 			DBG_PRINT(ERR_DBG,
@@ -3097,19 +3135,20 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  data - variable that returns the result of each of the test =
conducted by=20
- *  	the driver.
- * Return value:
- *  '0' on success.
+/**
+ * s2io_register_test - reads and writes into all clock domains.=20
+ * @sp : private member of the device structure, which is a pointer to =
the=20
+ * s2io_nic structure.
+ * @data : variable that returns the result of each of the test =
conducted b
+ * by the driver.
  * Description:
- *  Read and write into all clock domains. The NIC has 3 clock domains,
- *  see that registers in all the three regions are accessible.
+ * Read and write into all clock domains. The NIC has 3 clock domains,
+ * see that registers in all the three regions are accessible.
+ * Return value:
+ * 0 on success.
  */
-static int s2io_registerTest(nic_t * sp, uint64_t * data)
+
+static int s2io_register_test(nic_t * sp, uint64_t * data)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	u64 val64 =3D 0;
@@ -3159,88 +3198,90 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  data - variable that returns the result of each of the test =
conducted by=20
- *  	the driver.
- * Return value:
- *  '0' on success.
+/**
+ * s2io_eeprom_test - to verify that EEprom in the xena can be =
programmed.=20
+ * @sp : private member of the device structure, which is a pointer to =
the
+ * s2io_nic structure.
+ * @data:variable that returns the result of each of the test conducted =
by
+ * the driver.
  * Description:
- *  Verify that EEPROM in the xena can be programmed using I2C_CONTROL=20
- *  register.
+ * Verify that EEPROM in the xena can be programmed using I2C_CONTROL=20
+ * register.
+ * Return value:
+ * 0 on success.
  */
-static int s2io_eepromTest(nic_t * sp, uint64_t * data)
+
+static int s2io_eeprom_test(nic_t * sp, uint64_t * data)
 {
 	int fail =3D 0, ret_data;
=20
 	/* Test Write Error at offset 0 */
-	if (!writeEeprom(sp, 0, 0, 3))
+	if (!write_eeprom(sp, 0, 0, 3))
 		fail =3D 1;
=20
 	/* Test Write at offset 4f0 */
-	if (writeEeprom(sp, 0x4F0, 0x01234567, 3))
+	if (write_eeprom(sp, 0x4F0, 0x01234567, 3))
 		fail =3D 1;
-	if ((ret_data =3D readEeprom(sp, 0x4f0)) < 0)
+	if ((ret_data =3D read_eeprom(sp, 0x4F0)) < 0)
 		fail =3D 1;
=20
 	if (ret_data !=3D 0x01234567)
 		fail =3D 1;
=20
 	/* Reset the EEPROM data go FFFF */
-	writeEeprom(sp, 0x4F0, 0xFFFFFFFF, 3);
+	write_eeprom(sp, 0x4F0, 0xFFFFFFFF, 3);
=20
 	/* Test Write Request Error at offset 0x7c */
-	if (!writeEeprom(sp, 0x07C, 0, 3))
+	if (!write_eeprom(sp, 0x07C, 0, 3))
 		fail =3D 1;
=20
 	/* Test Write Request at offset 0x7fc */
-	if (writeEeprom(sp, 0x7FC, 0x01234567, 3))
+	if (write_eeprom(sp, 0x7FC, 0x01234567, 3))
 		fail =3D 1;
-	if ((ret_data =3D readEeprom(sp, 0x7FC)) < 0)
+	if ((ret_data =3D read_eeprom(sp, 0x7FC)) < 0)
 		fail =3D 1;
=20
 	if (ret_data !=3D 0x01234567)
 		fail =3D 1;
=20
 	/* Reset the EEPROM data go FFFF */
-	writeEeprom(sp, 0x7FC, 0xFFFFFFFF, 3);
+	write_eeprom(sp, 0x7FC, 0xFFFFFFFF, 3);
=20
 	/* Test Write Error at offset 0x80 */
-	if (!writeEeprom(sp, 0x080, 0, 3))
+	if (!write_eeprom(sp, 0x080, 0, 3))
 		fail =3D 1;
=20
 	/* Test Write Error at offset 0xfc */
-	if (!writeEeprom(sp, 0x0FC, 0, 3))
+	if (!write_eeprom(sp, 0x0FC, 0, 3))
 		fail =3D 1;
=20
 	/* Test Write Error at offset 0x100 */
-	if (!writeEeprom(sp, 0x100, 0, 3))
+	if (!write_eeprom(sp, 0x100, 0, 3))
 		fail =3D 1;
=20
 	/* Test Write Error at offset 4ec */
-	if (!writeEeprom(sp, 0x4EC, 0, 3))
+	if (!write_eeprom(sp, 0x4EC, 0, 3))
 		fail =3D 1;
=20
 	*data =3D fail;
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  data - variable that returns the result of each of the test =
conducted by=20
- *  	the driver.
- * Return value:
- *  '0' on success and -1 on failure.
+/**
+ * s2io_bist_test - invokes the MemBist test of the card .
+ * @sp : private member of the device structure, which is a pointer to =
the=20
+ * s2io_nic structure.
+ * @data:variable that returns the result of each of the test conducted =
by=20
+ * the driver.
  * Description:
- *  This invokes the MemBist test of the card. We give around
- *  2 secs time for the Test to complete. If it's still not complete
- *  within this peiod, we consider that the test failed.=20
+ * This invokes the MemBist test of the card. We give around
+ * 2 secs time for the Test to complete. If it's still not complete
+ * within this peiod, we consider that the test failed.=20
+ * Return value:
+ * 0 on success and -1 on failure.
  */
-static int s2io_bistTest(nic_t * sp, uint64_t * data)
+
+static int s2io_bist_test(nic_t * sp, uint64_t * data)
 {
 	u8 bist =3D 0;
 	int cnt =3D 0, ret =3D -1;
@@ -3264,19 +3305,20 @@
 	return ret;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  data - variable that returns the result of each of the test =
conducted by=20
- *  	the driver.
- * Return value:
- *  '0' on success.
+/**
+ * s2io-link_test - verifies the link state of the nic =20
+ * @sp ; private member of the device structure, which is a pointer to =
the=20
+ * s2io_nic structure.
+ * @data: variable that returns the result of each of the test =
conducted by
+ * the driver.
  * Description:
- *  The function verifies the link state of the NIC and updates the =
input=20
- *  argument 'data' appropriately.
+ * The function verifies the link state of the NIC and updates the =
input=20
+ * argument 'data' appropriately.
+ * Return value:
+ * 0 on success.
  */
-static int s2io_linkTest(nic_t * sp, uint64_t * data)
+
+static int s2io_link_test(nic_t * sp, uint64_t * data)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	u64 val64;
@@ -3288,19 +3330,20 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  data - variable that returns the result of each of the test =
conducted by=20
- *  	the driver.
- * Return value:
- *  '0' on success.
+/**
+ * s2io_rldram_test - offline test for access to the RldRam chip on the =
NIC=20
+ * @sp - private member of the device structure, which is a pointer to =
the =20
+ * s2io_nic structure.
+ * @data - variable that returns the result of each of the test=20
+ * conducted by the driver.
  * Description:
  *  This is one of the offline test that tests the read and write=20
  *  access to the RldRam chip on the NIC.
+ * Return value:
+ *  0 on success.
  */
-static int s2io_rldramTest(nic_t * sp, uint64_t * data)
+
+static int s2io_rldram_test(nic_t * sp, uint64_t * data)
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	u64 val64;
@@ -3395,20 +3438,21 @@
 	return 0;
 }
=20
-/*
- * Input Argument/s:=20
- *  sp - private member of the device structure, which is a pointer to =
the=20
- *   	s2io_nic structure.
- *  ethtest - pointer to a ethtool command specific structure that will =
be
- *  	returned to the user.
- *  data - variable that returns the result of each of the test =
conducted by=20
- *  	the driver.
- * Return value:
- *  SUCCESS on success and an appropriate -1 on failure.
+/**
+ *  s2io_ethtool_test - conducts 6 tsets to determine the health of =
card.
+ *  @sp : private member of the device structure, which is a pointer to =
the
+ *  s2io_nic structure.
+ *  @ethtest : pointer to a ethtool command specific structure that =
will be
+ *  returned to the user.
+ *  @data : variable that returns the result of each of the test=20
+ * conducted by the driver.
  * Description:
  *  This function conducts 6 tests ( 4 offline and 2 online) to =
determine
- *  	the health of the card.
+ *  the health of the card.
+ * Return value:
+ *  void
  */
+
 static void s2io_ethtool_test(struct net_device *dev,
 			      struct ethtool_test *ethtest,
 			      uint64_t * data)
@@ -3424,22 +3468,22 @@
 		} else
 			s2io_set_swapper(sp);
=20
-		if (s2io_registerTest(sp, &data[0]))
+		if (s2io_register_test(sp, &data[0]))
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;
=20
 		s2io_reset(sp);
 		s2io_set_swapper(sp);
=20
-		if (s2io_rldramTest(sp, &data[3]))
+		if (s2io_rldram_test(sp, &data[3]))
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;
=20
 		s2io_reset(sp);
 		s2io_set_swapper(sp);
=20
-		if (s2io_eepromTest(sp, &data[1]))
+		if (s2io_eeprom_test(sp, &data[1]))
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;
=20
-		if (s2io_bistTest(sp, &data[4]))
+		if (s2io_bist_test(sp, &data[4]))
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;
=20
 		if (orig_state)
@@ -3459,7 +3503,7 @@
 			data[4] =3D -1;
 		}
=20
-		if (s2io_linkTest(sp, &data[2]))
+		if (s2io_link_test(sp, &data[2]))
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;
=20
 		data[0] =3D 0;
@@ -3475,7 +3519,7 @@
 {
 	int i =3D 0;
 	nic_t *sp =3D dev->priv;
-	StatInfo_t *stat_info =3D sp->mac_control.StatsInfo;
+	StatInfo_t *stat_info =3D sp->mac_control.stats_info;
=20
 	tmp_stats[i++] =3D stat_info->tmac_frms;
 	tmp_stats[i++] =3D stat_info->tmac_data_octets;
@@ -3597,36 +3641,37 @@
 	.get_ethtool_stats =3D s2io_get_ethtool_stats
 };
=20
-/*
- *  Input Argument/s:=20
- *  dev -   Device pointer.
- *  ifr -   An IOCTL specefic structure, that can contain a pointer to
- *      a proprietary structure used to pass information to the driver.
- *  cmd -   This is used to distinguish between the different commands =
that
- *      can be passed to the IOCTL functions.
- *  Return value:
- *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h
- *  file on failure.
+/**
+ *  s2io_ioctl - Entry point for the Ioctl=20
+ *  @dev :  Device pointer.
+ *  @ifr :  An IOCTL specefic structure, that can contain a pointer to
+ *  a proprietary structure used to pass information to the driver.
+ *  @cmd :  This is used to distinguish between the different commands =
that
+ *  can be passed to the IOCTL functions.
  *  Description:
  *  This function has support for ethtool, adding multiple MAC =
addresses on=20
  *  the NIC and some DBG commands for the util tool.
+ *  Return value:
+ *  Currently the IOCTL supports no operations, hence by default this
+ *  function returns OP NOT SUPPORTED value.
  */
+
 int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	return -EOPNOTSUPP;
 }
=20
-/*
- *  Input Argument/s:=20
- *   dev - device pointer.
- *   new_mtu - the new MTU size for the device.
+/**
+ *  s2io_change_mtu - entry point to change MTU size for the device.
+ *   @dev : device pointer.
+ *   @new_mtu : the new MTU size for the device.
+ *   Description: A driver entry point to change MTU size for the =
device.
+ *   Before changing the MTU the device must be stopped.
  *  Return value:
- *   '0' on success and an appropriate (-)ve integer as defined in =
errno.h
+ *   0 on success and an appropriate (-)ve integer as defined in =
errno.h
  *   file on failure.
- *  Description:
- *   A driver entry point to change MTU size for the device. Before =
changing
- *   the MTU the device must be stopped.
  */
+
 int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	nic_t *sp =3D dev->priv;
@@ -3645,7 +3690,7 @@
 		return -EPERM;
 	}
=20
-/* Set the new MTU into the PYLD register of the NIC */
+	/* Set the new MTU into the PYLD register of the NIC */
 	val64 =3D new_mtu;
 	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
=20
@@ -3654,18 +3699,19 @@
 	return 0;
 }
=20
-/*
- *  Input Argument/s:=20
- *  dev_adr - address of the device structure in dma_addr_t format.
- *  Return value:
- *  void.
+/**
+ *  s2io_tasklet - Bottom half of the ISR.
+ *  @dev_adr : address of the device structure in dma_addr_t format.
  *  Description:
  *  This is the tasklet or the bottom half of the ISR. This is
  *  an extension of the ISR which is scheduled by the scheduler to be =
run=20
  *  when the load on the CPU is low. All low priority tasks of the ISR =
can
  *  be pushed into the tasklet. For now the tasklet is used only to=20
  *  replenish the Rx buffers in the Rx buffer descriptors.
+ *  Return value:
+ *  void.
  */
+
 static void s2io_tasklet(unsigned long dev_addr)
 {
 	struct net_device *dev =3D (struct net_device *) dev_addr;
@@ -3678,29 +3724,30 @@
 	config =3D &sp->config;
=20
 	if (!TASKLET_IN_USE) {
-		for (i =3D 0; i < config->RxRingNum; i++) {
+		for (i =3D 0; i < config->rx_ring_num; i++) {
 			ret =3D fill_rx_buffers(sp, i);
 			if (ret =3D=3D -ENOMEM) {
 				DBG_PRINT(ERR_DBG, "%s: Out of ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "memory in tasklet\n");
-				return;
+				break;
 			} else if (ret =3D=3D -EFILL) {
 				DBG_PRINT(ERR_DBG,
 					  "%s: Rx Ring %d is full\n",
 					  dev->name, i);
-				return;
+				break;
 			}
 		}
 		clear_bit(0, (unsigned long *) (&sp->tasklet_status));
 	}
 }
=20
-
-/*
- * Description:
- *=20
+/**
+ * s2io_set_link - Set the LInk status
+ * @data: long pointer to device private structue
+ * Description: Sets the link status for the adapter
  */
+
 static void s2io_set_link(unsigned long data)
 {
 	nic_t *nic =3D (nic_t *) data;
@@ -3708,7 +3755,8 @@
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	register u64 val64, err_reg;
=20
-	/* Allow a small delay for the NICs self initiated=20
+	/*=20
+	 * Allow a small delay for the NICs self initiated=20
 	 * cleanup to complete.
 	 */
 	set_current_state(TASK_UNINTERRUPTIBLE);
@@ -3716,7 +3764,7 @@
=20
 	val64 =3D readq(&bar0->adapter_status);
 	if (verify_xena_quiescence(val64, nic->device_enabled_once)) {
-		/* Acknowledge interrupt and clear the R1 register */
+		/* Acknowledge Intr and clear R1 register. */
 		err_reg =3D readq(&bar0->mac_rmac_err_reg);
 		writeq(err_reg, &bar0->mac_rmac_err_reg);
=20
@@ -3748,13 +3796,16 @@
 	}
 }
=20
-/*
+/**=20
+ * s2io_restart_nic - Resets the NIC.
+ * @data : long pointer to the device private structure
  * Description:
  * This function is scheduled to be run by the s2io_tx_watchdog
  * function after 0.5 secs to reset the NIC. The idea is to reduce=20
  * the run time of the watch dog routine which is run holding a
  * spin lock.
  */
+
 static void s2io_restart_nic(unsigned long data)
 {
 	struct net_device *dev =3D (struct net_device *) data;
@@ -3767,18 +3818,19 @@
 		  "%s: was reset by Tx watchdog timer.\n", dev->name);
 }
=20
-/*
- *  Input Argument/s:=20
- *  dev - device pointer.
- *  Return value:
- *  void
+/**=20
+ *  s2io_tx_watchdog - Watchdog for transmit side.=20
+ *  @dev : Pointer to net device structure
  *  Description:
  *  This function is triggered if the Tx Queue is stopped
  *  for a pre-defined amount of time when the Interface is still up.
  *  If the Interface is jammed in such a situation, the hardware is
  *  reset (by s2io_close) and restarted again (by s2io_open) to
  *  overcome any problem that might have been caused in the hardware.
+ *  Return value:
+ *  void
  */
+
 static void s2io_tx_watchdog(struct net_device *dev)
 {
 	nic_t *sp =3D dev->priv;
@@ -3788,25 +3840,24 @@
 	}
 }
=20
-/*
- *  Input Argument/s:=20
- *   sp - private member of the device structure, which is a pointer to =
the=20
- *   s2io_nic structure.
- *   skb - the socket buffer pointer.
- *   len - length of the packet
- *   cksum - FCS checksum of the frame.
- *  ring_no - the ring from which this RxD was extracted.
- *  Return value:
- *   SUCCESS on success and -1 on failure.
- *  Description:=20
- *   This function is called by the Tx interrupt serivce routine to =
perform=20
+/**
+ *   rx_osm_handler - To perform some OS related operations on SKB.
+ *   @sp: private member of the device structure,pointer to s2io_nic =
structure.
+ *   @skb : the socket buffer pointer.
+ *   @len : length of the packet
+ *   @cksum : FCS checksum of the frame.
+ *   @ring_no : the ring from which this RxD was extracted.
+ *   Description:=20
+ *   This function is called by the Tx interrupt serivce routine to =
perform
  *   some OS related operations on the SKB before passing it to the =
upper
  *   layers. It mainly checks if the checksum is OK, if so adds it to =
the
  *   SKBs cksum variable, increments the Rx packet count and passes the =
SKB
  *   to the upper layer. If the checksum is wrong, it increments the Rx
  *   packet error count, frees the SKB and returns error.
+ *   Return value:
+ *   SUCCESS on success and -1 on failure.
  */
-static int rxOsmHandler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no)
+static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no)
 {
 	struct net_device *dev =3D (struct net_device *) sp->dev;
 	struct sk_buff *skb =3D
@@ -3817,7 +3868,8 @@
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {
 		l4_csum =3D RXD_GET_L4_CKSUM(rxdp->Control_1);
 		if ((l3_csum =3D=3D L3_CKSUM_OK) && (l4_csum =3D=3D L4_CKSUM_OK)) {
-			/* NIC verifies if the Checksum of the received
+			/*=20
+			 * NIC verifies if the Checksum of the received
 			 * frame is Ok or not and accordingly returns
 			 * a flag in the RxD.
 			 */
@@ -3844,25 +3896,21 @@
 #endif
=20
 	dev->last_rx =3D jiffies;
-#if DEBUG_ON
-	sp->rxpkt_cnt++;
-#endif
 	sp->rx_pkt_count++;
 	sp->stats.rx_packets++;
 	sp->stats.rx_bytes +=3D len;
-	sp->rxpkt_bytes +=3D len;
=20
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
 	rxdp->Host_Control =3D 0;
 	return SUCCESS;
 }
=20
-int check_for_txSpace(nic_t * sp)
+int check_for_tx_space(nic_t * sp)
 {
 	u32 put_off, get_off, queue_len;
 	int ret =3D TRUE, i;
=20
-	for (i =3D 0; i < sp->config.TxFIFONum; i++) {
+	for (i =3D 0; i < sp->config.tx_fifo_num; i++) {
 		queue_len =3D sp->mac_control.tx_curr_put_info[i].fifo_len
 		    + 1;
 		put_off =3D sp->mac_control.tx_curr_put_info[i].offset;
@@ -3876,18 +3924,19 @@
 	return ret;
 }
=20
-/*
-*  Input Argument/s:=20
-*   sp - private member of the device structure, which is a pointer to =
the=20
-*   s2io_nic structure.
-*   link - inidicates whether link is UP/DOWN.
-*  Return value:
-*   void.
-*  Description:
-*   This function stops/starts the Tx queue depending on whether the =
link
-*   status of the NIC is is down or up. This is called by the Alarm =
interrupt=20
-*  handler whenever a link change interrupt comes up.=20
-*/
+/**
+ *  s2io_link - stops/starts the Tx queue.
+ *  @sp : private member of the device structure, which is a pointer to =
the
+ *  s2io_nic structure.
+ *  @link : inidicates whether link is UP/DOWN.
+ *  Description:
+ *  This function stops/starts the Tx queue depending on whether the =
link
+ *  status of the NIC is is down or up. This is called by the Alarm=20
+ *  interrupt handler whenever a link change interrupt comes up.=20
+ *  Return value:
+ *  void.
+ */
+
 void s2io_link(nic_t * sp, int link)
 {
 	struct net_device *dev =3D (struct net_device *) sp->dev;
@@ -3900,8 +3949,9 @@
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
 			netif_carrier_on(dev);
-			if (check_for_txSpace(sp) =3D=3D TRUE) {
-				/* Don't wake the queue, if we know there
+			if (check_for_tx_space(sp) =3D=3D TRUE) {
+				/*
+				 * Dont wake the queue if we know there
 				 * are no free TxDs available.
 				 */
 				netif_wake_queue(dev);
@@ -3911,14 +3961,15 @@
 	sp->last_link_state =3D link;
 }
=20
-/*
-*  Input Argument/s:=20
-*   pdev - structure containing the PCI related information of the =
device.
-*  Return value:
-*   returns the revision ID of the device.
-*  Description:
-*   Function to identify the Revision ID of xena.
-*/
+/**
+ *  get_xena_rev_id - to identify revision ID of xena.=20
+ *  @pdev : PCI Dev structure
+ *  Description:
+ *  Function to identify the Revision ID of xena.
+ *  Return value:
+ *  returns the revision ID of the device.
+ */
+
 int get_xena_rev_id(struct pci_dev *pdev)
 {
 	u8 id =3D 0;
@@ -3927,21 +3978,22 @@
 	return id;
 }
=20
-/*
-*  Input Argument/s:=20
-*   sp - private member of the device structure, which is a pointer to =
the=20
-*   s2io_nic structure.
-*  Return value:
-*   void
-*  Description:
-*   This function initializes a few of the PCI and PCI-X configuration =
registers
-*   with recommended values.
-*/
+/**
+ *  s2io_init_pci -Initialization of PCI and PCI-X configuration =
registers .=20
+ *  @sp : private member of the device structure, which is a pointer to =
the=20
+ *  s2io_nic structure.
+ *  Description:
+ *  This function initializes a few of the PCI and PCI-X configuration =
registers
+ *  with recommended values.
+ *  Return value:
+ *  void
+ */
+
 static void s2io_init_pci(nic_t * sp)
 {
 	u16 pci_cmd =3D 0;
=20
-/* Enable Data Parity Error Recovery in PCI-X command register. */
+	/* Enable Data Parity Error Recovery in PCI-X command register. */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			     &(sp->pcix_cmd));
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
@@ -3949,13 +4001,13 @@
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			     &(sp->pcix_cmd));
=20
-/* Set the PErr Response bit in PCI command register. */
+	/* Set the PErr Response bit in PCI command register. */
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
 	pci_write_config_word(sp->pdev, PCI_COMMAND,
 			      (pci_cmd | PCI_COMMAND_PARITY));
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
=20
-/* Set user specified value in Latency Timer */
+	/* Set user specified value in Latency Timer */
 	if (latency_timer) {
 		pci_write_config_byte(sp->pdev, PCI_LATENCY_TIMER,
 				      latency_timer);
@@ -3963,14 +4015,14 @@
 				     &latency_timer);
 	}
=20
-/* Set MMRB count to 4096 in PCI-X Command register. */
+	/* Set MMRB count to 4096 in PCI-X Command register. */
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			      (sp->pcix_cmd | 0x0C));
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			     &(sp->pcix_cmd));
=20
-/* Setting Maximum outstanding splits to two for now. */
-	sp->pcix_cmd &=3D 0xFF1F;
+	/*  Setting Maximum outstanding splits based on system type. */
+	sp->pcix_cmd &=3D 0xFF8F;
=20
 	sp->pcix_cmd |=3D
 	    XENA_MAX_OUTSTANDING_SPLITS(XENA_TWO_SPLIT_TRANSACTION);
@@ -3978,7 +4030,6 @@
 			      sp->pcix_cmd);
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 			     &(sp->pcix_cmd));
-
 }
=20
 MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");
@@ -3991,21 +4042,20 @@
 MODULE_PARM(rx_prio, "1-" __MODULE_STRING(1) "i");
 MODULE_PARM(tx_prio, "1-" __MODULE_STRING(1) "i");
 MODULE_PARM(latency_timer, "1-" __MODULE_STRING(1) "i");
+/**
+ *  s2io_init_nic - Initialization of the adapter .=20
+ *  @pdev : structure containing the PCI related information of the =
device.
+ *  @pre: List of PCI devices supported by the driver listed in =
s2io_tbl.
+ *  Description:
+ *  The function initializes an adapter identified by the pci_dec =
structure.
+ *  All OS related initialization including memory and device structure =
and=20
+ *  initlaization of the device private variable is done. Also the =
swapper=20
+ *  control register is initialized to enable read and write into the =
I/O=20
+ *  registers of the device.
+ *  Return value:
+ *  returns 0 on success and negative on failure.
+ */
=20
-/*
-*  Input Argument/s:=20
-*   pdev - structure containing the PCI related information of the =
device.
-*   pre -  the List of PCI devices supported by the driver listed in =
s2io_tbl.
-*  Return value:
-*   returns '0' on success and negative on failure.
-*  Description:
-*  The function initializes an adapter identified by the pci_dec =
structure.
-*  All OS related initialization including memory and device structure =
and=20
-*  initlaization of the device private variable is done. Also the =
swapper=20
-*  control register is initialized to enable read and write into the =
I/O=20
-*  registers of the device.
-* =20
-*/
 static int __devinit
 s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 {
@@ -4031,6 +4081,7 @@
 	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
 		dma_flag =3D TRUE;
+
 		if (pci_set_consistent_dma_mask
 		    (pdev, 0xffffffffffffffffULL)) {
 			DBG_PRINT(ERR_DBG,
@@ -4080,7 +4131,8 @@
 	/* Initialize some PCI/PCI-X fields of the NIC. */
 	s2io_init_pci(sp);
=20
-	/* Setting the device configuration parameters.
+	/*=20
+	 * Setting the device configuration parameters.
 	 * Most of these parameters can be specified by the user during=20
 	 * module insertion as they are module loadable parameters. If=20
 	 * these parameters are not not specified during load time, they=20
@@ -4090,7 +4142,7 @@
 	config =3D &sp->config;
=20
 	/* Tx side parameters. */
-	config->TxFIFONum =3D fifo_num ? fifo_num : 1;
+	config->tx_fifo_num =3D fifo_num ? fifo_num : 1;
=20
 	if (!fifo_len[0] && (fifo_num > 1)) {
 		printk(KERN_ERR "Fifo Lens not specified for all FIFOs\n");
@@ -4109,67 +4161,56 @@
 				goto init_failed;
 			}
 		}
-		for (cnt =3D 0; cnt < config->TxFIFONum; cnt++) {
-			config->TxCfg[cnt].FifoLen =3D fifo_len[cnt];
-			config->TxCfg[cnt].FifoPriority =3D cnt;
+		for (cnt =3D 0; cnt < config->tx_fifo_num; cnt++) {
+			config->tx_cfg[cnt].fifo_len =3D fifo_len[cnt];
+			config->tx_cfg[cnt].fifo_priority =3D cnt;
 		}
 	} else {
-		config->TxCfg[0].FifoLen =3D DEFAULT_FIFO_LEN;
-		config->TxCfg[0].FifoPriority =3D 0;
+		config->tx_cfg[0].fifo_len =3D DEFAULT_FIFO_LEN;
+		config->tx_cfg[0].fifo_priority =3D 0;
 	}
=20
-	config->TxIntrType =3D TXD_INT_TYPE_UTILZ;
-	for (i =3D 0; i < config->TxFIFONum; i++) {
-		if (config->TxCfg[i].FifoLen < 65) {
-			config->TxIntrType =3D TXD_INT_TYPE_PER_LIST;
+	config->tx_intr_type =3D TXD_INT_TYPE_UTILZ;
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
+		config->tx_cfg[i].f_no_snoop =3D
+		    (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);
+		if (config->tx_cfg[i].fifo_len < 65) {
+			config->tx_intr_type =3D TXD_INT_TYPE_PER_LIST;
 			break;
 		}
 	}
-
-	config->TxCfg[0].fNoSnoop =3D (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);
-	config->MaxTxDs =3D MAX_SKB_FRAGS;
-	config->TxFlow =3D TRUE;
+	config->max_txds =3D MAX_SKB_FRAGS;
=20
 	/* Rx side parameters. */
-	config->RxRingNum =3D ring_num ? ring_num : 1;
+	config->rx_ring_num =3D ring_num ? ring_num : 1;
=20
 	if (ring_len[0]) {
 		int cnt;
-		for (cnt =3D 0; cnt < config->RxRingNum; cnt++) {
-			config->RxCfg[cnt].NumRxd =3D ring_len[cnt];
-			config->RxCfg[cnt].RingPriority =3D cnt;
+		for (cnt =3D 0; cnt < config->rx_ring_num; cnt++) {
+			config->rx_cfg[cnt].num_rxd =3D ring_len[cnt];
+			config->rx_cfg[cnt].ring_priority =3D cnt;
 		}
 	} else {
-		int id;
-		if ((id =3D get_xena_rev_id(pdev)) =3D=3D 1) {
-			config->RxCfg[0].NumRxd =3D LARGE_RXD_CNT;
+		config->rx_cfg[0].num_rxd =3D SMALL_RXD_CNT;
+		config->rx_cfg[0].ring_priority =3D 0;
+	}
=20
-		} else {
-			config->RxCfg[0].NumRxd =3D SMALL_RXD_CNT;
-		}
-		config->RxCfg[0].RingPriority =3D 0;
+	for (i =3D 0; i < config->rx_ring_num; i++) {
+		config->rx_cfg[i].ring_org =3D RING_ORG_BUFF1;
+		config->rx_cfg[i].f_no_snoop =3D
+		    (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);
 	}
-	config->RxCfg[0].RingOrg =3D RING_ORG_BUFF1;
-	config->RxCfg[0].RxdThresh =3D DEFAULT_RXD_THRESHOLD;
-	config->RxCfg[0].fNoSnoop =3D (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);
-	config->RxCfg[0].RxD_BackOff_Interval =3D TBD;
-	config->RxFlow =3D TRUE;
-
-	/* Miscellaneous parameters. */
-	config->RxVLANEnable =3D TRUE;
-	config->MTU =3D MAX_MTU_VLAN;
-	config->JumboEnable =3D FALSE;
=20
 	/*  Setting Mac Control parameters */
-	mac_control->txdl_len =3D MAX_SKB_FRAGS;
 	mac_control->rmac_pause_time =3D 0;
=20
+
 	/* Initialize Ring buffer parameters. */
-	for (i =3D 0; i < config->RxRingNum; i++)
+	for (i =3D 0; i < config->rx_ring_num; i++)
 		atomic_set(&sp->rx_bufs_left[i], 0);
=20
 	/*  initialize the shared memory used by the NIC and the host */
-	if (initSharedMem(sp)) {
+	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
 			  dev->name);
 		goto mem_alloc_failed;
@@ -4208,15 +4249,16 @@
 	dev->set_multicast_list =3D &s2io_set_multicast;
 	dev->do_ioctl =3D &s2io_ioctl;
 	dev->change_mtu =3D &s2io_change_mtu;
+#ifdef SET_ETHTOOL_OPS
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-
+#endif
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
 #ifdef CONFIG_S2IO_NAPI
 	dev->poll =3D s2io_poll;
-	dev->weight =3D 128;	/* For now. */
+	dev->weight =3D 90;	/* For now. */
 #endif
=20
 	dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
@@ -4244,14 +4286,15 @@
 	if (s2io_set_swapper(sp)) {
 		DBG_PRINT(ERR_DBG, "%s:swapper settings are wrong\n",
 			  dev->name);
-		goto set_swap_failed;
+		goto register_failed;
 	}
=20
 	/* Fix for all "FFs" MAC address problems observed on Alpha platforms =
*/
-	FixMacAddress(sp);
+	fix_mac_address(sp);
 	s2io_reset(sp);
=20
-	/* Setting swapper control on the NIC, so the MAC address can be read.
+	/*
+	 * Setting swapper control on the NIC, so the MAC address can be read.
 	 */
 	if (s2io_set_swapper(sp)) {
 		DBG_PRINT(ERR_DBG,
@@ -4260,50 +4303,52 @@
 		goto set_swap_failed;
 	}
=20
-	/*  MAC address initialization.
-	 *  For now only one mac address will be read and used.
+	/* =20
+	 * MAC address initialization.
+	 * For now only one mac address will be read and used.
 	 */
 	bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	val64 =3D RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
-	waitForCmdComplete(sp);
+	wait_for_cmd_complete(sp);
=20
 	tmp64 =3D readq(&bar0->rmac_addr_data0_mem);
 	mac_down =3D (u32) tmp64;
 	mac_up =3D (u32) (tmp64 >> 32);
=20
-	memset(sp->defMacAddr[0].mac_addr, 0, sizeof(ETH_ALEN));
+	memset(sp->def_mac_addr[0].mac_addr, 0, sizeof(ETH_ALEN));
=20
-	sp->defMacAddr[0].mac_addr[3] =3D (u8) (mac_up);
-	sp->defMacAddr[0].mac_addr[2] =3D (u8) (mac_up >> 8);
-	sp->defMacAddr[0].mac_addr[1] =3D (u8) (mac_up >> 16);
-	sp->defMacAddr[0].mac_addr[0] =3D (u8) (mac_up >> 24);
-	sp->defMacAddr[0].mac_addr[5] =3D (u8) (mac_down >> 16);
-	sp->defMacAddr[0].mac_addr[4] =3D (u8) (mac_down >> 24);
+	sp->def_mac_addr[0].mac_addr[3] =3D (u8) (mac_up);
+	sp->def_mac_addr[0].mac_addr[2] =3D (u8) (mac_up >> 8);
+	sp->def_mac_addr[0].mac_addr[1] =3D (u8) (mac_up >> 16);
+	sp->def_mac_addr[0].mac_addr[0] =3D (u8) (mac_up >> 24);
+	sp->def_mac_addr[0].mac_addr[5] =3D (u8) (mac_down >> 16);
+	sp->def_mac_addr[0].mac_addr[4] =3D (u8) (mac_down >> 24);
=20
 	DBG_PRINT(INIT_DBG,
 		  "DEFAULT MAC ADDR:0x%02x-%02x-%02x-%02x-%02x-%02x\n",
-		  sp->defMacAddr[0].mac_addr[0],
-		  sp->defMacAddr[0].mac_addr[1],
-		  sp->defMacAddr[0].mac_addr[2],
-		  sp->defMacAddr[0].mac_addr[3],
-		  sp->defMacAddr[0].mac_addr[4],
-		  sp->defMacAddr[0].mac_addr[5]);
+		  sp->def_mac_addr[0].mac_addr[0],
+		  sp->def_mac_addr[0].mac_addr[1],
+		  sp->def_mac_addr[0].mac_addr[2],
+		  sp->def_mac_addr[0].mac_addr[3],
+		  sp->def_mac_addr[0].mac_addr[4],
+		  sp->def_mac_addr[0].mac_addr[5]);
=20
 	/*  Set the factory defined MAC address initially   */
 	dev->addr_len =3D ETH_ALEN;
-	memcpy(dev->dev_addr, sp->defMacAddr, ETH_ALEN);
+	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
=20
 	/*  Initialize the tasklet status flag */
 	atomic_set(&(sp->tasklet_status), 0);
=20
=20
 	/* Initialize spinlocks */
-	spin_lock_init(&sp->isr_lock);
 	spin_lock_init(&sp->tx_lock);
+	spin_lock_init(&sp->isr_lock);
=20
-	/* SXE-002: Configure link and activity LED to init state=20
+	/*=20
+	 * SXE-002: Configure link and activity LED to init state=20
 	 * on driver load.=20
 	 */
 	subid =3D sp->pdev->subsystem_device;
@@ -4316,15 +4361,16 @@
 		val64 =3D readq(&bar0->gpio_control);
 	}
=20
-	/* Make Link state as off at this point, when the Link change=20
+	sp->rx_csum =3D 1;	/* Rx chksum verify enabled by default */
+
+	/*=20
+	 * Make Link state as off at this point, when the Link change=20
 	 * interrupt comes the state will be automatically changed to=20
 	 * the right state.
 	 */
 	netif_carrier_off(dev);
 	sp->last_link_state =3D LINK_DOWN;
=20
-	sp->rx_csum =3D 1;	/* Rx chksum verify enabled by default */
-
 	return 0;
=20
       set_swap_failed:
@@ -4335,7 +4381,7 @@
 	iounmap(sp->bar0);
       bar0_remap_failed:
       mem_alloc_failed:
-	freeSharedMem(sp);
+	free_shared_mem(sp);
       init_failed:
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
@@ -4345,16 +4391,15 @@
 	return -ENODEV;
 }
=20
-/*
-*  Input Argument/s:=20
-*   pdev - structure containing the PCI related information of the =
device.
-*  Return value:
-*  void
-*  Description:
-*  This function is called by the Pci subsystem to release a PCI device =

-*  and free up all resource held up by the device. This could be in =
response=20
-*  to a Hot plug event or when the driver is to be removed from memory.
-*/
+/**
+ * s2io_rem_nic - Free the PCI device=20
+ * @pdev: structure containing the PCI related information of the =
device.
+ * Description: This function is called by the Pci subsystem to release =
a=20
+ * PCI device and free up all resource held up by the device. This =
could
+ * be in response to a Hot plug event or when the driver is to be =
removed=20
+ * from memory.
+ */
+
 static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 {
 	struct net_device *dev =3D
@@ -4365,24 +4410,36 @@
 		DBG_PRINT(ERR_DBG, "Driver Data is NULL!!\n");
 		return;
 	}
+
 	sp =3D dev->priv;
-	freeSharedMem(sp);
+	unregister_netdev(dev);
+
+	free_shared_mem(sp);
 	iounmap(sp->bar0);
 	iounmap(sp->bar1);
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
=20
-	unregister_netdev(dev);
-
 	free_netdev(dev);
 }
=20
+/**
+ * s2io_starter - Entry point for the driver
+ * Description: This function is the entry point for the driver. It =
verifies
+ * the module loadable parameters and initializes PCI configuration =
space.
+ */
+
 int __init s2io_starter(void)
 {
 	return pci_module_init(&s2io_driver);
 }
=20
+/**
+ * s2io_closer - Cleanup routine for the driver=20
+ * Description: This function is the cleanup routine for the driver. It =
unregist * ers the driver.
+ */
+
 void s2io_closer(void)
 {
 	pci_unregister_driver(&s2io_driver);
diff -urN vanilla-linux/drivers/net/s2io.h =
linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-06 11:31:09.532308264 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-06 13:03:08.087360376 -0700
@@ -16,6 +16,7 @@
 #define TBD 0
 #define BIT(loc)		(0x8000000000000000ULL >> (loc))
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
+#define INV(d)  ((d&0xff)<<24) | (((d>>8)&0xff)<<16) | =
(((d>>16)&0xff)<<8)| ((d>>24)&0xff)
=20
 #ifndef BOOL
 #define BOOL    int
@@ -49,11 +50,13 @@
 #define ALIGN_SIZE  			127
 #define	PCIX_COMMAND_REGISTER	0x62
=20
+#ifndef SET_ETHTOOL_OPS
+#define SUPPORTED_10000baseT_Full (1 << 12)
+#endif
+
 /*
  * Debug related variables.
  */
-#define DEBUG_ON TRUE
-
 /* different debug levels. */
 #define	ERR_DBG		0
 #define	INIT_DBG	1
@@ -312,7 +315,7 @@
 /* Maintains Per FIFO related information. */
 typedef struct tx_fifo_config {
 #define	MAX_AVAILABLE_TXDS	8192
-	u32 FifoLen;		/* specifies len of FIFO upto 8192, ie no of TxDLs */
+	u32 fifo_len;		/* specifies len of FIFO upto 8192, ie no of TxDLs */
 /* Priority definition */
 #define TX_FIFO_PRI_0               0	/*Highest */
 #define TX_FIFO_PRI_1               1
@@ -322,9 +325,9 @@
 #define TX_FIFO_PRI_5               5
 #define TX_FIFO_PRI_6               6
 #define TX_FIFO_PRI_7               7	/*lowest */
-	u8 FifoPriority;	/* specifies pointer level for FIFO */
+	u8 fifo_priority;	/* specifies pointer level for FIFO */
 	/* user should not set twos fifos with same pri */
-	u8 fNoSnoop;
+	u8 f_no_snoop;
 #define NO_SNOOP_TXD                0x01
 #define NO_SNOOP_TXD_BUFFER          0x02
 } tx_fifo_config_t;
@@ -332,7 +335,7 @@
=20
 /* Maintains per Ring related information */
 typedef struct rx_ring_config {
-	u32 NumRxd;		/*No of RxDs per Rx Ring */
+	u32 num_rxd;		/*No of RxDs per Rx Ring */
 #define RX_RING_PRI_0               0	/* highest */
 #define RX_RING_PRI_1               1
 #define RX_RING_PRI_2               2
@@ -342,70 +345,37 @@
 #define RX_RING_PRI_6               6
 #define RX_RING_PRI_7               7	/* lowest */
=20
-	u8 RingPriority;	/*Specifies service priority of ring */
+	u8 ring_priority;	/*Specifies service priority of ring */
 	/* OSM should not set any two rings with same priority */
-	u8 RingOrg;		/*Organization of ring */
+	u8 ring_org;		/*Organization of ring */
 #define RING_ORG_BUFF1           0x01
 #define RX_RING_ORG_BUFF3           0x03
 #define RX_RING_ORG_BUFF5           0x05
=20
-/* In case of 3 buffer recv. mode, size of three buffers is expected =
as.. */
-#define BUFF_SZ_1                   22	/* ethernet header */
-#define BUFF_SZ_2                   (64+64)	/* max. IP+TCP header size =
*/
-#define BUFF_SZ_3                   (1500-20-20)	/* TCP payload */
-#define BUFF_SZ_3_JUMBO             (9600-20-20)	/* Jumbo TCP payload =
*/
-
-	u32 RxdThresh;		/*No of used Rxds NIC can store before transfer to =
host */
-#define DEFAULT_RXD_THRESHOLD       0x1	/* TODO */
-	u8 fNoSnoop;
+	u8 f_no_snoop;
 #define NO_SNOOP_RXD                0x01
 #define NO_SNOOP_RXD_BUFFER         0x02
-	u32 RxD_BackOff_Interval;
-#define RXD_BACKOFF_INTERVAL_DEF        0x0
-#define RXD_BACKOFF_INTERVAL_MIN        0x0
-#define RXD_BACKOFF_INTERVAL_MAX        0x0
 } rx_ring_config_t;
=20
 /* This structure provides contains values of the tunable parameters=20
  * of the H/W=20
  */
 struct config_param {
-
 /* Tx Side */
-	u32 TxFIFONum;		/*Number of Tx FIFOs */
+	u32 tx_fifo_num;	/*Number of Tx FIFOs */
 #define MAX_TX_FIFOS 8
=20
-	tx_fifo_config_t TxCfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */
-	u32 MaxTxDs;		/*Max no. of Tx buffer descriptor per TxDL */
-	BOOL TxVLANEnable;	/*TRUE: Insert VLAN ID, FALSE: Don't insert */
-#define TX_REQ_TIMEOUT_DEFAULT          0x0
-#define TX_REQ_TIMEOUT_MIN              0x0
-#define TX_REQ_TIMEOUT_MAX              0x0
-	u32 TxReqTimeOut;
-	BOOL TxFlow;		/*Tx flow control enable */
-	BOOL RxFlow;
-	BOOL OverrideTxServiceState;	/* TRUE: Overide, FALSE: Do not override=20
-					   Use the new priority information
-					   of service state. It is not recommended
-					   to change but OSM can opt to do so */
-#define MAX_SERVICE_STATES  36
-	u8 TxServiceState[MAX_SERVICE_STATES];
-	/* Array element represent 'priority'=20
-	 * and array index represents
-	 *  'Service state' e.g.=20
-	 *  TxServiceState[3]=3D7; it means=20
-	 *  Service state 3 is associated=20
-	 *  with priority 7 of a Tx FIFO */
-	u64 TxIntrType;		/* Specifies if Tx Intr is UTILZ or PER_LIST type. */
+	tx_fifo_config_t tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */
+	u32 max_txds;		/*Max no. of Tx buffer descriptor per TxDL */
+	u64 tx_intr_type;
+	/* Specifies if Tx Intr is UTILZ or PER_LIST type. */
=20
 /* Rx Side */
-	u32 RxRingNum;		/*Number of receive rings */
+	u32 rx_ring_num;	/*Number of receive rings */
 #define MAX_RX_RINGS 8
 #define MAX_RX_BLOCKS_PER_RING  150
=20
-	rx_ring_config_t RxCfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
-	BOOL RxVLANEnable;	/*TRUE: Strip off VLAN tag from the frame,
-				   FALSE: Don't strip off VLAN tag */
+	rx_ring_config_t rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
=20
 #define HEADER_ETHERNET_II_802_3_SIZE 14
 #define HEADER_802_2_SIZE              3
@@ -419,23 +389,6 @@
 #define MAX_PYLD_JUMBO              9600
 #define MAX_MTU_JUMBO               (MAX_PYLD_JUMBO+18)
 #define MAX_MTU_JUMBO_VLAN          (MAX_PYLD_JUMBO+22)
-	u32 MTU;		/*Maximum Payload */
-	BOOL JumboEnable;	/*Enable Jumbo frames recv/send */
-	BOOL OverrideRxServiceState;	/* TRUE: Overide, FALSE: Do not override=20
-					   Use the new priority information
-					   of service state. It is not recommended
-					   to change but OSM can opt to do so */
-#define MAX_SERVICE_STATES  36
-	u8 RxServiceState[MAX_SERVICE_STATES];
-	/* Array element represent 'priority'=20
-	 * and array index represents=20
-	 * 'Service state'e.g.=20
-	 * RxServiceState[3]=3D7; it means=20
-	 * Service state 3 is associated=20
-	 * with priority 7 of a Rx FIFO */
-	BOOL StatAutoRefresh;	/* When true, StatRefreshTime have valid value =
*/
-	u32 StatRefreshTime;	/*Time for refreshing statistics */
-#define     STAT_TRSF_PER_1_SECOND      0x208D5
 };
=20
 /* Structure representing MAC Addrs */
@@ -514,14 +467,9 @@
 #define SET_NUM_TAG(val)       vBIT(val,16,32)
=20
 #define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & =
vBIT(0xFFFF,0,16)))
-/*   =20
-#define TXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER1_SIZE) >> (63-31)) =20
-#define TXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER2_SIZE) >> (63-47)) =20
-*/
 	u64 Buffer0_ptr;
 } RxD_t;
=20
-
 /* Structure that represents the Rx descriptor block which contains=20
  * 128 Rx descriptors.
  */
@@ -531,11 +479,12 @@
=20
 	u64 reserved_0;
 #define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
-	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd in this blk */
-	u64 reserved_2_pNext_RxD_block;	/*@ Logical ptr to next */
-	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.
-					   In a 32 bit arch the upper 32 bits=20
-					   should be 0 */
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last=20
+				 * Rxd in this blk */
+	u64 reserved_2_pNext_RxD_block;	/* Logical ptr to next */
+	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.In a 32 bit arch
+					 * the upper 32 bits should=20
+					 * be 0 */
 } RxD_block_t;
=20
 /* Structure which stores all the MAC control parameters */
@@ -568,10 +517,6 @@
  */
 typedef struct mac_info {
 /* rx side stuff */
-	u32 rxd_ring_mem_sz;
-	RxD_t *RxRing[MAX_RX_RINGS];	/* Logical Rx ring pointers */
-	dma_addr_t RxRing_Phy[MAX_RX_RINGS];
-
 	/* Put pointer info which indictes which RxD has to be replenished=20
 	 * with a new buffer.
 	 */
@@ -583,41 +528,29 @@
 	rx_curr_get_info_t rx_curr_get_info[MAX_RX_RINGS];
=20
 	u16 rmac_pause_time;
-
-	/* this will be used in receive function, this decides which ring =
would
-	   be processed first. eg: ring with priority value 0 (highest) should
-	   be processed first.=20
-	   first 3 LSB bits represent ring number which should be processed=20
-	   first, similarly next 3 bits represent next ring to be processed.
-	   eg: value of _rx_ring_pri_map =3D 0x0000 003A means=20
-	   ring #2 would be processed first and #7 would be processed next
-	 */
-	u32 _rx_ring_pri_map;
+	u16 mc_pause_threshold_q0q3;
+	u16 mc_pause_threshold_q4q7;
=20
 /* tx side stuff */
-	void *txd_list_mem;	/* orignal pointer to allocated mem */
+	void *txd_list_mem;	/* original pointer to allocated mem */
 	dma_addr_t txd_list_mem_phy;
 	u32 txd_list_mem_sz;
=20
 	/* logical pointer of start of each Tx FIFO */
 	TxFIFO_element_t *tx_FIFO_start[MAX_TX_FIFOS];
=20
-	/* logical pointer of start of TxDL which corresponds to each Tx FIFO =
*/
+	/* The Phy and virtual mem loactions of the Tx descriptors. */
 	TxD_t *txdl_start[MAX_TX_FIFOS];
-
-	/* Same as txdl_start but phy addr */
 	dma_addr_t txdl_start_phy[MAX_TX_FIFOS];
=20
 /* Current offset within tx_FIFO_start, where driver would write new Tx =
frame*/
 	tx_curr_put_info_t tx_curr_put_info[MAX_TX_FIFOS];
 	tx_curr_get_info_t tx_curr_get_info[MAX_TX_FIFOS];
=20
-	u16 txdl_len;		/* length of a TxDL, same for all */
-
 	void *stats_mem;	/* orignal pointer to allocated mem */
 	dma_addr_t stats_mem_phy;	/* Physical address of the stat block */
 	u32 stats_mem_sz;
-	StatInfo_t *StatsInfo;	/* Logical address of the stat block */
+	StatInfo_t *stats_info;	/* Logical address of the stat block */
 } mac_info_t;
=20
 /* structure representing the user defined MAC addresses */
@@ -632,13 +565,20 @@
 	dma_addr_t block_dma_addr;
 } rx_block_info_t;
=20
+/* Default Tunable parameters of the NIC. */
+#define DEFAULT_FIFO_LEN 4096
+#define SMALL_RXD_CNT	30 * (MAX_RXDS_PER_BLOCK+1)
+#define LARGE_RXD_CNT	100 * (MAX_RXDS_PER_BLOCK+1)
+#define SMALL_BLK_CNT	30
+#define LARGE_BLK_CNT	100
+
 /* Structure representing one instance of the NIC */
 typedef struct s2io_nic {
 #define MAX_MAC_SUPPORTED   16
 #define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED
=20
-	macaddr_t defMacAddr[MAX_MAC_SUPPORTED];
-	macaddr_t preMacAddr[MAX_MAC_SUPPORTED];
+	macaddr_t def_mac_addr[MAX_MAC_SUPPORTED];
+	macaddr_t pre_mac_addr[MAX_MAC_SUPPORTED];
=20
 	struct net_device_stats stats;
 	caddr_t bar0;
@@ -671,8 +611,8 @@
 	u32 irq;
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
=20
-	spinlock_t isr_lock;
 	spinlock_t tx_lock;
+	spinlock_t isr_lock;
=20
 #define PROMISC     1
 #define ALL_MULTI   2
@@ -691,20 +631,11 @@
 	u16 tx_err_count;
 	u16 rx_err_count;
=20
-#if DEBUG_ON
-	u64 rxpkt_bytes;
-	u64 txpkt_bytes;
-	int int_cnt;
-	int rxint_cnt;
-	int txint_cnt;
-	u64 rxpkt_cnt;
-#endif
-
-	/*  Place holders for the virtual and physical addresses of=20
+	/*
+	 *  Place holders for the virtual and physical addresses of=20
 	 *  all the Rx Blocks
 	 */
-	struct rx_block_info
-	 rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];
+	rx_block_info_t rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];
 	int block_count[MAX_RX_RINGS];
 	int pkt_cnt[MAX_RX_RINGS];
=20
@@ -742,19 +673,14 @@
 #define RESET_ERROR 1;
 #define CMD_ERROR   2;
=20
-/* Default Tunable parameters of the NIC. */
-#define DEFAULT_FIFO_LEN 4096
-#define SMALL_RXD_CNT	40 * (MAX_RXDS_PER_BLOCK+1)
-#define LARGE_RXD_CNT	100 * (MAX_RXDS_PER_BLOCK+1)
-
 /*  OS related system calls */
 #ifndef readq
 static inline u64 readq(void *addr)
 {
 	u64 ret =3D 0;
 	ret =3D readl(addr + 4);
-	ret <<=3D 32;
-	ret |=3D readl(addr);
+	(u64) ret <<=3D 32;
+	(u64) ret |=3D readl(addr);
=20
 	return ret;
 }
@@ -816,30 +742,36 @@
=20
 /*  DMA level Inressupts */
 #define TXDMA_PFC_INT_M     BIT(0)
-    /*  PFC block interrupts */
+#define TXDMA_PCC_INT_M     BIT(2)
+
+/*  PFC block interrupts */
 #define PFC_MISC_ERR_1      BIT(0)	/* Interrupt to indicate FIFO full =
*/
=20
+/* PCC block interrupts. */
+#define	PCC_FB_ECC_ERR	   vBIT(0xff, 16, 8)	/* Interrupt to indicate
+						   PCC_FB_ECC Error. */
+
 /*
  * Prototype declaration.
  */
 static int __devinit s2io_init_nic(struct pci_dev *pdev,
 				   const struct pci_device_id *pre);
 static void __devexit s2io_rem_nic(struct pci_dev *pdev);
-static int initSharedMem(struct s2io_nic *sp);
-static void freeSharedMem(struct s2io_nic *sp);
-static int initNic(struct s2io_nic *nic);
+static int init_shared_mem(struct s2io_nic *sp);
+static void free_shared_mem(struct s2io_nic *sp);
+static int init_nic(struct s2io_nic *nic);
 #ifndef CONFIG_S2IO_NAPI
-static void rxIntrHandler(struct s2io_nic *sp);
+static void rx_intr_handler(struct s2io_nic *sp);
 #endif
-static void txIntrHandler(struct s2io_nic *sp);
-static void alarmIntrHandler(struct s2io_nic *sp);
+static void tx_intr_handler(struct s2io_nic *sp);
+static void alarm_intr_handler(struct s2io_nic *sp);
=20
 static int s2io_starter(void);
 void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
-static int rxOsmHandler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no);
+static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no);
 void s2io_link(nic_t * sp, int link);
 void s2io_reset(nic_t * sp);
 #ifdef CONFIG_S2IO_NAPI
@@ -849,6 +781,10 @@
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs =
*regs);
 static int verify_xena_quiescence(u64 val64, int flag);
+int verify_load_parm(void);
+#ifdef SET_ETHTOOL_OPS
 static struct ethtool_ops netdev_ethtool_ops;
+#endif
+static void s2io_set_link(unsigned long data);
=20
 #endif				/* _S2IO_H */
diff -urN vanilla-linux/drivers/net/s2io-regs.h =
linux-2.6.8.1/drivers/net/s2io-regs.h
--- vanilla-linux/drivers/net/s2io-regs.h	2004-10-06 11:31:09.539307200 =
-0700
+++ linux-2.6.8.1/drivers/net/s2io-regs.h	2004-10-06 13:03:08.087360376 =
-0700
@@ -289,6 +289,8 @@
 	u64 tda_err_alarm;
=20
 	u64 pcc_err_reg;
+#define PCC_FB_ECC_DB_ERR		vBIT(0xFF, 16, 8)
+
 	u64 pcc_err_mask;
 	u64 pcc_err_alarm;
=20
@@ -512,6 +514,7 @@
 #define RX_PA_CFG_IGNORE_FRM_ERR           BIT(1)
 #define RX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)
 #define RX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)
+#define RX_PA_CFG_IGNORE_L2_ERR            BIT(6)
=20
 	u8 unused12[0x700 - 0x1D8];
=20

------=_NextPart_000_003F_01C4B150.5919F570--
