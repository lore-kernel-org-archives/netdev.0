From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 netdev-2.6 2/2] copyright + trailing blanks + misc
Date: Tue, 13 Jan 2004 11:31:55 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401131128390.2213-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Misc: 2004 copyright, remove trailing white space, remove some
  unused symbols.

-----------

--- net-drivers-2.5-exp/drivers/net/e100.c.orig	2004-01-09 16:46:20.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e100.c	2004-01-09 16:50:02.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -27,7 +27,7 @@
 *******************************************************************************/
 
 /*
- *	e100.c: Intel(R) PRO/100 ethernet driver 
+ *	e100.c: Intel(R) PRO/100 ethernet driver
  *
  *	(Re)written 2003 by scott.feldman@intel.com.  Based loosely on
  *	original e100 driver, but better described as a munging of
@@ -65,11 +65,11 @@
  *	through the Management Data Interface (MDI).  Consequently, the
  *	driver leverages the mii.c library shared with other MII-compliant
  *	devices.
- *	
- *	Big- and Little-Endian byte order as well as 32- and 64-bit 
+ *
+ *	Big- and Little-Endian byte order as well as 32- and 64-bit
  *	archs are supported.  Weak-ordered memory and non-cache-coherent
  *	archs are supported.
- *	
+ *
  *	III. Transmit
  *
  *	A Tx skb is mapped and hangs off of a TCB.  TCBs are linked
@@ -83,7 +83,7 @@
  *	Non-Tx commands (config, multicast setup, etc) are linked
  *	into the CBL ring along with Tx commands.  The common structure
  *	used for both Tx and non-Tx commands is the Command Block (CB).
- *	
+ *
  *	cb_to_use is the next CB to use for queuing a command; cb_to_clean
  *	is the next CB to check for completion; cb_to_send is the first
  *	CB to start on in case of a previous failure to resume.  CB clean
@@ -101,14 +101,14 @@
  *	Descriptors (RFD) + data buffer, thus forming the simplified mode
  *	memory structure.  Rx skbs are allocated to contain both the RFD
  *	and the data buffer, but the RFD is pulled off before the skb is
- *	indicated.  The data buffer is aligned such that encapsulated 
+ *	indicated.  The data buffer is aligned such that encapsulated
  *	protocol headers are u32-aligned.  Since the RFD is part of the
  *	mapped shared memory, and completion status is contained within
  *	the RFD, the RFD must be dma_sync'ed to maintain a consistent
  *	view from software and hardware.
  *
  *	Under typical operation, the  receive unit (RU) is start once,
- *	and the controller happily fills RFDs as frames arrive.  If 
+ *	and the controller happily fills RFDs as frames arrive.  If
  *	replacement RFDs cannot be allocated, or the RU goes non-active,
  *	the RU must be restarted.  Frame arrival generates an interrupt,
  *	and Rx indication and re-allocation happen in the same context,
@@ -130,7 +130,7 @@
  *
  * 	MagicPacket(tm) WoL support is enabled/disabled via ethtool.
  *
- * 	Thanks to JC (jchapman@katalix.com) for helping with 
+ * 	Thanks to JC (jchapman@katalix.com) for helping with
  * 	testing/troubleshooting the development driver.
  */
 
@@ -154,9 +154,9 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.12_dev"
+#define DRV_VERSION		"3.0.13_dev"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
-#define DRV_COPYRIGHT		"Copyright(c) 1999-2003 Intel Corporation"
+#define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
 
 #define E100_WATCHDOG_PERIOD	2 * HZ
@@ -233,9 +233,9 @@
 
 enum phy {
 	phy_100a     = 0x000003E0,
-	phy_100c     = 0x035002A8, 
+	phy_100c     = 0x035002A8,
 	phy_82555_tx = 0x015002A8,
-	phy_nsc_tx   = 0x5C002000, 
+	phy_nsc_tx   = 0x5C002000,
 	phy_82562_et = 0x033002A8,
 	phy_82562_em = 0x032002A8,
 	phy_82562_eh = 0x017002A8,
@@ -260,15 +260,8 @@
 };
 
 enum scb_status {
-	rus_idle         = 0x00,
-	rus_suspended    = 0x04,
-	rus_no_resources = 0x08,
 	rus_ready        = 0x10,
 	rus_mask         = 0x3C,
-	cus_idle         = 0x00,
-	cus_suspended    = 0x40,
-	cus_active       = 0x80,
-       	cus_mask         = 0xC0,
 };
 
 enum scb_stat_ack {
@@ -517,7 +510,7 @@
 		multicast_all = (1 << 2),
 		wol_magic     = (1 << 3),
 	} flags					____cacheline_aligned;
