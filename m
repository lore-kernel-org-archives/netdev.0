From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 9/9] net/various: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:36 +0100
Message-ID: <1269453456-13599-9-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
---
 drivers/net/benet/be_ethtool.c        |    2 +-
 drivers/net/benet/be_main.c           |    2 +-
 drivers/net/bnx2x_link.c              |   12 ++++++------
 drivers/net/bonding/bond_main.c       |    4 ++--
 drivers/net/dnet.c                    |    2 +-
 drivers/net/hamradio/baycom_ser_fdx.c |    2 +-
 drivers/net/mlx4/en_netdev.c          |    2 +-
 drivers/net/qla3xxx.c                 |    2 +-
 drivers/net/qlge/qlge_dbg.c           |    4 ++--
 drivers/net/sis900.c                  |    4 ++--
 drivers/net/skfp/fplustm.c            |    2 +-
 drivers/net/skfp/pcmplc.c             |    4 ++--
 drivers/net/skfp/srf.c                |    2 +-
 drivers/net/skge.c                    |    2 +-
 drivers/net/stmmac/dwmac100.c         |    2 +-
 drivers/net/stmmac/stmmac_main.c      |    2 +-
 drivers/net/tlan.c                    |    2 +-
 drivers/net/tsi108_eth.c              |    6 +++---
 drivers/net/ucc_geth.c                |    2 +-
 drivers/net/vxge/vxge-main.c          |    2 +-
 drivers/net/wan/pc300_drv.c           |    2 +-
 drivers/net/wan/pc300_tty.c           |    2 +-
 drivers/net/wan/sdla.c                |    2 +-
 drivers/net/wimax/i2400m/tx.c         |    2 +-
 24 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 9560d48..d7390da 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -496,7 +496,7 @@ be_test_ddr_dma(struct be_adapter *adapter)
 	ddrdma_cmd.va = pci_alloc_consistent(adapter->pdev, ddrdma_cmd.size,
 					&ddrdma_cmd.dma);
 	if (!ddrdma_cmd.va) {
-		dev_err(&adapter->pdev->dev, "Memory allocation failure \n");
+		dev_err(&adapter->pdev->dev, "Memory allocation failure\n");
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 174e5f8..50ea056 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1749,7 +1749,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 			PCICFG_PM_CONTROL_OFFSET, PCICFG_PM_CONTROL_MASK);
 		if (status) {
 			dev_err(&adapter->pdev->dev,
-				"Could not enable Wake-on-lan \n");
+				"Could not enable Wake-on-lan\n");
 			pci_free_consistent(adapter->pdev, cmd.size, cmd.va,
 					cmd.dma);
 			return status;
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 32e79c3..ff70be8 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1594,7 +1594,7 @@ static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
 				MDIO_AN_REG_ADV_PAUSE_MASK) >> 8;
 		pause_result |= (lp_pause &
 				 MDIO_AN_REG_ADV_PAUSE_MASK) >> 10;
-		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x \n",
+		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x\n",
 		   pause_result);
 		bnx2x_pause_resolve(vars, pause_result);
 		if (vars->flow_ctrl == BNX2X_FLOW_CTRL_NONE &&
@@ -1616,7 +1616,7 @@ static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
 				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 7;
 
 			bnx2x_pause_resolve(vars, pause_result);
-			DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x \n",
+			DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x\n",
 				 pause_result);
 		}
 	}
@@ -1974,7 +1974,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		}
 	}
 
-	DP(NETIF_MSG_LINK, "gp_status 0x%x  phy_link_up %x line_speed %x \n",
+	DP(NETIF_MSG_LINK, "gp_status 0x%x  phy_link_up %x line_speed %x\n",
 		 gp_status, vars->phy_link_up, vars->line_speed);
 	DP(NETIF_MSG_LINK, "duplex %x  flow_ctrl 0x%x"
 		 " autoneg 0x%x\n",
@@ -3852,7 +3852,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				    SPEED_AUTO_NEG) &&
 				   ((params->speed_cap_mask &
 				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))) {
-				DP(NETIF_MSG_LINK, "Setting 1G clause37 \n");
+				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
 					       ext_phy_addr, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_ADV, 0x20);