-	
+
 	enum mac mac;
 	enum phy phy;
 	struct params params;
@@ -544,7 +537,7 @@
 	u32 rx_fc_pause;
 	u32 rx_fc_unsupported;
 	u32 rx_tco_frames;
-	
+
 	u8 rev_id;
 	u16 leds;
 	u16 eeprom_wc;
@@ -577,14 +570,14 @@
 	 * device off of PCI bus */
 	writel(selective_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
-	
+
 	/* Now fully reset device */
 	writel(software_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
-	
+
 	/* TCO workaround - 82559 and greater */
 	if(nic->mac >= mac_82559_D101M) {
-		/* Issue a redundant CU load base without setting 
+		/* Issue a redundant CU load base without setting
 		 * general pointer, and without waiting for scb to
 		 * clear.  This gets us into post-driver.  Finally,
 		 * wait 20 msec for reset to take effect. */
@@ -712,7 +705,7 @@
 	/* Try reading with an 8-bit addr len to discover actual addr len */
 	e100_eeprom_read(nic, &addr_len, 0);
 	nic->eeprom_wc = 1 << addr_len;
-	
+
 	for(addr = 0; addr < nic->eeprom_wc; addr++) {
 		nic->eeprom[addr] = e100_eeprom_read(nic, &addr_len, addr);
 		if(addr < nic->eeprom_wc - 1)
@@ -726,7 +719,7 @@
 		DPRINTK(PROBE, ERR, "EEPROM corrupted\n");
 		return -EAGAIN;
 	}
-	
+
 	return 0;
 }
 
@@ -738,10 +731,10 @@
 	/* Try reading with an 8-bit addr len to discover actual addr len */
 	e100_eeprom_read(nic, &addr_len, 0);
 	nic->eeprom_wc = 1 << addr_len;
-	
+
 	if(start + count >= nic->eeprom_wc)
 		return -EINVAL;
-	
+
 	for(addr = start; addr < start + count; addr++)
 		e100_eeprom_write(nic, addr_len, addr, nic->eeprom[addr]);
 
@@ -810,7 +803,7 @@
 		err = -ENOSPC;
 
 	cb_prepare(nic, cb, skb);
-	
+
 	/* Order is important otherwise we'll be in a race with h/w:
 	 * set S-bit in current first, then clear S-bit in previous. */
 	cb->command |= cpu_to_le16(cb_s);
@@ -849,7 +842,7 @@
 		if((data_out = readl(&nic->csr->mdi_ctrl)) & mdi_ready)
 			break;
 	}
-	
+
 	DPRINTK(HW, DEBUG,
 		"%s:addr=%d, reg=%d, data_in=0x%04X, data_out=0x%04X\n",
 		dir == mdi_read ? "READ" : "WRITE", addr, reg, data, data_out);
@@ -877,9 +870,9 @@
 	if(nic->mac == mac_unknown)
 		nic->mac = mac_82557_D100_A;
 
-	nic->params.rfds = rfds; 
-	nic->params.cbs = cbs; 
-	
+	nic->params.rfds = rfds;
+	nic->params.cbs = cbs;
+
 	/* Quadwords to DMA into FIFO before starting frame transmit */
 	nic->tx_threshold = 0xE0;
 
@@ -905,9 +898,9 @@
 	u8 *c = (u8 *)config;
 
 	cb->command = cpu_to_le16(cb_config);
-				
+
 	memset(config, 0, sizeof(struct config));
-	
+
 	config->byte_count = 0x16;		/* bytes in this struct */
 	config->rx_fifo_limit = 0x8;		/* bytes in FIFO before DMA */
 	config->direct_rx_dma = 0x1;		/* reserved */
@@ -938,7 +931,7 @@
 
 	if(nic->mii.force_media && nic->mii.full_duplex)
 		config->full_duplex_force = 0x1;	/* 1=force, 0=auto */
-		
+
 	if(nic->flags & promiscuous || nic->loopback) {
 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
@@ -947,7 +940,7 @@
 
 	if(nic->flags & multicast_all)
 		config->multicast_all = 0x1;		/* 1=accept, 0=no */
-	
+
 	if(!(nic->flags & wol_magic))
 		config->magic_packet_disable = 0x1;	/* 1=off, 0=on */
 
@@ -961,7 +954,7 @@
 		else
 			config->standard_stat_counter = 0x0;
 	}
-	
+
 	DPRINTK(HW, DEBUG, "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
 		c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
 	DPRINTK(HW, DEBUG, "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
@@ -1007,7 +1000,7 @@
 	DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
 	if(addr == 32)
 		return -EAGAIN;
-	
+
 	/* Selected the phy and isolate the rest */
 	for(addr = 0; addr < 32; addr++) {
 		if(addr != nic->mii.phy_id) {
@@ -1018,13 +1011,13 @@
 				bmcr & ~BMCR_ISOLATE);
 		}
 	}
-	
+
 	/* Get phy ID */
 	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
 	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
 	nic->phy = (u32)id_hi << 16 | (u32)id_lo;
 	DPRINTK(HW, DEBUG, "phy ID = 0x%08X\n", nic->phy);
-		
+
 	/* Handle National tx phy */
 	if(nic->phy == phy_nsc_tx) {
 		/* Disable congestion control */
@@ -1033,7 +1026,7 @@
 		cong &= ~NSC_CONG_ENABLE;
 		mdio_write(netdev, nic->mii.phy_id, MII_NSC_CONG, cong);
 	}
-	
+
 	if(nic->mac >= mac_82550_D102)
 		/* enable/disable MDI/MDI-X auto-switching */
 		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
@@ -1045,7 +1038,7 @@
 static int e100_hw_init(struct nic *nic)
 {
 	int err;
-	
+
 	e100_hw_reset(nic);
 
 	DPRINTK(HW, ERR, "e100_hw_init\n");
@@ -1062,7 +1055,7 @@
 		return err;
 	if((err = e100_exec_cb(nic, NULL, e100_setup_iaaddr)))
 		return err;
-	if((err = e100_exec_cmd(nic, cuc_dump_addr, 
+	if((err = e100_exec_cmd(nic, cuc_dump_addr,
 		nic->dma_addr + offsetof(struct mem, stats))))
 		return err;
 	if((err = e100_exec_cmd(nic, cuc_dump_reset, 0)))
@@ -1117,7 +1110,7 @@
 		&s->complete;
 
 	/* Device's stats reporting may take several microseconds to
-	 * complete, so where always waiting for results of the 
+	 * complete, so where always waiting for results of the
 	 * previous command. */
 
 	if(*complete == le32_to_cpu(0x0000A007)) {
@@ -1203,10 +1196,10 @@
 	} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
 		DPRINTK(LINK, INFO, "link down\n");
 	}
-	
+
 	mii_check_link(&nic->mii);
-	
-	/* Software generated interrupt to recover from (rare) Rx 
+
+	/* Software generated interrupt to recover from (rare) Rx
 	 * allocation failure */
 	writeb(irq_sw_gen, &nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
@@ -1269,7 +1262,7 @@
 	for(cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
-		if(likely(cb->skb != NULL)) {
+		if(likely(cb->skb)) {
 			nic->net_stats.tx_packets++;
 			nic->net_stats.tx_bytes += cb->skb->len;
 
@@ -1283,7 +1276,7 @@
 		cb->status = 0;
 		nic->cbs_avail++;
 	}
-	
+
 	spin_unlock(&nic->cb_lock);
 
 	/* Recover from running out of Tx resources in xmit_frame */
@@ -1293,7 +1286,7 @@
 	return tx_cleaned;
 }
 
-static void e100_clean_cbs(struct nic *nic, int free_mem)
+static void e100_clean_cbs(struct nic *nic)
 {
 	if(nic->cbs) {
 		while(nic->cb_to_clean != nic->cb_to_use) {
@@ -1308,13 +1301,11 @@
 			nic->cb_to_clean = nic->cb_to_clean->next;
 		}
 		nic->cbs_avail = nic->params.cbs.count;
-		if(free_mem) {
-			pci_free_consistent(nic->pdev, 
-				sizeof(struct cb) * nic->params.cbs.count, 
-				nic->cbs, nic->cbs_dma_addr);
-			nic->cbs = NULL;
-			nic->cbs_avail = 0;
-		}
+		pci_free_consistent(nic->pdev,
+			sizeof(struct cb) * nic->params.cbs.count,
+			nic->cbs, nic->cbs_dma_addr);
+		nic->cbs = NULL;
+		nic->cbs_avail = 0;
 	}
 	nic->cuc_cmd = cuc_start;
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean =
@@ -1325,25 +1316,25 @@
 {
 	struct cb *cb;
 	unsigned int i, count = nic->params.cbs.count;
-	
+
 	nic->cuc_cmd = cuc_start;
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = NULL;
 	nic->cbs_avail = 0;
-	
-	nic->cbs = pci_alloc_consistent(nic->pdev, 
+
+	nic->cbs = pci_alloc_consistent(nic->pdev,
 		sizeof(struct cb) * count, &nic->cbs_dma_addr);
 	if(!nic->cbs)
 		return -ENOMEM;
 
 	for(cb = nic->cbs, i = 0; i < count; cb++, i++) {
 		cb->next = (i + 1 < count) ? cb + 1 : nic->cbs;
-		cb->prev = (i == 0) ? nic->cbs + count - 1 : cb - 1;	
-		
+		cb->prev = (i == 0) ? nic->cbs + count - 1 : cb - 1;
+
 		cb->dma_addr = nic->cbs_dma_addr + i * sizeof(struct cb);
 		cb->link = cpu_to_le32(nic->cbs_dma_addr +
 			((i+1) % count) * sizeof(struct cb));
 	}
-	
+
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = nic->cbs;
 	nic->cbs_avail = count;
 
@@ -1617,7 +1608,7 @@
 	   !(nic->eeprom[eeprom_config_asf] & eeprom_gcl) &&
 	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE));
 }
-	
+
 static int e100_up(struct nic *nic)
 {
 	int err;
@@ -1642,7 +1633,7 @@
 	del_timer_sync(&nic->watchdog);
 	netif_stop_queue(nic->netdev);
 err_clean_cbs:
-	e100_clean_cbs(nic, 1);
+	e100_clean_cbs(nic);
 err_rx_clean_list:
 	e100_rx_clean_list(nic);
 	return err;
@@ -1655,7 +1646,7 @@
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
 	netif_stop_queue(nic->netdev);
-	e100_clean_cbs(nic, 1);
+	e100_clean_cbs(nic);
 	e100_rx_clean_list(nic);
 }
 
@@ -1697,7 +1688,7 @@
 			BMCR_LOOPBACK);
 
 	e100_start_receiver(nic);
-	
+
 	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
 		err = -ENOMEM;
 		goto err_loopback_none;
@@ -1717,7 +1708,7 @@
 	mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, 0);
 	nic->loopback = lb_none;
 	e100_hw_init(nic);
-	e100_clean_cbs(nic, 1);
+	e100_clean_cbs(nic);
 err_clean_rx:
 	e100_rx_clean_list(nic);
 	return err;
@@ -1745,7 +1736,7 @@
 	struct nic *nic = netdev->priv;
 	return mii_ethtool_gset(&nic->mii, cmd);
 }
-  
+
 static int e100_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
 	struct nic *nic = netdev->priv;
@@ -1757,7 +1748,7 @@
 
 	return err;
 }
-  
+
 static void e100_get_drvinfo(struct net_device *netdev,
 	struct ethtool_drvinfo *info)
 {
@@ -1767,7 +1758,7 @@
 	strcpy(info->fw_version, "N/A");
 	strcpy(info->bus_info, pci_name(nic->pdev));
 }
-  
+
 static int e100_get_regs_len(struct net_device *netdev)
 {
 	struct nic *nic = netdev->priv;
@@ -1805,11 +1796,11 @@
 	wol->supported = (nic->mac >= mac_82558_D101_A4) ?  WAKE_MAGIC : 0;
 	wol->wolopts = (nic->flags & wol_magic) ? WAKE_MAGIC : 0;
 }
-  
+
 static int e100_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct nic *nic = netdev->priv;
-  
+
 	if(wol->wolopts != WAKE_MAGIC && wol->wolopts != 0)
 		return -EOPNOTSUPP;
 
@@ -1820,22 +1811,22 @@
 
 	pci_enable_wake(nic->pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
 	e100_exec_cb(nic, NULL, e100_configure);
-  
+
 	return 0;
 }
-  
+
 static u32 e100_get_msglevel(struct net_device *netdev)
 {
 	struct nic *nic = netdev->priv;
 	return nic->msg_enable;
 }
-  
+
 static void e100_set_msglevel(struct net_device *netdev, u32 value)
 {
 	struct nic *nic = netdev->priv;
 	nic->msg_enable = value;
 }
-  
+
 static int e100_nway_reset(struct net_device *netdev)
 {
 	struct nic *nic = netdev->priv;
@@ -1847,7 +1838,7 @@
 	struct nic *nic = netdev->priv;
 	return mii_link_ok(&nic->mii);
 }
-  
+
 static int e100_get_eeprom_len(struct net_device *netdev)
 {
 	struct nic *nic = netdev->priv;
@@ -1859,7 +1850,7 @@
 	struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct nic *nic = netdev->priv;
-	
+
 	eeprom->magic = E100_EEPROM_MAGIC;
 	memcpy(bytes, &((u8 *)nic->eeprom)[eeprom->offset], eeprom->len);
 
@@ -1870,7 +1861,7 @@
 	struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct nic *nic = netdev->priv;
-	
+
 	if(eeprom->magic != E100_EEPROM_MAGIC)
 		return -EINVAL;
 	memcpy(&((u8 *)nic->eeprom)[eeprom->offset], bytes, eeprom->len);
@@ -1885,7 +1876,7 @@
 	struct nic *nic = netdev->priv;
 	struct param_range *rfds = &nic->params.rfds;
 	struct param_range *cbs = &nic->params.cbs;
-  
+
 	ring->rx_max_pending = rfds->max;
 	ring->tx_max_pending = cbs->max;
 	ring->rx_mini_max_pending = 0;
@@ -1895,14 +1886,14 @@
 	ring->rx_mini_pending = 0;
 	ring->rx_jumbo_pending = 0;
 }
-  
+
 static int e100_set_ringparam(struct net_device *netdev,
 	struct ethtool_ringparam *ring)
 {
 	struct nic *nic = netdev->priv;
 	struct param_range *rfds = &nic->params.rfds;
 	struct param_range *cbs = &nic->params.cbs;
-  
+
 	if(netif_running(netdev))
 		e100_down(nic);
 	rfds->count = max(ring->rx_pending, rfds->min);
@@ -1911,11 +1902,11 @@
 	cbs->count = min(cbs->count, cbs->max);
 	if(netif_running(netdev))
 		e100_up(nic);
-		
+
 	return 0;
 }
-  
-static char e100_gstrings_test[][ETH_GSTRING_LEN] = {
+
+static const char e100_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Link test     (on/offline)",
 	"Eeprom test   (on/offline)",
 	"Self test        (offline)",
@@ -1966,7 +1957,7 @@
 	return 0;
 }
 
-static char e100_gstrings_stats[][ETH_GSTRING_LEN] = {
+static const char e100_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
 	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
@@ -1974,7 +1965,7 @@
 	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
 	"tx_heartbeat_errors", "tx_window_errors",
 	/* device-specific stats */
-	"tx_deferred", "tx_single_collisions", "tx_multi_collisions", 
+	"tx_deferred", "tx_single_collisions", "tx_multi_collisions",
 	"tx_flow_control_pause", "rx_flow_control_pause",
 	"rx_flow_control_unsupported", "tx_tco_packets", "rx_tco_packets",
 };
@@ -2083,13 +2074,13 @@
 	return 0;
 }
 
-static int __devinit e100_probe(struct pci_dev *pdev, 
+static int __devinit e100_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct nic *nic;
 	int err;
-	
+
 	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
 		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
 			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
@@ -2241,7 +2232,7 @@
 	}
 }
 
-#ifdef CONFIG_PM			
+#ifdef CONFIG_PM
 static int e100_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2272,7 +2263,7 @@
 	netif_device_attach(netdev);
 	if(netif_running(netdev))
 		e100_up(nic);
-	
+
 	return 0;
 }
 #endif
@@ -2282,7 +2273,7 @@
 	.id_table =     e100_id_table,
 	.probe =        e100_probe,
 	.remove =       __devexit_p(e100_remove),
-#ifdef CONFIG_PM			
+#ifdef CONFIG_PM
 	.suspend =      e100_suspend,
 	.resume =       e100_resume,
 #endif