@@ -4234,14 +4234,14 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				      ext_phy_addr,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_10G_CTRL2, &tmp1);
-				DP(NETIF_MSG_LINK, "1.7 = 0x%x \n", tmp1);
+				DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
 
 			} else if ((params->req_line_speed ==
 				    SPEED_AUTO_NEG) &&
 				   ((params->speed_cap_mask &
 				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))) {
 
-				DP(NETIF_MSG_LINK, "Setting 1G clause37 \n");
+				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
 					       ext_phy_addr, MDIO_AN_DEVAD,
 					       MDIO_PMA_REG_8727_MISC_CTRL, 0);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c2aceaa..f8ab60b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4667,13 +4667,13 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (num_grat_arp < 0 || num_grat_arp > 255) {
-		pr_warning("Warning: num_grat_arp (%d) not in range 0-255 so it was reset to 1 \n",
+		pr_warning("Warning: num_grat_arp (%d) not in range 0-255 so it was reset to 1\n",
 			   num_grat_arp);
 		num_grat_arp = 1;
 	}
 
 	if (num_unsol_na < 0 || num_unsol_na > 255) {
-		pr_warning("Warning: num_unsol_na (%d) not in range 0-255 so it was reset to 1 \n",
+		pr_warning("Warning: num_unsol_na (%d) not in range 0-255 so it was reset to 1\n",
 			   num_unsol_na);
 		num_unsol_na = 1;
 	}
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 2346852..d51a83e 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -918,7 +918,7 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 
 	dev_info(&pdev->dev, "Dave DNET at 0x%p (0x%08x) irq %d %pM\n",
 	       bp->regs, mem_base, dev->irq, dev->dev_addr);
-	dev_info(&pdev->dev, "has %smdio, %sirq, %sgigabit, %sdma \n",
+	dev_info(&pdev->dev, "has %smdio, %sirq, %sgigabit, %sdma\n",
 	       (bp->capabilities & DNET_HAS_MDIO) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_IRQ) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_GIGABIT) ? "" : "no ",
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index 0cab992..ffc0cbd 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -429,7 +429,7 @@ static int ser12_open(struct net_device *dev)
 		return -EINVAL;
 	}
 	if (!request_region(dev->base_addr, SER12_EXTENT, "baycom_ser_fdx")) {
-		printk(KERN_WARNING "BAYCOM_SER_FSX: I/O port 0x%04lx busy \n", 
+		printk(KERN_WARNING "BAYCOM_SER_FSX: I/O port 0x%04lx busy\n", 
 		       dev->base_addr);
 		return -EACCES;
 	}
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 7cd0933..5eb96fe 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -503,7 +503,7 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 
 	err = mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
 	if (err)
-		en_dbg(HW, priv, "Could not update stats \n");
+		en_dbg(HW, priv, "Could not update stats\n");
 
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up) {
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 4ef0afb..fc11ad3 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2258,7 +2258,7 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 				       "%x.\n",
 				       ndev->name, net_rsp->opcode);
 				printk(KERN_ERR PFX
-				       "0x%08lx 0x%08lx 0x%08lx 0x%08lx \n",
+				       "0x%08lx 0x%08lx 0x%08lx 0x%08lx\n",
 				       (unsigned long int)tmp[0],
 				       (unsigned long int)tmp[1],
 				       (unsigned long int)tmp[2],
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index ff8550d..947a7aa 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1338,7 +1338,7 @@ void ql_mpi_core_to_log(struct work_struct *work)
 
 	for (i = 0; i < count; i += 8) {
 		printk(KERN_ERR "%.08x: %.08x %.08x %.08x %.08x %.08x "
-			"%.08x %.08x %.08x \n", i,
+			"%.08x %.08x %.08x\n", i,
 			tmp[i + 0],
 			tmp[i + 1],
 			tmp[i + 2],
@@ -2056,7 +2056,7 @@ void ql_dump_ob_mac_iocb(struct ob_mac_iocb_req *ob_mac_iocb)
 	       ob_mac_tso_iocb->flags2 & OB_MAC_TSO_IOCB_LSO ? "LSO" : "",
 	       ob_mac_tso_iocb->flags2 & OB_MAC_TSO_IOCB_UC ? "UC" : "",
 	       ob_mac_tso_iocb->flags2 & OB_MAC_TSO_IOCB_TC ? "TC" : "");
-	printk(KERN_ERR PFX "flags3          = %s %s %s \n",
+	printk(KERN_ERR PFX "flags3          = %s %s %s\n",
 	       ob_mac_tso_iocb->flags3 & OB_MAC_TSO_IOCB_IC ? "IC" : "",
 	       ob_mac_tso_iocb->flags3 & OB_MAC_TSO_IOCB_DFP ? "DFP" : "",
 	       ob_mac_tso_iocb->flags3 & OB_MAC_TSO_IOCB_V ? "V" : "");
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index cc0c731..bc7ff41 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1499,7 +1499,7 @@ static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex
 	}
 
 	if(netif_msg_link(sis_priv))
-		printk(KERN_INFO "%s: Media Link On %s %s-duplex \n",
+		printk(KERN_INFO "%s: Media Link On %s %s-duplex\n",
 	       				net_dev->name,
 	       				*speed == HW_SPEED_100_MBPS ?
 	       					"100mbps" : "10mbps",
@@ -1523,7 +1523,7 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 	int i;
 
 	if(netif_msg_tx_err(sis_priv))
-		printk(KERN_INFO "%s: Transmit timeout, status %8.8x %8.8x \n",
+		printk(KERN_INFO "%s: Transmit timeout, status %8.8x %8.8x\n",
 	       		net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
 
 	/* Disable interrupts by clearing the interrupt mask. */
diff --git a/drivers/net/skfp/fplustm.c b/drivers/net/skfp/fplustm.c
index 6028bbb..9d8d1ac 100644
--- a/drivers/net/skfp/fplustm.c
+++ b/drivers/net/skfp/fplustm.c
@@ -1352,7 +1352,7 @@ void rtm_set_timer(struct s_smc *smc)
 	/*
 	 * MIB timer and hardware timer have the same resolution of 80nS
 	 */
-	DB_RMT("RMT: setting new fddiPATHT_Rmode, t = %d ns \n",
+	DB_RMT("RMT: setting new fddiPATHT_Rmode, t = %d ns\n",
 		(int) smc->mib.a[PATH0].fddiPATHT_Rmode,0) ;
 	outpd(ADDR(B2_RTM_INI),smc->mib.a[PATH0].fddiPATHT_Rmode) ;
 }
diff --git a/drivers/net/skfp/pcmplc.c b/drivers/net/skfp/pcmplc.c
index e6b33ee..ba45bc7 100644
--- a/drivers/net/skfp/pcmplc.c
+++ b/drivers/net/skfp/pcmplc.c
@@ -1277,7 +1277,7 @@ static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy)
 
 	mib = phy->mib ;
 
-	DB_PCMN(1,"SIG rec %x %x: \n", bit,phy->r_val[bit] ) ;
+	DB_PCMN(1,"SIG rec %x %x:\n", bit,phy->r_val[bit] ) ;
 	bit++ ;
 
 	switch(bit) {
@@ -1580,7 +1580,7 @@ static void pc_tcode_actions(struct s_smc *smc, const int bit, struct s_phy *phy
 		mib->fddiPORTMacIndicated.T_val = phy->t_val[9] ;
 		break ;
 	}
-	DB_PCMN(1,"SIG snd %x %x: \n", bit,phy->t_val[bit] ) ;
+	DB_PCMN(1,"SIG snd %x %x:\n", bit,phy->t_val[bit] ) ;
 }
 
 /*
diff --git a/drivers/net/skfp/srf.c b/drivers/net/skfp/srf.c
index 6caf713..40882b3 100644
--- a/drivers/net/skfp/srf.c
+++ b/drivers/net/skfp/srf.c
@@ -414,7 +414,7 @@ static void smt_send_srf(struct s_smc *smc)
 	smt->smt_len = SMT_MAX_INFO_LEN - pcon.pc_len ;
 	mb->sm_len = smt->smt_len + sizeof(struct smt_header) ;
 
-	DB_SMT("SRF: sending SRF at %x, len %d \n",smt,mb->sm_len) ;
+	DB_SMT("SRF: sending SRF at %x, len %d\n",smt,mb->sm_len) ;
 	DB_SMT("SRF: state SR%d Threshold %d\n",
 		smc->srf.sr_state,smc->srf.SRThreshold/TICKS_PER_SECOND) ;
 #ifdef	DEBUG
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index d0058e5..bd8c5e8 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3666,7 +3666,7 @@ static int skge_debug_show(struct seq_file *seq, void *v)
 			   t->csum_offs, t->csum_write, t->csum_start);
 	}
 
-	seq_printf(seq, "\nRx Ring: \n");
+	seq_printf(seq, "\nRx Ring:\n");
 	for (e = skge->rx_ring.to_clean; ; e = e->next) {
 		const struct skge_rx_desc *r = e->desc;
 
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
index 803b037..a183de2 100644
--- a/drivers/net/stmmac/dwmac100.c
+++ b/drivers/net/stmmac/dwmac100.c
@@ -138,7 +138,7 @@ static void dwmac100_dump_dma_regs(unsigned long ioaddr)
 {
 	int i;
 
-	DBG(KERN_DEBUG "DWMAC 100 DMA CSR \n");
+	DBG(KERN_DEBUG "DWMAC 100 DMA CSR\n");
 	for (i = 0; i < 9; i++)
 		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
 		       (DMA_BUS_MODE + i * 4),
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 92bef30..963f591 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -836,7 +836,7 @@ static int stmmac_open(struct net_device *dev)
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
 	if (unlikely(priv->tm == NULL)) {
-		pr_err("%s: ERROR: timer memory alloc failed \n", __func__);
+		pr_err("%s: ERROR: timer memory alloc failed\n", __func__);
 		return -ENOMEM;
 	}
 	priv->tm->freq = tmrate;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 390540c..05ea30a 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -2464,7 +2464,7 @@ static void TLan_PhyPrint( struct net_device *dev )
 		printk( "TLAN:   Device %s, Unmanaged PHY.\n", dev->name );
 	} else if ( phy <= TLAN_PHY_MAX_ADDR ) {
 		printk( "TLAN:   Device %s, PHY 0x%02x.\n", dev->name, phy );
-		printk( "TLAN:      Off.  +0     +1     +2     +3 \n" );
+		printk( "TLAN:      Off.  +0     +1     +2     +3\n" );
                 for ( i = 0; i < 0x20; i+= 4 ) {
 			printk( "TLAN:      0x%02x", i );
 			TLan_MiiReadReg( dev, phy, i, &data0 );
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 647cdd1..80333a4 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -263,7 +263,7 @@ static inline void tsi108_write_tbi(struct tsi108_prv_data *data,
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __func__);
+	printk(KERN_ERR "%s function time out\n", __func__);
 }
 
 static int mii_speed(struct mii_if_info *mii)
@@ -1056,7 +1056,7 @@ static void tsi108_stop_ethernet(struct net_device *dev)
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __func__);
+	printk(KERN_ERR "%s function time out\n", __func__);
 }
 
 static void tsi108_reset_ether(struct tsi108_prv_data * data)
@@ -1233,7 +1233,7 @@ static void tsi108_init_phy(struct net_device *dev)
 		udelay(10);
 	}
 	if (i == 0)
-		printk(KERN_ERR "%s function time out \n", __func__);
+		printk(KERN_ERR "%s function time out\n", __func__);
 
 	if (data->phy_type == TSI108_PHY_BCM54XX) {
 		tsi108_write_mii(data, 0x09, 0x0300);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1b0aef3..75743a7 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3883,7 +3883,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	}
 
 	if (netif_msg_probe(&debug))
-		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
+		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d)\n",
 			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
 			ug_info->uf_info.irq);
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 46a7c9e..0006837 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4174,7 +4174,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 			ret = pci_enable_sriov(pdev, max_config_dev - 1);
 			if (ret)
 				vxge_debug_ll_config(VXGE_ERR,
-					"Failed to enable SRIOV: %d \n", ret);
+					"Failed to enable SRIOV: %d\n", ret);
 	}
 
 	/*
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index f4f1c00..cb72cc7 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -395,7 +395,7 @@ static void tx1_dma_buf_check(pc300_t * card, int ch)
 	u16 next_bd = card->chan[ch].tx_next_bd;
 	u32 scabase = card->hw.scabase;
 
-	printk ("\nnfree_tx_bd = %d \n", card->chan[ch].nfree_tx_bd);
+	printk ("\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
 	       first_bd, TX_BD_ADDR(ch, first_bd),
 	       next_bd, TX_BD_ADDR(ch, next_bd));
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index 4917a94..4293889 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -366,7 +366,7 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 	int res;
 
 	if (!tty || !tty->driver_data ) {
-		CPC_TTY_DBG("hdlx-tty: no TTY in close \n");
+		CPC_TTY_DBG("hdlx-tty: no TTY in close\n");
 		return;
 	}
 
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 31c41af..43ae6f4 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1352,7 +1352,7 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 		return(-EINVAL);
 
 	if (!request_region(map->base_addr, SDLA_IO_EXTENTS, dev->name)){
-		printk(KERN_WARNING "SDLA: io-port 0x%04lx in use \n", dev->base_addr);
+		printk(KERN_WARNING "SDLA: io-port 0x%04lx in use\n", dev->base_addr);
 		return(-EINVAL);
 	}
 	base = map->base_addr;
diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 54480e8..38f9c92 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -688,7 +688,7 @@ try_new:
 			 pl_type, buf_len);
 		tx_msg->num_pls = le16_to_cpu(num_pls+1);
 		tx_msg->size += padded_len;
-		d_printf(2, dev, "TX: appended %zu b (up to %u b) pl #%u \n",
+		d_printf(2, dev, "TX: appended %zu b (up to %u b) pl #%u\n",
 			padded_len, tx_msg->size, num_pls+1);
 		d_printf(2, dev,
 			 "TX: appended hdr @%zu %zu b pl #%u @%zu %zu/%zu b\n",
-- 
1.6.6.1
