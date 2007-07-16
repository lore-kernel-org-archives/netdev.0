From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Mon, 16 Jul 2007 18:57:21 -0400
Message-ID: <20070716225721.GA2127@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:35176 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120AbXGPW5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:57:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor fixes and cleanups, and a wireless pull from Linville.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/8139cp.c                           |   27 +-
 drivers/net/Kconfig                            |    2 +-
 drivers/net/arm/Kconfig                        |    1 +
 drivers/net/atl1/atl1.h                        |  156 +-
 drivers/net/atl1/atl1_main.c                   | 2176 ++++++++++++------------
 drivers/net/ehea/ehea.h                        |   23 +-
 drivers/net/ehea/ehea_main.c                   |  144 ++-
 drivers/net/ehea/ehea_phyp.h                   |    3 +
 drivers/net/ehea/ehea_qmr.c                    |  156 ++-
 drivers/net/ehea/ehea_qmr.h                    |   14 +-
 drivers/net/forcedeth.c                        |  162 ++-
 drivers/net/gianfar_mii.c                      |    1 -
 drivers/net/macb.c                             |  563 ++++---
 drivers/net/macb.h                             |   10 +-
 drivers/net/myri10ge/myri10ge.c                |    6 -
 drivers/net/s2io.c                             |    4 +-
 drivers/net/usb/cdc_subset.c                   |    3 +
 drivers/net/wireless/airo.c                    |  208 ++--
 drivers/net/wireless/ipw2100.c                 |   11 +-
 drivers/net/wireless/ipw2200.c                 |    5 +-
 drivers/net/wireless/libertas/cmd.c            |    2 +-
 drivers/net/wireless/libertas/rx.c             |    1 -
 drivers/net/wireless/libertas/version.h        |    1 -
 drivers/net/wireless/libertas/wext.c           |    3 -
 drivers/net/wireless/prism54/isl_ioctl.c       |   22 +-
 drivers/net/wireless/rtl8187_rtl8225.c         |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c        |   88 +-
 drivers/net/wireless/zd1211rw/zd_chip.h        |   13 +-
 drivers/net/wireless/zd1211rw/zd_mac.c         |   59 +-
 drivers/net/wireless/zd1211rw/zd_mac.h         |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf.c          |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf.h          |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c   |   12 +-
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c  |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c   |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c   |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c         |   98 +-
 drivers/net/wireless/zd1211rw/zd_usb.h         |    3 +
 drivers/s390/net/qeth.h                        |    9 +
 drivers/s390/net/qeth_main.c                   |  183 ++-
 drivers/s390/net/qeth_proc.c                   |    6 +
 include/asm-arm/arch-at91/board.h              |    1 +
 include/asm-avr32/arch-at32ap/board.h          |    1 +
 net/ieee80211/softmac/ieee80211softmac_assoc.c |    5 +-
 44 files changed, 2400 insertions(+), 1800 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/version.h

Adrian Bunk (1):
      drivers/net/wireless/libertas/wext.c: remove dead code

Ayaz Abdulla (3):
      forcedeth bug fix: cicada phy
      forcedeth bug fix: vitesse phy
      forcedeth bug fix: realtek phy

Brice Goglin (1):
      myri10ge: Remove nonsensical limit in the tx done routine

Dan Williams (1):
      libertas: fix disabling WPA

Daniel Drake (4):
      zd1211rw: Allow channels 1-11 for unrecognised regulatory domains
      zd1211rw: Detect more AL2230S radios
      zd1211rw: Add ID for Buffalo WLI-U2-KG54L
      zd1211rw: Defer firmware load until first ifup

Francois Romieu (1):
      8139cp: implement the missing dev->tx_timeout

Frank Blaschka (2):
      s390: scatter-gather for inbound traffic in qeth driver
      s390: add barriers to qeth driver

Holger Schurig (1):
      libertas: fix use-after-free in rx path

Jay Cliburn (5):
      atl1: remove irq_sem
      atl1: header file cleanup
      atl1: cleanup atl1_main
      atl1: fix excessively indented code
      atl1: reorder atl1_main functions

Jean Tourrilhes (1):
      softmac: Fix ESSID problem

John Donoghue (1):
      EP93XX_ETH must select MII

Kumar Gala (1):
      gianfar: kill unused header

Matthias Kaehlcke (1):
      use list_for_each_entry() for iteration in Prism 54 driver

Micah Gruber (1):
      Fix a potential NULL pointer dereference in free_shared_mem() in drivers/net/s2io.c

Michael Wu (1):
      rtl8187: fix endianness issue in rtl8225 register writing

Michal Schmidt (5):
      airo: disable the PCI device when unloading module
      airo: delay some initialization until the netdev is up
      airo: fix a race causing initialization failures
      airo: simpler calling convention for enable_MAC()
      airo: start with radio off

Patrice Vilchez (1):
      macb: Add multicast capability

Robert P. J. Day (1):
      WIRELESS: Remove clearly obsolete libertas/version.h file.

Stephen Hemminger (2):
      ipw2200: rf kill switch polling power saving
      ipw2100: RF kill switch timer power save

Thomas Klein (1):
      eHEA: Introducing support vor DLPAR memory add

frederic RODO (1):
      macb: Use generic PHY layer

jing xiang (1):
      cdc-subset to support new vendor/product ID

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 58bbc3e..f5223ec 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -26,7 +26,6 @@
 
 	TODO:
 	* Test Tx checksumming thoroughly
-	* Implement dev->tx_timeout
 
 	Low priority TODO:
 	* Complete reset on PciErr
@@ -1218,6 +1217,30 @@ static int cp_close (struct net_device *dev)
 	return 0;
 }
 
+static void cp_tx_timeout(struct net_device *dev)
+{
+	struct cp_private *cp = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+
+	printk(KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x %4x\n",
+	       dev->name, cpr8(Cmd), cpr16(CpCmd),
+	       cpr16(IntrStatus), cpr16(IntrMask));
+
+	spin_lock_irqsave(&cp->lock, flags);
+
+	cp_stop_hw(cp);
+	cp_clean_rings(cp);
+	rc = cp_init_rings(cp);
+	cp_start_hw(cp);
+
+	netif_wake_queue(dev);
+
+	spin_unlock_irqrestore(&cp->lock, flags);
+
+	return;
+}
+
 #ifdef BROKEN
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -1923,10 +1946,8 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->change_mtu = cp_change_mtu;
 #endif
 	dev->ethtool_ops = &cp_ethtool_ops;
-#if 0
 	dev->tx_timeout = cp_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#endif
 
 #if CP_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b941c74..4b9b7fe 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -187,7 +187,7 @@ config MII
 config MACB
 	tristate "Atmel MACB support"
 	depends on AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263
-	select MII
+	select PHYLIB
 	help
 	  The Atmel MACB ethernet interface is found on many AT32 and AT91
 	  parts. Say Y to include support for the MACB chip.
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 5bf2d33..f9cc2b6 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -43,6 +43,7 @@ config ARM_AT91_ETHER
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
 	depends on ARM && ARCH_EP93XX
+	select MII
 	help
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
 	  Say Y if you are building a kernel for EP93xx based devices.
diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index b1c6034..991c8b9 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -43,6 +43,7 @@ extern const struct ethtool_ops atl1_ethtool_ops;
 struct atl1_adapter;
 
 #define ATL1_MAX_INTR		3
+#define ATL1_MAX_TX_BUF_LEN	0x3000	/* 12288 bytes */
 
 #define ATL1_DEFAULT_TPD	256
 #define ATL1_MAX_TPD		1024
@@ -57,29 +58,45 @@ struct atl1_adapter;
 #define ATL1_RRD_DESC(R, i)	ATL1_GET_DESC(R, i, struct rx_return_desc)
 
 /*
+ * This detached comment is preserved for documentation purposes only.
+ * It was originally attached to some code that got deleted, but seems
+ * important enough to keep around...
+ *
+ * <begin detached comment>
  * Some workarounds require millisecond delays and are run during interrupt
  * context.  Most notably, when establishing link, the phy may need tweaking
  * but cannot process phy register reads/writes faster than millisecond
  * intervals...and we establish link due to a "link status change" interrupt.
+ * <end detached comment>
+ */
+
+/*
+ * atl1_ring_header represents a single, contiguous block of DMA space
+ * mapped for the three descriptor rings (tpd, rfd, rrd) and the two
+ * message blocks (cmb, smb) described below
  */
+struct atl1_ring_header {
+	void *desc;		/* virtual address */
+	dma_addr_t dma;		/* physical address*/
+	unsigned int size;	/* length in bytes */
+};
 
 /*
- * wrapper around a pointer to a socket buffer,
- * so a DMA handle can be stored along with the buffer
+ * atl1_buffer is wrapper around a pointer to a socket buffer
+ * so a DMA handle can be stored along with the skb
  */
 struct atl1_buffer {
-	struct sk_buff *skb;
-	u16 length;
-	u16 alloced;
+	struct sk_buff *skb;	/* socket buffer */
+	u16 length;		/* rx buffer length */
+	u16 alloced;		/* 1 if skb allocated */
 	dma_addr_t dma;
 };
 
-#define MAX_TX_BUF_LEN		0x3000	/* 12KB */
-
+/* transmit packet descriptor (tpd) ring */
 struct atl1_tpd_ring {
-	void *desc;		/* pointer to the descriptor ring memory */
-	dma_addr_t dma;		/* physical adress of the descriptor ring */
-	u16 size;		/* length of descriptor ring in bytes */
+	void *desc;		/* descriptor ring virtual address */
+	dma_addr_t dma;		/* descriptor ring physical address */
+	u16 size;		/* descriptor ring length in bytes */
 	u16 count;		/* number of descriptors in the ring */
 	u16 hw_idx;		/* hardware index */
 	atomic_t next_to_clean;
@@ -87,36 +104,34 @@ struct atl1_tpd_ring {
 	struct atl1_buffer *buffer_info;
 };
 
+/* receive free descriptor (rfd) ring */
 struct atl1_rfd_ring {
-	void *desc;
-	dma_addr_t dma;
-	u16 size;
-	u16 count;
+	void *desc;		/* descriptor ring virtual address */
+	dma_addr_t dma;		/* descriptor ring physical address */
+	u16 size;		/* descriptor ring length in bytes */
+	u16 count;		/* number of descriptors in the ring */
 	atomic_t next_to_use;
 	u16 next_to_clean;
 	struct atl1_buffer *buffer_info;
 };
 
+/* receive return descriptor (rrd) ring */
 struct atl1_rrd_ring {
-	void *desc;
-	dma_addr_t dma;
-	unsigned int size;
-	u16 count;
+	void *desc;		/* descriptor ring virtual address */
+	dma_addr_t dma;		/* descriptor ring physical address */
+	unsigned int size;	/* descriptor ring length in bytes */
+	u16 count;		/* number of descriptors in the ring */
 	u16 next_to_use;
 	atomic_t next_to_clean;
 };
 
-struct atl1_ring_header {
-	void *desc;		/* pointer to the descriptor ring memory */
-	dma_addr_t dma;		/* physical adress of the descriptor ring */
-	unsigned int size;	/* length of descriptor ring in bytes */
-};
-
+/* coalescing message block (cmb) */
 struct atl1_cmb {
 	struct coals_msg_block *cmb;
 	dma_addr_t dma;
 };
 
+/* statistics message block (smb) */
 struct atl1_smb {
 	struct stats_msg_block *smb;
 	dma_addr_t dma;
@@ -141,24 +156,26 @@ struct atl1_sft_stats {
 	u64 tx_aborted_errors;
 	u64 tx_window_errors;
 	u64 tx_carrier_errors;
-
-	u64 tx_pause;		/* num Pause packet transmitted. */
-	u64 excecol;		/* num tx packets aborted due to excessive collisions. */
-	u64 deffer;		/* num deferred tx packets */
-	u64 scc;		/* num packets subsequently transmitted successfully w/ single prior collision. */
-	u64 mcc;		/* num packets subsequently transmitted successfully w/ multiple prior collisions. */
+	u64 tx_pause;		/* num pause packets transmitted. */
+	u64 excecol;		/* num tx packets w/ excessive collisions. */
+	u64 deffer;		/* num tx packets deferred */
+	u64 scc;		/* num packets subsequently transmitted
+				 * successfully w/ single prior collision. */
+	u64 mcc;		/* num packets subsequently transmitted
+				 * successfully w/ multiple prior collisions. */
 	u64 latecol;		/* num tx packets  w/ late collisions. */
-	u64 tx_underun;		/* num tx packets aborted due to transmit FIFO underrun, or TRD FIFO underrun */
-	u64 tx_trunc;		/* num tx packets truncated due to size exceeding MTU, regardless whether truncated by Selene or not. (The name doesn't really reflect the meaning in this case.) */
+	u64 tx_underun;		/* num tx packets aborted due to transmit
+				 * FIFO underrun, or TRD FIFO underrun */
+	u64 tx_trunc;		/* num tx packets truncated due to size
+				 * exceeding MTU, regardless whether truncated
+				 * by the chip or not. (The name doesn't really
+				 * reflect the meaning in this case.) */
 	u64 rx_pause;		/* num Pause packets received. */
 	u64 rx_rrd_ov;
 	u64 rx_trunc;
 };
 
-/* board specific private data structure */
-#define ATL1_REGS_LEN	8
-
-/* Structure containing variables used by the shared code */
+/* hardware structure */
 struct atl1_hw {
 	u8 __iomem *hw_addr;
 	struct atl1_adapter *back;
@@ -167,24 +184,35 @@ struct atl1_hw {
 	enum atl1_dma_req_block dmar_block;
 	enum atl1_dma_req_block dmaw_block;
 	u8 preamble_len;
-	u8 max_retry;		/* Retransmission maximum, after which the packet will be discarded */
-	u8 jam_ipg;		/* IPG to start JAM for collision based flow control in half-duplex mode. In units of 8-bit time */
-	u8 ipgt;		/* Desired back to back inter-packet gap. The default is 96-bit time */
-	u8 min_ifg;		/* Minimum number of IFG to enforce in between RX frames. Frame gap below such IFP is dropped */
+	u8 max_retry;		/* Retransmission maximum, after which the
+				 * packet will be discarded */
+	u8 jam_ipg;		/* IPG to start JAM for collision based flow
+				 * control in half-duplex mode. In units of
+				 * 8-bit time */
+	u8 ipgt;		/* Desired back to back inter-packet gap.
+				 * The default is 96-bit time */
+	u8 min_ifg;		/* Minimum number of IFG to enforce in between
+				 * receive frames. Frame gap below such IFP
+				 * is dropped */
 	u8 ipgr1;		/* 64bit Carrier-Sense window */
 	u8 ipgr2;		/* 96-bit IPG window */
-	u8 tpd_burst;		/* Number of TPD to prefetch in cache-aligned burst. Each TPD is 16 bytes long */
-	u8 rfd_burst;		/* Number of RFD to prefetch in cache-aligned burst. Each RFD is 12 bytes long */
+	u8 tpd_burst;		/* Number of TPD to prefetch in cache-aligned
+				 * burst. Each TPD is 16 bytes long */
+	u8 rfd_burst;		/* Number of RFD to prefetch in cache-aligned
+				 * burst. Each RFD is 12 bytes long */
 	u8 rfd_fetch_gap;
-	u8 rrd_burst;		/* Threshold number of RRDs that can be retired in a burst. Each RRD is 16 bytes long */
+	u8 rrd_burst;		/* Threshold number of RRDs that can be retired
+				 * in a burst. Each RRD is 16 bytes long */
 	u8 tpd_fetch_th;
 	u8 tpd_fetch_gap;
 	u16 tx_jumbo_task_th;
-	u16 txf_burst;		/* Number of data bytes to read in a cache-aligned burst. Each SRAM entry is
-				   8 bytes long */
-	u16 rx_jumbo_th;	/* Jumbo packet size for non-VLAN packet. VLAN packets should add 4 bytes */
+	u16 txf_burst;		/* Number of data bytes to read in a cache-
+				 * aligned burst. Each SRAM entry is 8 bytes */
+	u16 rx_jumbo_th;	/* Jumbo packet size for non-VLAN packet. VLAN
+				 * packets should add 4 bytes */
 	u16 rx_jumbo_lkah;
-	u16 rrd_ret_timer;	/* RRD retirement timer. Decrement by 1 after every 512ns passes. */
+	u16 rrd_ret_timer;	/* RRD retirement timer. Decrement by 1 after
+				 * every 512ns passes. */
 	u16 lcol;		/* Collision Window */
 
 	u16 cmb_tpd;
@@ -194,20 +222,12 @@ struct atl1_hw {
 	u32 smb_timer;
 	u16 media_type;
 	u16 autoneg_advertised;
-	u16 pci_cmd_word;
 
 	u16 mii_autoneg_adv_reg;
 	u16 mii_1000t_ctrl_reg;
 
-	u32 mem_rang;
-	u32 txcw;
 	u32 max_frame_size;
 	u32 min_frame_size;
-	u32 mc_filter_type;
-	u32 num_mc_addrs;
-	u32 collision_delta;
-	u32 tx_packet_delta;
-	u16 phy_spd_default;
 
 	u16 dev_rev;
 	u8 revision_id;
@@ -215,28 +235,23 @@ struct atl1_hw {
 	/* spi flash */
 	u8 flash_vendor;
 
-	u8 dma_fairness;
 	u8 mac_addr[ETH_ALEN];
 	u8 perm_mac_addr[ETH_ALEN];
 
-	/* bool phy_preamble_sup; */
 	bool phy_configured;
 };
 
 struct atl1_adapter {
-	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
 	struct atl1_sft_stats soft_stats;
-
 	struct vlan_group *vlgrp;
 	u32 rx_buffer_len;
 	u32 wol;
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
 	struct work_struct link_chg_task;
 	struct work_struct pcie_dma_to_rst_task;
@@ -244,9 +259,7 @@ struct atl1_adapter {
 	struct timer_list phy_config_timer;
 	bool phy_timer_pending;
 
-	bool mac_disabled;
-
-	/* All descriptor rings' memory */
+	/* all descriptor rings' memory */
 	struct atl1_ring_header ring_header;
 
 	/* TX */
@@ -259,25 +272,16 @@ struct atl1_adapter {
 	u64 hw_csum_err;
 	u64 hw_csum_good;
 
-	u32 gorcl;
-	u64 gorcl_old;
-
-	/* Interrupt Moderator timer ( 2us resolution) */
-	u16 imt;
-	/* Interrupt Clear timer (2us resolution) */
-	u16 ict;
-
-	/* MII interface info */
-	struct mii_if_info mii;
+	u16 imt;	/* interrupt moderator timer (2us resolution */
+	u16 ict;	/* interrupt clear timer (2us resolution */
+	struct mii_if_info mii;		/* MII interface info */
 
 	/* structs defined in atl1_hw.h */
-	u32 bd_number;		/* board number */
+	u32 bd_number;			/* board number */
 	bool pci_using_64;
 	struct atl1_hw hw;
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
-
-	u32 pci_state[16];
 };
 
 #endif	/* _ATL1_H_ */
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 3bb40dd..f7ac475 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -38,7 +38,7 @@
  * TODO:
  * Fix TSO; tx performance is horrible with TSO enabled.
  * Wake on LAN.
- * Add more ethtool functions, including set ring parameters.
+ * Add more ethtool functions.
  * Fix abstruse irq enable/disable condition described here:
  *	http://marc.theaimsgroup.com/?l=linux-netdev&m=116398508500553&w=2
  *
@@ -162,13 +162,70 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	hw->cmb_tx_timer = 1;	/* about 2us */
 	hw->smb_timer = 100000;	/* about 200ms */
 
-	atomic_set(&adapter->irq_sem, 0);
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);
 
 	return 0;
 }
 
+static int mdio_read(struct net_device *netdev, int phy_id, int reg_num)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	u16 result;
+
+	atl1_read_phy_reg(&adapter->hw, reg_num & 0x1f, &result);
+
+	return result;
+}
+
+static void mdio_write(struct net_device *netdev, int phy_id, int reg_num,
+	int val)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+
+	atl1_write_phy_reg(&adapter->hw, reg_num, val);
+}
+
+/*
+ * atl1_mii_ioctl -
+ * @netdev:
+ * @ifreq:
+ * @cmd:
+ */
+static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
+	int retval;
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	spin_lock_irqsave(&adapter->lock, flags);
+	retval = generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+
+	return retval;
+}
+
+/*
+ * atl1_ioctl -
+ * @netdev:
+ * @ifreq:
+ * @cmd:
+ */
+static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return atl1_mii_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 /*
  * atl1_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
@@ -192,19 +249,22 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 		goto err_nomem;
 	}
 	rfd_ring->buffer_info =
-	    (struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
+		(struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
 
-	/* real ring DMA buffer */
-	ring_header->size = size = sizeof(struct tx_packet_desc) *
-					tpd_ring->count
-	    + sizeof(struct rx_free_desc) * rfd_ring->count
-	    + sizeof(struct rx_return_desc) * rrd_ring->count
-	    + sizeof(struct coals_msg_block)
-	    + sizeof(struct stats_msg_block)
-	    + 40;		/* "40: for 8 bytes align" huh? -- CHS */
+	/* real ring DMA buffer
+	 * each ring/block may need up to 8 bytes for alignment, hence the
+	 * additional 40 bytes tacked onto the end.
+	 */
+	ring_header->size = size =
+		sizeof(struct tx_packet_desc) * tpd_ring->count
+		+ sizeof(struct rx_free_desc) * rfd_ring->count
+		+ sizeof(struct rx_return_desc) * rrd_ring->count
+		+ sizeof(struct coals_msg_block)
+		+ sizeof(struct stats_msg_block)
+		+ 40;
 
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
-						&ring_header->dma);
+		&ring_header->dma);
 	if (unlikely(!ring_header->desc)) {
 		dev_err(&pdev->dev, "pci_alloc_consistent failed\n");
 		goto err_nomem;
@@ -218,8 +278,6 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	tpd_ring->dma += offset;
 	tpd_ring->desc = (u8 *) ring_header->desc + offset;
 	tpd_ring->size = sizeof(struct tx_packet_desc) * tpd_ring->count;
-	atomic_set(&tpd_ring->next_to_use, 0);
-	atomic_set(&tpd_ring->next_to_clean, 0);
 
 	/* init RFD ring */
 	rfd_ring->dma = tpd_ring->dma + tpd_ring->size;
@@ -227,9 +285,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	rfd_ring->dma += offset;
 	rfd_ring->desc = (u8 *) tpd_ring->desc + (tpd_ring->size + offset);
 	rfd_ring->size = sizeof(struct rx_free_desc) * rfd_ring->count;
-	rfd_ring->next_to_clean = 0;
-	/* rfd_ring->next_to_use = rfd_ring->count - 1; */
-	atomic_set(&rfd_ring->next_to_use, 0);
+
 
 	/* init RRD ring */
 	rrd_ring->dma = rfd_ring->dma + rfd_ring->size;
@@ -237,23 +293,22 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	rrd_ring->dma += offset;
 	rrd_ring->desc = (u8 *) rfd_ring->desc + (rfd_ring->size + offset);
 	rrd_ring->size = sizeof(struct rx_return_desc) * rrd_ring->count;
-	rrd_ring->next_to_use = 0;
-	atomic_set(&rrd_ring->next_to_clean, 0);
+
 
 	/* init CMB */
 	adapter->cmb.dma = rrd_ring->dma + rrd_ring->size;
 	offset = (adapter->cmb.dma & 0x7) ? (8 - (adapter->cmb.dma & 0x7)) : 0;
 	adapter->cmb.dma += offset;
-	adapter->cmb.cmb =
-	    (struct coals_msg_block *) ((u8 *) rrd_ring->desc +
-				   (rrd_ring->size + offset));
+	adapter->cmb.cmb = (struct coals_msg_block *)
+		((u8 *) rrd_ring->desc + (rrd_ring->size + offset));
 
 	/* init SMB */
 	adapter->smb.dma = adapter->cmb.dma + sizeof(struct coals_msg_block);
 	offset = (adapter->smb.dma & 0x7) ? (8 - (adapter->smb.dma & 0x7)) : 0;
 	adapter->smb.dma += offset;
 	adapter->smb.smb = (struct stats_msg_block *)
-	    ((u8 *) adapter->cmb.cmb + (sizeof(struct coals_msg_block) + offset));
+		((u8 *) adapter->cmb.cmb +
+		(sizeof(struct coals_msg_block) + offset));
 
 	return ATL1_SUCCESS;
 
@@ -262,559 +317,133 @@ err_nomem:
 	return -ENOMEM;
 }
 
-/*
- * atl1_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- */
-static void atl1_irq_enable(struct atl1_adapter *adapter)
-{
-	if (likely(!atomic_dec_and_test(&adapter->irq_sem)))
-		iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
-}
-
-static void atl1_clear_phy_int(struct atl1_adapter *adapter)
-{
-	u16 phy_data;
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
-static void atl1_inc_smb(struct atl1_adapter *adapter)
-{
-	struct stats_msg_block *smb = adapter->smb.smb;
-
-	/* Fill out the OS statistics structure */
-	adapter->soft_stats.rx_packets += smb->rx_ok;
-	adapter->soft_stats.tx_packets += smb->tx_ok;
-	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
-	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
-	adapter->soft_stats.multicast += smb->rx_mcast;
-	adapter->soft_stats.collisions += (smb->tx_1_col +
-					   smb->tx_2_col * 2 +
-					   smb->tx_late_col +
-					   smb->tx_abort_col *
-					   adapter->hw.max_retry);
-
-	/* Rx Errors */
-	adapter->soft_stats.rx_errors += (smb->rx_frag +
-					  smb->rx_fcs_err +
-					  smb->rx_len_err +
-					  smb->rx_sz_ov +
-					  smb->rx_rxf_ov +
-					  smb->rx_rrd_ov + smb->rx_align_err);
-	adapter->soft_stats.rx_fifo_errors += smb->rx_rxf_ov;
-	adapter->soft_stats.rx_length_errors += smb->rx_len_err;
-	adapter->soft_stats.rx_crc_errors += smb->rx_fcs_err;
-	adapter->soft_stats.rx_frame_errors += smb->rx_align_err;
-	adapter->soft_stats.rx_missed_errors += (smb->rx_rrd_ov +
-						 smb->rx_rxf_ov);
-
-	adapter->soft_stats.rx_pause += smb->rx_pause;
-	adapter->soft_stats.rx_rrd_ov += smb->rx_rrd_ov;
-	adapter->soft_stats.rx_trunc += smb->rx_sz_ov;
-
-	/* Tx Errors */
-	adapter->soft_stats.tx_errors += (smb->tx_late_col +
-					  smb->tx_abort_col +
-					  smb->tx_underrun + smb->tx_trunc);
-	adapter->soft_stats.tx_fifo_errors += smb->tx_underrun;
-	adapter->soft_stats.tx_aborted_errors += smb->tx_abort_col;
-	adapter->soft_stats.tx_window_errors += smb->tx_late_col;
-
-	adapter->soft_stats.excecol += smb->tx_abort_col;
-	adapter->soft_stats.deffer += smb->tx_defer;
-	adapter->soft_stats.scc += smb->tx_1_col;
-	adapter->soft_stats.mcc += smb->tx_2_col;
-	adapter->soft_stats.latecol += smb->tx_late_col;
-	adapter->soft_stats.tx_underun += smb->tx_underrun;
-	adapter->soft_stats.tx_trunc += smb->tx_trunc;
-	adapter->soft_stats.tx_pause += smb->tx_pause;
-
-	adapter->net_stats.rx_packets = adapter->soft_stats.rx_packets;
-	adapter->net_stats.tx_packets = adapter->soft_stats.tx_packets;
-	adapter->net_stats.rx_bytes = adapter->soft_stats.rx_bytes;
-	adapter->net_stats.tx_bytes = adapter->soft_stats.tx_bytes;
-	adapter->net_stats.multicast = adapter->soft_stats.multicast;
-	adapter->net_stats.collisions = adapter->soft_stats.collisions;
-	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
-	adapter->net_stats.rx_over_errors =
-	    adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.rx_length_errors =
-	    adapter->soft_stats.rx_length_errors;
-	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
-	adapter->net_stats.rx_frame_errors =
-	    adapter->soft_stats.rx_frame_errors;
-	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
-	adapter->net_stats.rx_missed_errors =
-	    adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
-	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
-	adapter->net_stats.tx_aborted_errors =
-	    adapter->soft_stats.tx_aborted_errors;
-	adapter->net_stats.tx_window_errors =
-	    adapter->soft_stats.tx_window_errors;
-	adapter->net_stats.tx_carrier_errors =
-	    adapter->soft_stats.tx_carrier_errors;
-}
-
-static void atl1_rx_checksum(struct atl1_adapter *adapter,
-					struct rx_return_desc *rrd,
-					struct sk_buff *skb)
+void atl1_init_ring_ptrs(struct atl1_adapter *adapter)
 {
-	skb->ip_summed = CHECKSUM_NONE;
-
-	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
-					ERR_FLAG_CODE | ERR_FLAG_OV)) {
-			adapter->hw_csum_err++;
-			dev_dbg(&adapter->pdev->dev, "rx checksum error\n");
-			return;
-		}
-	}
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
 
-	/* not IPv4 */
-	if (!(rrd->pkt_flg & PACKET_FLAG_IPV4))
-		/* checksum is invalid, but it's not an IPv4 pkt, so ok */
-		return;
+	atomic_set(&tpd_ring->next_to_use, 0);
+	atomic_set(&tpd_ring->next_to_clean, 0);
 
-	/* IPv4 packet */
-	if (likely(!(rrd->err_flg &
-		(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM)))) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		adapter->hw_csum_good++;
-		return;
-	}
+	rfd_ring->next_to_clean = 0;
+	atomic_set(&rfd_ring->next_to_use, 0);
 
-	/* IPv4, but hardware thinks its checksum is wrong */
-	dev_dbg(&adapter->pdev->dev,
-		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
-		rrd->pkt_flg, rrd->err_flg);
-	skb->ip_summed = CHECKSUM_COMPLETE;
-	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
-	adapter->hw_csum_err++;
-	return;
+	rrd_ring->next_to_use = 0;
+	atomic_set(&rrd_ring->next_to_clean, 0);
 }
 
 /*
- * atl1_alloc_rx_buffers - Replace used receive buffers
- * @adapter: address of board private structure
+ * atl1_clean_rx_ring - Free RFD Buffers
+ * @adapter: board private structure
  */
-static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
-{
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-	struct pci_dev *pdev = adapter->pdev;
-	struct page *page;
-	unsigned long offset;
-	struct atl1_buffer *buffer_info, *next_info;
-	struct sk_buff *skb;
-	u16 num_alloc = 0;
-	u16 rfd_next_to_use, next_next;
-	struct rx_free_desc *rfd_desc;
-
-	next_next = rfd_next_to_use = atomic_read(&rfd_ring->next_to_use);
-	if (++next_next == rfd_ring->count)
-		next_next = 0;
-	buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
-	next_info = &rfd_ring->buffer_info[next_next];
-
-	while (!buffer_info->alloced && !next_info->alloced) {
-		if (buffer_info->skb) {
-			buffer_info->alloced = 1;
-			goto next;
-		}
-
-		rfd_desc = ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
-
-		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
-		if (unlikely(!skb)) {	/* Better luck next round */
-			adapter->net_stats.rx_dropped++;
-			break;
-		}
-
-		/*
-		 * Make buffer alignment 2 beyond a 16 byte boundary
-		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed
-		 */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		buffer_info->alloced = 1;
-		buffer_info->skb = skb;
-		buffer_info->length = (u16) adapter->rx_buffer_len;
-		page = virt_to_page(skb->data);
-		offset = (unsigned long)skb->data & ~PAGE_MASK;
-		buffer_info->dma = pci_map_page(pdev, page, offset,
-						adapter->rx_buffer_len,
-						PCI_DMA_FROMDEVICE);
-		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
-		rfd_desc->buf_len = cpu_to_le16(adapter->rx_buffer_len);
-		rfd_desc->coalese = 0;
-
-next:
-		rfd_next_to_use = next_next;
-		if (unlikely(++next_next == rfd_ring->count))
-			next_next = 0;
-
-		buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
-		next_info = &rfd_ring->buffer_info[next_next];
-		num_alloc++;
-	}
-
-	if (num_alloc) {
-		/*
-		 * Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64).
-		 */
-		wmb();
-		atomic_set(&rfd_ring->next_to_use, (int)rfd_next_to_use);
-	}
-	return num_alloc;
-}
-
-static void atl1_intr_rx(struct atl1_adapter *adapter)
+static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 {
-	int i, count;
-	u16 length;
-	u16 rrd_next_to_clean;
-	u32 value;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
 	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1_buffer *buffer_info;
-	struct rx_return_desc *rrd;
-	struct sk_buff *skb;
-
-	count = 0;
-
-	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
-
-	while (1) {
-		rrd = ATL1_RRD_DESC(rrd_ring, rrd_next_to_clean);
-		i = 1;
-		if (likely(rrd->xsz.valid)) {	/* packet valid */
-chk_rrd:
-			/* check rrd status */
-			if (likely(rrd->num_buf == 1))
-				goto rrd_ok;
-
-			/* rrd seems to be bad */
-			if (unlikely(i-- > 0)) {
-				/* rrd may not be DMAed completely */
-				dev_dbg(&adapter->pdev->dev,
-					"incomplete RRD DMA transfer\n");
-				udelay(1);
-				goto chk_rrd;
-			}
-			/* bad rrd */
-			dev_dbg(&adapter->pdev->dev, "bad RRD\n");
-			/* see if update RFD index */
-			if (rrd->num_buf > 1) {
-				u16 num_buf;
-				num_buf =
-				    (rrd->xsz.xsum_sz.pkt_size +
-				     adapter->rx_buffer_len -
-				     1) / adapter->rx_buffer_len;
-				if (rrd->num_buf == num_buf) {
-					/* clean alloc flag for bad rrd */
-					while (rfd_ring->next_to_clean !=
-					       (rrd->buf_indx + num_buf)) {
-						rfd_ring->buffer_info[rfd_ring->
-								      next_to_clean].alloced = 0;
-						if (++rfd_ring->next_to_clean ==
-						    rfd_ring->count) {
-							rfd_ring->
-							    next_to_clean = 0;
-						}
-					}
-				}
-			}
-
-			/* update rrd */
-			rrd->xsz.valid = 0;
-			if (++rrd_next_to_clean == rrd_ring->count)
-				rrd_next_to_clean = 0;
-			count++;
-			continue;
-		} else {	/* current rrd still not be updated */
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long size;
+	unsigned int i;
 
-			break;
-		}
-rrd_ok:
-		/* clean alloc flag for bad rrd */
-		while (rfd_ring->next_to_clean != rrd->buf_indx) {
-			rfd_ring->buffer_info[rfd_ring->next_to_clean].alloced =
-			    0;
-			if (++rfd_ring->next_to_clean == rfd_ring->count)
-				rfd_ring->next_to_clean = 0;
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rfd_ring->count; i++) {
+		buffer_info = &rfd_ring->buffer_info[i];
+		if (buffer_info->dma) {
+			pci_unmap_page(pdev, buffer_info->dma,
+				buffer_info->length, PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
 		}
-
-		buffer_info = &rfd_ring->buffer_info[rrd->buf_indx];
-		if (++rfd_ring->next_to_clean == rfd_ring->count)
-			rfd_ring->next_to_clean = 0;
-
-		/* update rrd next to clean */
-		if (++rrd_next_to_clean == rrd_ring->count)
-			rrd_next_to_clean = 0;
-		count++;
-
-		if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-			if (!(rrd->err_flg &
-				(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM
-				| ERR_FLAG_LEN))) {
-				/* packet error, don't need upstream */
-				buffer_info->alloced = 0;
-				rrd->xsz.valid = 0;
-				continue;
-			}
+		if (buffer_info->skb) {
+			dev_kfree_skb(buffer_info->skb);
+			buffer_info->skb = NULL;
 		}
-
-		/* Good Receive */
-		pci_unmap_page(adapter->pdev, buffer_info->dma,
-			       buffer_info->length, PCI_DMA_FROMDEVICE);
-		skb = buffer_info->skb;
-		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
-
-		skb_put(skb, length - ETHERNET_FCS_SIZE);
-
-		/* Receive Checksum Offload */
-		atl1_rx_checksum(adapter, rrd, skb);
-		skb->protocol = eth_type_trans(skb, adapter->netdev);
-
-		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
-			u16 vlan_tag = (rrd->vlan_tag >> 4) |
-					((rrd->vlan_tag & 7) << 13) |
-					((rrd->vlan_tag & 8) << 9);
-			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
-		} else
-			netif_rx(skb);
-
-		/* let protocol layer free skb */
-		buffer_info->skb = NULL;
-		buffer_info->alloced = 0;
-		rrd->xsz.valid = 0;
-
-		adapter->netdev->last_rx = jiffies;
 	}
 
-	atomic_set(&rrd_ring->next_to_clean, rrd_next_to_clean);
-
-	atl1_alloc_rx_buffers(adapter);
+	size = sizeof(struct atl1_buffer) * rfd_ring->count;
+	memset(rfd_ring->buffer_info, 0, size);
 
-	/* update mailbox ? */
-	if (count) {
-		u32 tpd_next_to_use;
-		u32 rfd_next_to_use;
-		u32 rrd_next_to_clean;
+	/* Zero out the descriptor ring */
+	memset(rfd_ring->desc, 0, rfd_ring->size);
 
-		spin_lock(&adapter->mb_lock);
+	rfd_ring->next_to_clean = 0;
+	atomic_set(&rfd_ring->next_to_use, 0);
 
-		tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
-		rfd_next_to_use =
-		    atomic_read(&adapter->rfd_ring.next_to_use);
-		rrd_next_to_clean =
-		    atomic_read(&adapter->rrd_ring.next_to_clean);
-		value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
-			MB_RFD_PROD_INDX_SHIFT) |
-                        ((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
-			MB_RRD_CONS_INDX_SHIFT) |
-                        ((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
-			MB_TPD_PROD_INDX_SHIFT);
-		iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
-		spin_unlock(&adapter->mb_lock);
-	}
+	rrd_ring->next_to_use = 0;
+	atomic_set(&rrd_ring->next_to_clean, 0);
 }
 
-static void atl1_intr_tx(struct atl1_adapter *adapter)
+/*
+ * atl1_clean_tx_ring - Free Tx Buffers
+ * @adapter: board private structure
+ */
+static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
-	u16 sw_tpd_next_to_clean;
-	u16 cmb_tpd_next_to_clean;
-
-	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
-	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
-
-	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
-		struct tx_packet_desc *tpd;
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long size;
+	unsigned int i;
 
-		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
-		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
+	/* Free all the Tx ring sk_buffs */
+	for (i = 0; i < tpd_ring->count; i++) {
+		buffer_info = &tpd_ring->buffer_info[i];
 		if (buffer_info->dma) {
-			pci_unmap_page(adapter->pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+			pci_unmap_page(pdev, buffer_info->dma,
+				buffer_info->length, PCI_DMA_TODEVICE);
 			buffer_info->dma = 0;
 		}
+	}
 
+	for (i = 0; i < tpd_ring->count; i++) {
+		buffer_info = &tpd_ring->buffer_info[i];
 		if (buffer_info->skb) {
-			dev_kfree_skb_irq(buffer_info->skb);
+			dev_kfree_skb_any(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
-		tpd->buffer_addr = 0;
-		tpd->desc.data = 0;
-
-		if (++sw_tpd_next_to_clean == tpd_ring->count)
-			sw_tpd_next_to_clean = 0;
 	}
-	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
-
-	if (netif_queue_stopped(adapter->netdev)
-	    && netif_carrier_ok(adapter->netdev))
-		netif_wake_queue(adapter->netdev);
-}
 
-static void atl1_check_for_link(struct atl1_adapter *adapter)
-{
-	struct net_device *netdev = adapter->netdev;
-	u16 phy_data = 0;
-
-	spin_lock(&adapter->lock);
-	adapter->phy_timer_pending = false;
-	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
-	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
-	spin_unlock(&adapter->lock);
-
-	/* notify upper layer link down ASAP */
-	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
-		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			dev_info(&adapter->pdev->dev, "%s link is down\n",
-				netdev->name);
-			adapter->link_speed = SPEED_0;
-			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
-		}
-	}
-	schedule_work(&adapter->link_chg_task);
-}
-
-/*
- * atl1_intr - Interrupt Handler
- * @irq: interrupt number
- * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
- */
-static irqreturn_t atl1_intr(int irq, void *data)
-{
-	/*struct atl1_adapter *adapter = ((struct net_device *)data)->priv;*/
-	struct atl1_adapter *adapter = netdev_priv(data);
-	u32 status;
-	u8 update_rx;
-	int max_ints = 10;
-
-	status = adapter->cmb.cmb->int_stats;
-	if (!status)
-		return IRQ_NONE;
-
-	update_rx = 0;
-
-	do {
-		/* clear CMB interrupt status at once */
-		adapter->cmb.cmb->int_stats = 0;
-
-		if (status & ISR_GPHY)	/* clear phy status */
-			atl1_clear_phy_int(adapter);
-
-		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
-		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
-
-		/* check if SMB intr */
-		if (status & ISR_SMB)
-			atl1_inc_smb(adapter);
-
-		/* check if PCIE PHY Link down */
-		if (status & ISR_PHY_LINKDOWN) {
-			dev_dbg(&adapter->pdev->dev, "pcie phy link down %x\n",
-				status);
-			if (netif_running(adapter->netdev)) {	/* reset MAC */
-				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-				schedule_work(&adapter->pcie_dma_to_rst_task);
-				return IRQ_HANDLED;
-			}
-		}
-
-		/* check if DMA read/write error ? */
-		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			dev_dbg(&adapter->pdev->dev,
-				"pcie DMA r/w error (status = 0x%x)\n",
-				status);
-			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-			schedule_work(&adapter->pcie_dma_to_rst_task);
-			return IRQ_HANDLED;
-		}
-
-		/* link event */
-		if (status & ISR_GPHY) {
-			adapter->soft_stats.tx_carrier_errors++;
-			atl1_check_for_link(adapter);
-		}
-
-		/* transmit event */
-		if (status & ISR_CMB_TX)
-			atl1_intr_tx(adapter);
-
-		/* rx exception */
-		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
-			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-				ISR_HOST_RRD_OV))
-				dev_dbg(&adapter->pdev->dev,
-					"rx exception, ISR = 0x%x\n", status);
-			atl1_intr_rx(adapter);
-		}
-
-		if (--max_ints < 0)
-			break;
+	size = sizeof(struct atl1_buffer) * tpd_ring->count;
+	memset(tpd_ring->buffer_info, 0, size);
 
-	} while ((status = adapter->cmb.cmb->int_stats));
+	/* Zero out the descriptor ring */
+	memset(tpd_ring->desc, 0, tpd_ring->size);
 
-	/* re-enable Interrupt */
-	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
-	return IRQ_HANDLED;
+	atomic_set(&tpd_ring->next_to_use, 0);
+	atomic_set(&tpd_ring->next_to_clean, 0);
 }
 
 /*
- * atl1_set_multi - Multicast and Promiscuous mode set
- * @netdev: network interface device structure
+ * atl1_free_ring_resources - Free Tx / RX descriptor Resources
+ * @adapter: board private structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
- * promiscuous mode, and all-multi behavior.
+ * Free all transmit software resources
  */
-static void atl1_set_multi(struct net_device *netdev)
+void atl1_free_ring_resources(struct atl1_adapter *adapter)
 {
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct atl1_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
-	u32 rctl;
-	u32 hash_value;
+	struct pci_dev *pdev = adapter->pdev;
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+	struct atl1_ring_header *ring_header = &adapter->ring_header;
 
-	/* Check for Promiscuous and All Multicast modes */
-	rctl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-	if (netdev->flags & IFF_PROMISC)
-		rctl |= MAC_CTRL_PROMIS_EN;
-	else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= MAC_CTRL_MC_ALL_EN;
-		rctl &= ~MAC_CTRL_PROMIS_EN;
-	} else
-		rctl &= ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
+	atl1_clean_tx_ring(adapter);
+	atl1_clean_rx_ring(adapter);
 
-	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
+	kfree(tpd_ring->buffer_info);
+	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
+		ring_header->dma);
 
-	/* clear the old settings from the multicast hash table */
-	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+	tpd_ring->buffer_info = NULL;
+	tpd_ring->desc = NULL;
+	tpd_ring->dma = 0;
 
-	/* compute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
-		hash_value = atl1_hash_mc_addr(hw, mc_ptr->dmi_addr);
-		atl1_hash_set(hw, hash_value);
-	}
+	rfd_ring->buffer_info = NULL;
+	rfd_ring->desc = NULL;
+	rfd_ring->dma = 0;
+
+	rrd_ring->desc = NULL;
+	rrd_ring->dma = 0;
 }
 
 static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
@@ -855,6 +484,31 @@ static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
 	iowrite32(value, hw->hw_addr + REG_MAC_CTRL);
 }
 
+/*
+ * atl1_set_mac - Change the Ethernet Address of the NIC
+ * @netdev: network interface device structure
+ * @p: pointer to an address structure
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int atl1_set_mac(struct net_device *netdev, void *p)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+
+	atl1_set_mac_addr(&adapter->hw);
+	return 0;
+}
+
 static u32 atl1_check_link(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
@@ -962,6 +616,103 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	return ATL1_SUCCESS;
 }
 
+static void atl1_check_for_link(struct atl1_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	u16 phy_data = 0;
+
+	spin_lock(&adapter->lock);
+	adapter->phy_timer_pending = false;
+	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
+	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
+	spin_unlock(&adapter->lock);
+
+	/* notify upper layer link down ASAP */
+	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
+		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
+			dev_info(&adapter->pdev->dev, "%s link is down\n",
+				netdev->name);
+			adapter->link_speed = SPEED_0;
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
+	}
+	schedule_work(&adapter->link_chg_task);
+}
+
+/*
+ * atl1_set_multi - Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ *
+ * The set_multi entry point is called whenever the multicast address
+ * list or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper multicast,
+ * promiscuous mode, and all-multi behavior.
+ */
+static void atl1_set_multi(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_hw *hw = &adapter->hw;
+	struct dev_mc_list *mc_ptr;
+	u32 rctl;
+	u32 hash_value;
+
+	/* Check for Promiscuous and All Multicast modes */
+	rctl = ioread32(hw->hw_addr + REG_MAC_CTRL);
+	if (netdev->flags & IFF_PROMISC)
+		rctl |= MAC_CTRL_PROMIS_EN;
+	else if (netdev->flags & IFF_ALLMULTI) {
+		rctl |= MAC_CTRL_MC_ALL_EN;
+		rctl &= ~MAC_CTRL_PROMIS_EN;
+	} else
+		rctl &= ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
+
+	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
+
+	/* clear the old settings from the multicast hash table */
+	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+
+	/* compute mc addresses' hash value ,and put it into hash table */
+	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+		hash_value = atl1_hash_mc_addr(hw, mc_ptr->dmi_addr);
+		atl1_hash_set(hw, hash_value);
+	}
+}
+
+/*
+ * atl1_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	int old_mtu = netdev->mtu;
+	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
+
+	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
+	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
+		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	adapter->hw.max_frame_size = max_frame;
+	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
+	adapter->rx_buffer_len = (max_frame + 7) & ~7;
+	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
+
+	netdev->mtu = new_mtu;
+	if ((old_mtu != new_mtu) && netif_running(netdev)) {
+		atl1_down(adapter);
+		atl1_up(adapter);
+	}
+
+	return 0;
+}
+
 static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 {
 	u32 hi, lo, value;
@@ -974,7 +725,7 @@ static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 	lo = value * 7 / 8;
 
 	value = ((hi & RXQ_RXF_PAUSE_TH_HI_MASK) << RXQ_RXF_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, adapter->hw.hw_addr + REG_RXQ_RXF_PAUSE_THRESH);
 
 	/* RRD Flow Control */
@@ -984,7 +735,7 @@ static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 	if (lo < 2)
 		lo = 2;
 	value = ((hi & RXQ_RRD_PAUSE_TH_HI_MASK) << RXQ_RRD_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, adapter->hw.hw_addr + REG_RXQ_RRD_PAUSE_THRESH);
 }
 
@@ -1001,7 +752,7 @@ static void set_flow_ctrl_new(struct atl1_hw *hw)
 	if (hi < lo)
 		hi = lo + 16;
 	value = ((hi & RXQ_RXF_PAUSE_TH_HI_MASK) << RXQ_RXF_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_RXQ_RXF_PAUSE_THRESH);
 
 	/* RRD Flow Control */
@@ -1013,7 +764,7 @@ static void set_flow_ctrl_new(struct atl1_hw *hw)
 	if (hi < lo)
 		hi = lo + 3;
 	value = ((hi & RXQ_RRD_PAUSE_TH_HI_MASK) << RXQ_RRD_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_RXQ_RRD_PAUSE_THRESH);
 }
 
@@ -1062,7 +813,8 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	value <<= 16;
 	value += adapter->rfd_ring.count;
 	iowrite32(value, hw->hw_addr + REG_DESC_RFD_RRD_RING_SIZE);
-	iowrite32(adapter->tpd_ring.count, hw->hw_addr + REG_DESC_TPD_RING_SIZE);
+	iowrite32(adapter->tpd_ring.count, hw->hw_addr +
+		REG_DESC_TPD_RING_SIZE);
 
 	/* Load Ptr */
 	iowrite32(1, hw->hw_addr + REG_LOAD_PTR);
@@ -1070,31 +822,31 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* config Mailbox */
 	value = ((atomic_read(&adapter->tpd_ring.next_to_use)
 		  & MB_TPD_PROD_INDX_MASK) << MB_TPD_PROD_INDX_SHIFT) |
-	    ((atomic_read(&adapter->rrd_ring.next_to_clean)
-	      & MB_RRD_CONS_INDX_MASK) << MB_RRD_CONS_INDX_SHIFT) |
-	    ((atomic_read(&adapter->rfd_ring.next_to_use)
-	      & MB_RFD_PROD_INDX_MASK) << MB_RFD_PROD_INDX_SHIFT);
+		((atomic_read(&adapter->rrd_ring.next_to_clean)
+		& MB_RRD_CONS_INDX_MASK) << MB_RRD_CONS_INDX_SHIFT) |
+		((atomic_read(&adapter->rfd_ring.next_to_use)
+		& MB_RFD_PROD_INDX_MASK) << MB_RFD_PROD_INDX_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_MAILBOX);
 
 	/* config IPG/IFG */
 	value = (((u32) hw->ipgt & MAC_IPG_IFG_IPGT_MASK)
 		 << MAC_IPG_IFG_IPGT_SHIFT) |
-	    (((u32) hw->min_ifg & MAC_IPG_IFG_MIFG_MASK)
-	     << MAC_IPG_IFG_MIFG_SHIFT) |
-	    (((u32) hw->ipgr1 & MAC_IPG_IFG_IPGR1_MASK)
-	     << MAC_IPG_IFG_IPGR1_SHIFT) |
-	    (((u32) hw->ipgr2 & MAC_IPG_IFG_IPGR2_MASK)
-	     << MAC_IPG_IFG_IPGR2_SHIFT);
+		(((u32) hw->min_ifg & MAC_IPG_IFG_MIFG_MASK)
+		<< MAC_IPG_IFG_MIFG_SHIFT) |
+		(((u32) hw->ipgr1 & MAC_IPG_IFG_IPGR1_MASK)
+		<< MAC_IPG_IFG_IPGR1_SHIFT) |
+		(((u32) hw->ipgr2 & MAC_IPG_IFG_IPGR2_MASK)
+		<< MAC_IPG_IFG_IPGR2_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_MAC_IPG_IFG);
 
 	/* config  Half-Duplex Control */
 	value = ((u32) hw->lcol & MAC_HALF_DUPLX_CTRL_LCOL_MASK) |
-	    (((u32) hw->max_retry & MAC_HALF_DUPLX_CTRL_RETRY_MASK)
-	     << MAC_HALF_DUPLX_CTRL_RETRY_SHIFT) |
-	    MAC_HALF_DUPLX_CTRL_EXC_DEF_EN |
-	    (0xa << MAC_HALF_DUPLX_CTRL_ABEBT_SHIFT) |
-	    (((u32) hw->jam_ipg & MAC_HALF_DUPLX_CTRL_JAMIPG_MASK)
-	     << MAC_HALF_DUPLX_CTRL_JAMIPG_SHIFT);
+		(((u32) hw->max_retry & MAC_HALF_DUPLX_CTRL_RETRY_MASK)
+		<< MAC_HALF_DUPLX_CTRL_RETRY_SHIFT) |
+		MAC_HALF_DUPLX_CTRL_EXC_DEF_EN |
+		(0xa << MAC_HALF_DUPLX_CTRL_ABEBT_SHIFT) |
+		(((u32) hw->jam_ipg & MAC_HALF_DUPLX_CTRL_JAMIPG_MASK)
+		<< MAC_HALF_DUPLX_CTRL_JAMIPG_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_MAC_HALF_DUPLX_CTRL);
 
 	/* set Interrupt Moderator Timer */
@@ -1110,10 +862,10 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* jumbo size & rrd retirement timer */
 	value = (((u32) hw->rx_jumbo_th & RXQ_JMBOSZ_TH_MASK)
 		 << RXQ_JMBOSZ_TH_SHIFT) |
-	    (((u32) hw->rx_jumbo_lkah & RXQ_JMBO_LKAH_MASK)
-	     << RXQ_JMBO_LKAH_SHIFT) |
-	    (((u32) hw->rrd_ret_timer & RXQ_RRD_TIMER_MASK)
-	     << RXQ_RRD_TIMER_SHIFT);
+		(((u32) hw->rx_jumbo_lkah & RXQ_JMBO_LKAH_MASK)
+		<< RXQ_JMBO_LKAH_SHIFT) |
+		(((u32) hw->rrd_ret_timer & RXQ_RRD_TIMER_MASK)
+		<< RXQ_RRD_TIMER_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_RXQ_JMBOSZ_RRDTIM);
 
 	/* Flow Control */
@@ -1132,35 +884,36 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* config TXQ */
 	value = (((u32) hw->tpd_burst & TXQ_CTRL_TPD_BURST_NUM_MASK)
 		 << TXQ_CTRL_TPD_BURST_NUM_SHIFT) |
-	    (((u32) hw->txf_burst & TXQ_CTRL_TXF_BURST_NUM_MASK)
-	     << TXQ_CTRL_TXF_BURST_NUM_SHIFT) |
-	    (((u32) hw->tpd_fetch_th & TXQ_CTRL_TPD_FETCH_TH_MASK)
-	     << TXQ_CTRL_TPD_FETCH_TH_SHIFT) | TXQ_CTRL_ENH_MODE | TXQ_CTRL_EN;
+		(((u32) hw->txf_burst & TXQ_CTRL_TXF_BURST_NUM_MASK)
+		<< TXQ_CTRL_TXF_BURST_NUM_SHIFT) |
+		(((u32) hw->tpd_fetch_th & TXQ_CTRL_TPD_FETCH_TH_MASK)
+		<< TXQ_CTRL_TPD_FETCH_TH_SHIFT) | TXQ_CTRL_ENH_MODE |
+		TXQ_CTRL_EN;
 	iowrite32(value, hw->hw_addr + REG_TXQ_CTRL);
 
 	/* min tpd fetch gap & tx jumbo packet size threshold for taskoffload */
 	value = (((u32) hw->tx_jumbo_task_th & TX_JUMBO_TASK_TH_MASK)
-		 << TX_JUMBO_TASK_TH_SHIFT) |
-	    (((u32) hw->tpd_fetch_gap & TX_TPD_MIN_IPG_MASK)
-	     << TX_TPD_MIN_IPG_SHIFT);
+		<< TX_JUMBO_TASK_TH_SHIFT) |
+		(((u32) hw->tpd_fetch_gap & TX_TPD_MIN_IPG_MASK)
+		<< TX_TPD_MIN_IPG_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_TX_JUMBO_TASK_TH_TPD_IPG);
 
 	/* config RXQ */
 	value = (((u32) hw->rfd_burst & RXQ_CTRL_RFD_BURST_NUM_MASK)
-		 << RXQ_CTRL_RFD_BURST_NUM_SHIFT) |
-	    (((u32) hw->rrd_burst & RXQ_CTRL_RRD_BURST_THRESH_MASK)
-	     << RXQ_CTRL_RRD_BURST_THRESH_SHIFT) |
-	    (((u32) hw->rfd_fetch_gap & RXQ_CTRL_RFD_PREF_MIN_IPG_MASK)
-	     << RXQ_CTRL_RFD_PREF_MIN_IPG_SHIFT) |
-	    RXQ_CTRL_CUT_THRU_EN | RXQ_CTRL_EN;
+		<< RXQ_CTRL_RFD_BURST_NUM_SHIFT) |
+		(((u32) hw->rrd_burst & RXQ_CTRL_RRD_BURST_THRESH_MASK)
+		<< RXQ_CTRL_RRD_BURST_THRESH_SHIFT) |
+		(((u32) hw->rfd_fetch_gap & RXQ_CTRL_RFD_PREF_MIN_IPG_MASK)
+		<< RXQ_CTRL_RFD_PREF_MIN_IPG_SHIFT) | RXQ_CTRL_CUT_THRU_EN |
+		RXQ_CTRL_EN;
 	iowrite32(value, hw->hw_addr + REG_RXQ_CTRL);
 
 	/* config DMA Engine */
 	value = ((((u32) hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-		 << DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
-	    ((((u32) hw->dmaw_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-	     << DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
-	    DMA_CTRL_DMAR_EN | DMA_CTRL_DMAW_EN;
+		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
+		((((u32) hw->dmaw_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
+		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) | DMA_CTRL_DMAR_EN |
+		DMA_CTRL_DMAW_EN;
 	value |= (u32) hw->dma_ord;
 	if (atl1_rcb_128 == hw->rcb_value)
 		value |= DMA_CTRL_RCB_VALUE;
@@ -1190,56 +943,495 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 }
 
 /*
+ * atl1_pcie_patch - Patch for PCIE module
+ */
+static void atl1_pcie_patch(struct atl1_adapter *adapter)
+{
+	u32 value;
+
+	/* much vendor magic here */
+	value = 0x6500;
+	iowrite32(value, adapter->hw.hw_addr + 0x12FC);
+	/* pcie flow control mode change */
+	value = ioread32(adapter->hw.hw_addr + 0x1008);
+	value |= 0x8000;
+	iowrite32(value, adapter->hw.hw_addr + 0x1008);
+}
+
+/*
+ * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
+ * on PCI Command register is disable.
+ * The function enable this bit.
+ * Brackett, 2006/03/15
+ */
+static void atl1_via_workaround(struct atl1_adapter *adapter)
+{
+	unsigned long value;
+
+	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
+	if (value & PCI_COMMAND_INTX_DISABLE)
+		value &= ~PCI_COMMAND_INTX_DISABLE;
+	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
+}
+
+/*
+ * atl1_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ */
+static void atl1_irq_enable(struct atl1_adapter *adapter)
+{
+	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
+}
+
+/*
  * atl1_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
 static void atl1_irq_disable(struct atl1_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 	ioread32(adapter->hw.hw_addr + REG_IMR);
 	synchronize_irq(adapter->pdev->irq);
 }
 
-static void atl1_vlan_rx_register(struct net_device *netdev,
-				struct vlan_group *grp)
+static void atl1_clear_phy_int(struct atl1_adapter *adapter)
 {
-	struct atl1_adapter *adapter = netdev_priv(netdev);
+	u16 phy_data;
 	unsigned long flags;
-	u32 ctrl;
 
 	spin_lock_irqsave(&adapter->lock, flags);
-	/* atl1_irq_disable(adapter); */
-	adapter->vlgrp = grp;
+	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
 
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl |= MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+static void atl1_inc_smb(struct atl1_adapter *adapter)
+{
+	struct stats_msg_block *smb = adapter->smb.smb;
+
+	/* Fill out the OS statistics structure */
+	adapter->soft_stats.rx_packets += smb->rx_ok;
+	adapter->soft_stats.tx_packets += smb->tx_ok;
+	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
+	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
+	adapter->soft_stats.multicast += smb->rx_mcast;
+	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col * 2 +
+		smb->tx_late_col + smb->tx_abort_col * adapter->hw.max_retry);
+
+	/* Rx Errors */
+	adapter->soft_stats.rx_errors += (smb->rx_frag + smb->rx_fcs_err +
+		smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
+		smb->rx_rrd_ov + smb->rx_align_err);
+	adapter->soft_stats.rx_fifo_errors += smb->rx_rxf_ov;
+	adapter->soft_stats.rx_length_errors += smb->rx_len_err;
+	adapter->soft_stats.rx_crc_errors += smb->rx_fcs_err;
+	adapter->soft_stats.rx_frame_errors += smb->rx_align_err;
+	adapter->soft_stats.rx_missed_errors += (smb->rx_rrd_ov +
+		smb->rx_rxf_ov);
+
+	adapter->soft_stats.rx_pause += smb->rx_pause;
+	adapter->soft_stats.rx_rrd_ov += smb->rx_rrd_ov;
+	adapter->soft_stats.rx_trunc += smb->rx_sz_ov;
+
+	/* Tx Errors */
+	adapter->soft_stats.tx_errors += (smb->tx_late_col +
+		smb->tx_abort_col + smb->tx_underrun + smb->tx_trunc);
+	adapter->soft_stats.tx_fifo_errors += smb->tx_underrun;
+	adapter->soft_stats.tx_aborted_errors += smb->tx_abort_col;
+	adapter->soft_stats.tx_window_errors += smb->tx_late_col;
+
+	adapter->soft_stats.excecol += smb->tx_abort_col;
+	adapter->soft_stats.deffer += smb->tx_defer;
+	adapter->soft_stats.scc += smb->tx_1_col;
+	adapter->soft_stats.mcc += smb->tx_2_col;
+	adapter->soft_stats.latecol += smb->tx_late_col;
+	adapter->soft_stats.tx_underun += smb->tx_underrun;
+	adapter->soft_stats.tx_trunc += smb->tx_trunc;
+	adapter->soft_stats.tx_pause += smb->tx_pause;
+
+	adapter->net_stats.rx_packets = adapter->soft_stats.rx_packets;
+	adapter->net_stats.tx_packets = adapter->soft_stats.tx_packets;
+	adapter->net_stats.rx_bytes = adapter->soft_stats.rx_bytes;
+	adapter->net_stats.tx_bytes = adapter->soft_stats.tx_bytes;
+	adapter->net_stats.multicast = adapter->soft_stats.multicast;
+	adapter->net_stats.collisions = adapter->soft_stats.collisions;
+	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
+	adapter->net_stats.rx_over_errors =
+		adapter->soft_stats.rx_missed_errors;
+	adapter->net_stats.rx_length_errors =
+		adapter->soft_stats.rx_length_errors;
+	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
+	adapter->net_stats.rx_frame_errors =
+		adapter->soft_stats.rx_frame_errors;
+	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
+	adapter->net_stats.rx_missed_errors =
+		adapter->soft_stats.rx_missed_errors;
+	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
+	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
+	adapter->net_stats.tx_aborted_errors =
+		adapter->soft_stats.tx_aborted_errors;
+	adapter->net_stats.tx_window_errors =
+		adapter->soft_stats.tx_window_errors;
+	adapter->net_stats.tx_carrier_errors =
+		adapter->soft_stats.tx_carrier_errors;
+}
+
+/*
+ * atl1_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ *
+ * Returns the address of the device statistics structure.
+ * The statistics are actually updated from the timer callback.
+ */
+static struct net_device_stats *atl1_get_stats(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	return &adapter->net_stats;
+}
+
+static void atl1_update_mailbox(struct atl1_adapter *adapter)
+{
+	unsigned long flags;
+	u32 tpd_next_to_use;
+	u32 rfd_next_to_use;
+	u32 rrd_next_to_clean;
+	u32 value;
+
+	spin_lock_irqsave(&adapter->mb_lock, flags);
+
+	tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
+	rfd_next_to_use = atomic_read(&adapter->rfd_ring.next_to_use);
+	rrd_next_to_clean = atomic_read(&adapter->rrd_ring.next_to_clean);
+
+	value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
+		MB_RFD_PROD_INDX_SHIFT) |
+		((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
+		MB_RRD_CONS_INDX_SHIFT) |
+		((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
+		MB_TPD_PROD_INDX_SHIFT);
+	iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
+
+	spin_unlock_irqrestore(&adapter->mb_lock, flags);
+}
+
+static void atl1_clean_alloc_flag(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd, u16 offset)
+{
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+
+	while (rfd_ring->next_to_clean != (rrd->buf_indx + offset)) {
+		rfd_ring->buffer_info[rfd_ring->next_to_clean].alloced = 0;
+		if (++rfd_ring->next_to_clean == rfd_ring->count) {
+			rfd_ring->next_to_clean = 0;
+		}
 	}
+}
 
-	/* atl1_irq_enable(adapter); */
-	spin_unlock_irqrestore(&adapter->lock, flags);
+static void atl1_update_rfd_index(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd)
+{
+	u16 num_buf;
+
+	num_buf = (rrd->xsz.xsum_sz.pkt_size + adapter->rx_buffer_len - 1) /
+		adapter->rx_buffer_len;
+	if (rrd->num_buf == num_buf)
+		/* clean alloc flag for bad rrd */
+		atl1_clean_alloc_flag(adapter, rrd, num_buf);
 }
 
-static void atl1_restore_vlan(struct atl1_adapter *adapter)
+static void atl1_rx_checksum(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd, struct sk_buff *skb)
 {
-	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	struct pci_dev *pdev = adapter->pdev;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
+		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
+					ERR_FLAG_CODE | ERR_FLAG_OV)) {
+			adapter->hw_csum_err++;
+			dev_printk(KERN_DEBUG, &pdev->dev,
+				"rx checksum error\n");
+			return;
+		}
+	}
+
+	/* not IPv4 */
+	if (!(rrd->pkt_flg & PACKET_FLAG_IPV4))
+		/* checksum is invalid, but it's not an IPv4 pkt, so ok */
+		return;
+
+	/* IPv4 packet */
+	if (likely(!(rrd->err_flg &
+		(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM)))) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		adapter->hw_csum_good++;
+		return;
+	}
+
+	/* IPv4, but hardware thinks its checksum is wrong */
+	dev_printk(KERN_DEBUG, &pdev->dev,
+		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
+		rrd->pkt_flg, rrd->err_flg);
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
+	adapter->hw_csum_err++;
+	return;
+}
+
+/*
+ * atl1_alloc_rx_buffers - Replace used receive buffers
+ * @adapter: address of board private structure
+ */
+static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
+{
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct pci_dev *pdev = adapter->pdev;
+	struct page *page;
+	unsigned long offset;
+	struct atl1_buffer *buffer_info, *next_info;
+	struct sk_buff *skb;
+	u16 num_alloc = 0;
+	u16 rfd_next_to_use, next_next;
+	struct rx_free_desc *rfd_desc;
+
+	next_next = rfd_next_to_use = atomic_read(&rfd_ring->next_to_use);
+	if (++next_next == rfd_ring->count)
+		next_next = 0;
+	buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
+	next_info = &rfd_ring->buffer_info[next_next];
+
+	while (!buffer_info->alloced && !next_info->alloced) {
+		if (buffer_info->skb) {
+			buffer_info->alloced = 1;
+			goto next;
+		}
+
+		rfd_desc = ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
+
+		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+		if (unlikely(!skb)) {	/* Better luck next round */
+			adapter->net_stats.rx_dropped++;
+			break;
+		}
+
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		buffer_info->alloced = 1;
+		buffer_info->skb = skb;
+		buffer_info->length = (u16) adapter->rx_buffer_len;
+		page = virt_to_page(skb->data);
+		offset = (unsigned long)skb->data & ~PAGE_MASK;
+		buffer_info->dma = pci_map_page(pdev, page, offset,
+						adapter->rx_buffer_len,
+						PCI_DMA_FROMDEVICE);
+		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
+		rfd_desc->buf_len = cpu_to_le16(adapter->rx_buffer_len);
+		rfd_desc->coalese = 0;
+
+next:
+		rfd_next_to_use = next_next;
+		if (unlikely(++next_next == rfd_ring->count))
+			next_next = 0;
+
+		buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
+		next_info = &rfd_ring->buffer_info[next_next];
+		num_alloc++;
+	}
+
+	if (num_alloc) {
+		/*
+		 * Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+		atomic_set(&rfd_ring->next_to_use, (int)rfd_next_to_use);
+	}
+	return num_alloc;
+}
+
+static void atl1_intr_rx(struct atl1_adapter *adapter)
+{
+	int i, count;
+	u16 length;
+	u16 rrd_next_to_clean;
+	u32 value;
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+	struct atl1_buffer *buffer_info;
+	struct rx_return_desc *rrd;
+	struct sk_buff *skb;
+
+	count = 0;
+
+	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
+
+	while (1) {
+		rrd = ATL1_RRD_DESC(rrd_ring, rrd_next_to_clean);
+		i = 1;
+		if (likely(rrd->xsz.valid)) {	/* packet valid */
+chk_rrd:
+			/* check rrd status */
+			if (likely(rrd->num_buf == 1))
+				goto rrd_ok;
+
+			/* rrd seems to be bad */
+			if (unlikely(i-- > 0)) {
+				/* rrd may not be DMAed completely */
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"incomplete RRD DMA transfer\n");
+				udelay(1);
+				goto chk_rrd;
+			}
+			/* bad rrd */
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"bad RRD\n");
+			/* see if update RFD index */
+			if (rrd->num_buf > 1)
+				atl1_update_rfd_index(adapter, rrd);
+
+			/* update rrd */
+			rrd->xsz.valid = 0;
+			if (++rrd_next_to_clean == rrd_ring->count)
+				rrd_next_to_clean = 0;
+			count++;
+			continue;
+		} else {	/* current rrd still not be updated */
+
+			break;
+		}
+rrd_ok:
+		/* clean alloc flag for bad rrd */
+		atl1_clean_alloc_flag(adapter, rrd, 0);
+
+		buffer_info = &rfd_ring->buffer_info[rrd->buf_indx];
+		if (++rfd_ring->next_to_clean == rfd_ring->count)
+			rfd_ring->next_to_clean = 0;
+
+		/* update rrd next to clean */
+		if (++rrd_next_to_clean == rrd_ring->count)
+			rrd_next_to_clean = 0;
+		count++;
+
+		if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
+			if (!(rrd->err_flg &
+				(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM
+				| ERR_FLAG_LEN))) {
+				/* packet error, don't need upstream */
+				buffer_info->alloced = 0;
+				rrd->xsz.valid = 0;
+				continue;
+			}
+		}
+
+		/* Good Receive */
+		pci_unmap_page(adapter->pdev, buffer_info->dma,
+			       buffer_info->length, PCI_DMA_FROMDEVICE);
+		skb = buffer_info->skb;
+		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
+
+		skb_put(skb, length - ETHERNET_FCS_SIZE);
+
+		/* Receive Checksum Offload */
+		atl1_rx_checksum(adapter, rrd, skb);
+		skb->protocol = eth_type_trans(skb, adapter->netdev);
+
+		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
+			u16 vlan_tag = (rrd->vlan_tag >> 4) |
+					((rrd->vlan_tag & 7) << 13) |
+					((rrd->vlan_tag & 8) << 9);
+			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
+		} else
+			netif_rx(skb);
+
+		/* let protocol layer free skb */
+		buffer_info->skb = NULL;
+		buffer_info->alloced = 0;
+		rrd->xsz.valid = 0;
+
+		adapter->netdev->last_rx = jiffies;
+	}
+
+	atomic_set(&rrd_ring->next_to_clean, rrd_next_to_clean);
+
+	atl1_alloc_rx_buffers(adapter);
+
+	/* update mailbox ? */
+	if (count) {
+		u32 tpd_next_to_use;
+		u32 rfd_next_to_use;
+		u32 rrd_next_to_clean;
+
+		spin_lock(&adapter->mb_lock);
+
+		tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
+		rfd_next_to_use =
+		    atomic_read(&adapter->rfd_ring.next_to_use);
+		rrd_next_to_clean =
+		    atomic_read(&adapter->rrd_ring.next_to_clean);
+		value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
+			MB_RFD_PROD_INDX_SHIFT) |
+                        ((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
+			MB_RRD_CONS_INDX_SHIFT) |
+                        ((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
+			MB_TPD_PROD_INDX_SHIFT);
+		iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
+		spin_unlock(&adapter->mb_lock);
+	}
+}
+
+static void atl1_intr_tx(struct atl1_adapter *adapter)
+{
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
+	struct atl1_buffer *buffer_info;
+	u16 sw_tpd_next_to_clean;
+	u16 cmb_tpd_next_to_clean;
+
+	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
+	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
+
+	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
+		struct tx_packet_desc *tpd;
+
+		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
+		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
+		if (buffer_info->dma) {
+			pci_unmap_page(adapter->pdev, buffer_info->dma,
+				       buffer_info->length, PCI_DMA_TODEVICE);
+			buffer_info->dma = 0;
+		}
+
+		if (buffer_info->skb) {
+			dev_kfree_skb_irq(buffer_info->skb);
+			buffer_info->skb = NULL;
+		}
+		tpd->buffer_addr = 0;
+		tpd->desc.data = 0;
+
+		if (++sw_tpd_next_to_clean == tpd_ring->count)
+			sw_tpd_next_to_clean = 0;
+	}
+	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
+
+	if (netif_queue_stopped(adapter->netdev)
+	    && netif_carrier_ok(adapter->netdev))
+		netif_wake_queue(adapter->netdev);
 }
 
 static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 next_to_use = atomic_read(&tpd_ring->next_to_use);
-	return ((next_to_clean >
-		 next_to_use) ? next_to_clean - next_to_use -
-		1 : tpd_ring->count + next_to_clean - next_to_use - 1);
+	return ((next_to_clean > next_to_use) ?
+		next_to_clean - next_to_use - 1 :
+		tpd_ring->count + next_to_clean - next_to_use - 1);
 }
 
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
@@ -1262,9 +1454,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			iph->tot_len = 0;
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
+				iph->daddr, 0, IPPROTO_TCP, 0);
 			ipofst = skb_network_offset(skb);
 			if (ipofst != ENET_HEADER_SIZE) /* 802.3 frame */
 				tso->tsopl |= 1 << TSO_PARAM_ETHTYPE_SHIFT;
@@ -1272,7 +1462,8 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			tso->tsopl |= (iph->ihl &
 				CSUM_PARAM_IPHL_MASK) << CSUM_PARAM_IPHL_SHIFT;
 			tso->tsopl |= (tcp_hdrlen(skb) &
-				TSO_PARAM_TCPHDRLEN_MASK) << TSO_PARAM_TCPHDRLEN_SHIFT;
+				TSO_PARAM_TCPHDRLEN_MASK) <<
+				TSO_PARAM_TCPHDRLEN_SHIFT;
 			tso->tsopl |= (skb_shinfo(skb)->gso_size &
 				TSO_PARAM_MSS_MASK) << TSO_PARAM_MSS_SHIFT;
 			tso->tsopl |= 1 << TSO_PARAM_IPCKSUM_SHIFT;
@@ -1285,7 +1476,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 }
 
 static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
-			struct csum_param *csum)
+	struct csum_param *csum)
 {
 	u8 css, cso;
 
@@ -1293,7 +1484,7 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 		cso = skb_transport_offset(skb);
 		css = cso + skb->csum_offset;
 		if (unlikely(cso & 0x1)) {
-			dev_dbg(&adapter->pdev->dev,
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"payload offset not an even number\n");
 			return -1;
 		}
@@ -1308,8 +1499,8 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 	return true;
 }
 
-static void atl1_tx_map(struct atl1_adapter *adapter,
-				struct sk_buff *skb, bool tcp_seg)
+static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
+	bool tcp_seg)
 {
 	/* We enter this function holding a spinlock. */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -1346,26 +1537,25 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 
 		if (first_buf_len > proto_hdr_len) {
 			len12 = first_buf_len - proto_hdr_len;
-			m = (len12 + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) /
+				ATL1_MAX_TX_BUF_LEN;
 			for (i = 0; i < m; i++) {
 				buffer_info =
 				    &tpd_ring->buffer_info[tpd_next_to_use];
 				buffer_info->skb = NULL;
 				buffer_info->length =
-				    (MAX_TX_BUF_LEN >=
-				     len12) ? MAX_TX_BUF_LEN : len12;
+				    (ATL1_MAX_TX_BUF_LEN >=
+				     len12) ? ATL1_MAX_TX_BUF_LEN : len12;
 				len12 -= buffer_info->length;
 				page = virt_to_page(skb->data +
-						 (proto_hdr_len +
-						  i * MAX_TX_BUF_LEN));
+					(proto_hdr_len +
+					i * ATL1_MAX_TX_BUF_LEN));
 				offset = (unsigned long)(skb->data +
-							(proto_hdr_len +
-							i * MAX_TX_BUF_LEN)) &
-							~PAGE_MASK;
-				buffer_info->dma =
-				    pci_map_page(adapter->pdev, page, offset,
-						 buffer_info->length,
-						 PCI_DMA_TODEVICE);
+					(proto_hdr_len +
+					i * ATL1_MAX_TX_BUF_LEN)) & ~PAGE_MASK;
+				buffer_info->dma = pci_map_page(adapter->pdev,
+					page, offset, buffer_info->length,
+					PCI_DMA_TODEVICE);
 				if (++tpd_next_to_use == tpd_ring->count)
 					tpd_next_to_use = 0;
 			}
@@ -1376,8 +1566,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 		page = virt_to_page(skb->data);
 		offset = (unsigned long)skb->data & ~PAGE_MASK;
 		buffer_info->dma = pci_map_page(adapter->pdev, page,
-						offset, first_buf_len,
-						PCI_DMA_TODEVICE);
+			offset, first_buf_len, PCI_DMA_TODEVICE);
 		if (++tpd_next_to_use == tpd_ring->count)
 			tpd_next_to_use = 0;
 	}
@@ -1389,19 +1578,19 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 		frag = &skb_shinfo(skb)->frags[f];
 		lenf = frag->size;
 
-		m = (lenf + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+		m = (lenf + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
 		for (i = 0; i < m; i++) {
 			buffer_info = &tpd_ring->buffer_info[tpd_next_to_use];
 			if (unlikely(buffer_info->skb))
 				BUG();
 			buffer_info->skb = NULL;
-			buffer_info->length =
-			    (lenf > MAX_TX_BUF_LEN) ? MAX_TX_BUF_LEN : lenf;
+			buffer_info->length = (lenf > ATL1_MAX_TX_BUF_LEN) ?
+				ATL1_MAX_TX_BUF_LEN : lenf;
 			lenf -= buffer_info->length;
-			buffer_info->dma =
-			    pci_map_page(adapter->pdev, frag->page,
-					 frag->page_offset + i * MAX_TX_BUF_LEN,
-					 buffer_info->length, PCI_DMA_TODEVICE);
+			buffer_info->dma = pci_map_page(adapter->pdev,
+				frag->page,
+				frag->page_offset + (i * ATL1_MAX_TX_BUF_LEN),
+				buffer_info->length, PCI_DMA_TODEVICE);
 
 			if (++tpd_next_to_use == tpd_ring->count)
 				tpd_next_to_use = 0;
@@ -1413,7 +1602,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 }
 
 static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
-			       union tpd_descr *descr)
+       union tpd_descr *descr)
 {
 	/* We enter this function holding a spinlock. */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -1457,31 +1646,6 @@ static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
 	atomic_set(&tpd_ring->next_to_use, (int)tpd_next_to_use);
 }
 
-static void atl1_update_mailbox(struct atl1_adapter *adapter)
-{
-	unsigned long flags;
-	u32 tpd_next_to_use;
-	u32 rfd_next_to_use;
-	u32 rrd_next_to_clean;
-	u32 value;
-
-	spin_lock_irqsave(&adapter->mb_lock, flags);
-
-	tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
-	rfd_next_to_use = atomic_read(&adapter->rfd_ring.next_to_use);
-	rrd_next_to_clean = atomic_read(&adapter->rrd_ring.next_to_clean);
-
-	value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
-		MB_RFD_PROD_INDX_SHIFT) |
-		((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
-		MB_RRD_CONS_INDX_SHIFT) |
-		((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
-		MB_TPD_PROD_INDX_SHIFT);
-	iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
-
-	spin_unlock_irqrestore(&adapter->mb_lock, flags);
-}
-
 static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1517,8 +1681,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	for (f = 0; f < nr_frags; f++) {
 		frag_size = skb_shinfo(skb)->frags[f].size;
 		if (frag_size)
-			count +=
-			    (frag_size + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+			count += (frag_size + ATL1_MAX_TX_BUF_LEN - 1) /
+				ATL1_MAX_TX_BUF_LEN;
 	}
 
 	/* mss will be nonzero if we're doing segment offload (TSO/GSO) */
@@ -1534,7 +1698,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			/* need additional TPD ? */
 			if (proto_hdr_len != len)
 				count += (len - proto_hdr_len +
-					MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
+					ATL1_MAX_TX_BUF_LEN - 1) /
+					ATL1_MAX_TX_BUF_LEN;
 		}
 	}
 
@@ -1542,7 +1707,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (!spin_trylock(&adapter->lock)) {
 		/* Can't get lock - tell upper layer to requeue */
 		local_irq_restore(flags);
-		dev_dbg(&adapter->pdev->dev, "tx locked\n");
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -1550,7 +1715,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		dev_dbg(&adapter->pdev->dev, "tx busy\n");
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1592,131 +1757,208 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 }
 
 /*
- * atl1_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
+ * atl1_intr - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ * @pt_regs: CPU registers structure
  */
-static struct net_device_stats *atl1_get_stats(struct net_device *netdev)
+static irqreturn_t atl1_intr(int irq, void *data)
 {
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	return &adapter->net_stats;
-}
+	struct atl1_adapter *adapter = netdev_priv(data);
+	u32 status;
+	u8 update_rx;
+	int max_ints = 10;
 
-/*
- * atl1_clean_rx_ring - Free RFD Buffers
- * @adapter: board private structure
- */
-static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
-{
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
-	struct atl1_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
-	unsigned long size;
-	unsigned int i;
+	status = adapter->cmb.cmb->int_stats;
+	if (!status)
+		return IRQ_NONE;
 
-	/* Free all the Rx ring sk_buffs */
-	for (i = 0; i < rfd_ring->count; i++) {
-		buffer_info = &rfd_ring->buffer_info[i];
-		if (buffer_info->dma) {
-			pci_unmap_page(pdev,
-					buffer_info->dma,
-					buffer_info->length,
-					PCI_DMA_FROMDEVICE);
-			buffer_info->dma = 0;
+	update_rx = 0;
+
+	do {
+		/* clear CMB interrupt status at once */
+		adapter->cmb.cmb->int_stats = 0;
+
+		if (status & ISR_GPHY)	/* clear phy status */
+			atl1_clear_phy_int(adapter);
+
+		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
+		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
+
+		/* check if SMB intr */
+		if (status & ISR_SMB)
+			atl1_inc_smb(adapter);
+
+		/* check if PCIE PHY Link down */
+		if (status & ISR_PHY_LINKDOWN) {
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie phy link down %x\n", status);
+			if (netif_running(adapter->netdev)) {	/* reset MAC */
+				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+				schedule_work(&adapter->pcie_dma_to_rst_task);
+				return IRQ_HANDLED;
+			}
 		}
-		if (buffer_info->skb) {
-			dev_kfree_skb(buffer_info->skb);
-			buffer_info->skb = NULL;
+
+		/* check if DMA read/write error ? */
+		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie DMA r/w error (status = 0x%x)\n",
+				status);
+			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+			schedule_work(&adapter->pcie_dma_to_rst_task);
+			return IRQ_HANDLED;
 		}
-	}
 
-	size = sizeof(struct atl1_buffer) * rfd_ring->count;
-	memset(rfd_ring->buffer_info, 0, size);
+		/* link event */
+		if (status & ISR_GPHY) {
+			adapter->soft_stats.tx_carrier_errors++;
+			atl1_check_for_link(adapter);
+		}
 
-	/* Zero out the descriptor ring */
-	memset(rfd_ring->desc, 0, rfd_ring->size);
+		/* transmit event */
+		if (status & ISR_CMB_TX)
+			atl1_intr_tx(adapter);
 
-	rfd_ring->next_to_clean = 0;
-	atomic_set(&rfd_ring->next_to_use, 0);
+		/* rx exception */
+		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
+			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+				ISR_HOST_RRD_OV))
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"rx exception, ISR = 0x%x\n", status);
+			atl1_intr_rx(adapter);
+		}
 
-	rrd_ring->next_to_use = 0;
-	atomic_set(&rrd_ring->next_to_clean, 0);
+		if (--max_ints < 0)
+			break;
+
+	} while ((status = adapter->cmb.cmb->int_stats));
+
+	/* re-enable Interrupt */
+	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
+	return IRQ_HANDLED;
 }
 
 /*
- * atl1_clean_tx_ring - Free Tx Buffers
- * @adapter: board private structure
+ * atl1_watchdog - Timer Call-back
+ * @data: pointer to netdev cast into an unsigned long
  */
-static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
+static void atl1_watchdog(unsigned long data)
 {
-	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-	struct atl1_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
-	unsigned long size;
-	unsigned int i;
+	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
 
-	/* Free all the Tx ring sk_buffs */
-	for (i = 0; i < tpd_ring->count; i++) {
-		buffer_info = &tpd_ring->buffer_info[i];
-		if (buffer_info->dma) {
-			pci_unmap_page(pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
-			buffer_info->dma = 0;
-		}
-	}
+	/* Reset the timer */
+	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+}
 
-	for (i = 0; i < tpd_ring->count; i++) {
-		buffer_info = &tpd_ring->buffer_info[i];
-		if (buffer_info->skb) {
-			dev_kfree_skb_any(buffer_info->skb);
-			buffer_info->skb = NULL;
-		}
-	}
+/*
+ * atl1_phy_config - Timer Call-back
+ * @data: pointer to netdev cast into an unsigned long
+ */
+static void atl1_phy_config(unsigned long data)
+{
+	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
+	struct atl1_hw *hw = &adapter->hw;
+	unsigned long flags;
 
-	size = sizeof(struct atl1_buffer) * tpd_ring->count;
-	memset(tpd_ring->buffer_info, 0, size);
+	spin_lock_irqsave(&adapter->lock, flags);
+	adapter->phy_timer_pending = false;
+	atl1_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_reg);
+	atl1_write_phy_reg(hw, MII_AT001_CR, hw->mii_1000t_ctrl_reg);
+	atl1_write_phy_reg(hw, MII_BMCR, MII_CR_RESET | MII_CR_AUTO_NEG_EN);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
 
-	/* Zero out the descriptor ring */
-	memset(tpd_ring->desc, 0, tpd_ring->size);
+/*
+ * atl1_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ */
+static void atl1_tx_timeout(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	/* Do the reset outside of interrupt context */
+	schedule_work(&adapter->tx_timeout_task);
+}
 
-	atomic_set(&tpd_ring->next_to_use, 0);
-	atomic_set(&tpd_ring->next_to_clean, 0);
+/*
+ * Orphaned vendor comment left intact here:
+ * <vendor comment>
+ * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
+ * will assert. We do soft reset <0x1400=1> according
+ * with the SPEC. BUT, it seemes that PCIE or DMA
+ * state-machine will not be reset. DMAR_TO_INT will
+ * assert again and again.
+ * </vendor comment>
+ */
+static void atl1_tx_timeout_task(struct work_struct *work)
+{
+	struct atl1_adapter *adapter =
+		container_of(work, struct atl1_adapter, tx_timeout_task);
+	struct net_device *netdev = adapter->netdev;
+
+	netif_device_detach(netdev);
+	atl1_down(adapter);
+	atl1_up(adapter);
+	netif_device_attach(netdev);
 }
 
 /*
- * atl1_free_ring_resources - Free Tx / RX descriptor Resources
- * @adapter: board private structure
- *
- * Free all transmit software resources
+ * atl1_link_chg_task - deal with link change event Out of interrupt context
  */
-void atl1_free_ring_resources(struct atl1_adapter *adapter)
+static void atl1_link_chg_task(struct work_struct *work)
 {
-	struct pci_dev *pdev = adapter->pdev;
-	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
-	struct atl1_ring_header *ring_header = &adapter->ring_header;
+	struct atl1_adapter *adapter =
+               container_of(work, struct atl1_adapter, link_chg_task);
+	unsigned long flags;
 
-	atl1_clean_tx_ring(adapter);
-	atl1_clean_rx_ring(adapter);
+	spin_lock_irqsave(&adapter->lock, flags);
+	atl1_check_link(adapter);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
 
-	kfree(tpd_ring->buffer_info);
-	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
-			    ring_header->dma);
+static void atl1_vlan_rx_register(struct net_device *netdev,
+	struct vlan_group *grp)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
+	u32 ctrl;
 
-	tpd_ring->buffer_info = NULL;
-	tpd_ring->desc = NULL;
-	tpd_ring->dma = 0;
+	spin_lock_irqsave(&adapter->lock, flags);
+	/* atl1_irq_disable(adapter); */
+	adapter->vlgrp = grp;
 
-	rfd_ring->buffer_info = NULL;
-	rfd_ring->desc = NULL;
-	rfd_ring->dma = 0;
+	if (grp) {
+		/* enable VLAN tag insert/strip */
+		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+		ctrl |= MAC_CTRL_RMV_VLAN;
+		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+		ctrl &= ~MAC_CTRL_RMV_VLAN;
+		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+	}
 
-	rrd_ring->desc = NULL;
-	rrd_ring->dma = 0;
+	/* atl1_irq_enable(adapter); */
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
+static void atl1_restore_vlan(struct atl1_adapter *adapter)
+{
+	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+}
+
+int atl1_reset(struct atl1_adapter *adapter)
+{
+	int ret;
+
+	ret = atl1_reset_hw(&adapter->hw);
+	if (ret != ATL1_SUCCESS)
+		return ret;
+	return atl1_init_hw(&adapter->hw);
 }
 
 s32 atl1_up(struct atl1_adapter *adapter)
@@ -1727,6 +1969,7 @@ s32 atl1_up(struct atl1_adapter *adapter)
 
 	/* hardware has been reset, we need to reload some things */
 	atl1_set_multi(netdev);
+	atl1_init_ring_ptrs(adapter);
 	atl1_restore_vlan(adapter);
 	err = atl1_alloc_rx_buffers(adapter);
 	if (unlikely(!err))		/* no RX BUFFER allocated */
@@ -1754,11 +1997,6 @@ s32 atl1_up(struct atl1_adapter *adapter)
 	atl1_check_link(adapter);
 	return 0;
 
-	/* FIXME: unreachable code! -- CHS */
-	/* free irq disable any interrupt */
-	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-	free_irq(adapter->pdev->irq, netdev);
-
 err_up:
 	pci_disable_msi(adapter->pdev);
 	/* free rx_buffers */
@@ -1790,172 +2028,6 @@ void atl1_down(struct atl1_adapter *adapter)
 }
 
 /*
- * atl1_change_mtu - Change the Maximum Transfer Unit
- * @netdev: network interface device structure
- * @new_mtu: new value for maximum frame size
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-
-	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
-
-	adapter->hw.max_frame_size = max_frame;
-	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
-	adapter->rx_buffer_len = (max_frame + 7) & ~7;
-	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
-
-	netdev->mtu = new_mtu;
-	if ((old_mtu != new_mtu) && netif_running(netdev)) {
-		atl1_down(adapter);
-		atl1_up(adapter);
-	}
-
-	return 0;
-}
-
-/*
- * atl1_set_mac - Change the Ethernet Address of the NIC
- * @netdev: network interface device structure
- * @p: pointer to an address structure
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_set_mac(struct net_device *netdev, void *p)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct sockaddr *addr = p;
-
-	if (netif_running(netdev))
-		return -EBUSY;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
-
-	atl1_set_mac_addr(&adapter->hw);
-	return 0;
-}
-
-/*
- * atl1_watchdog - Timer Call-back
- * @data: pointer to netdev cast into an unsigned long
- */
-static void atl1_watchdog(unsigned long data)
-{
-	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
-
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
-}
-
-static int mdio_read(struct net_device *netdev, int phy_id, int reg_num)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	u16 result;
-
-	atl1_read_phy_reg(&adapter->hw, reg_num & 0x1f, &result);
-
-	return result;
-}
-
-static void mdio_write(struct net_device *netdev, int phy_id, int reg_num, int val)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-
-	atl1_write_phy_reg(&adapter->hw, reg_num, val);
-}
-
-/*
- * atl1_mii_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
-static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
-	int retval;
-
-	if (!netif_running(netdev))
-		return -EINVAL;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	retval = generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-
-	return retval;
-}
-
-/*
- * atl1_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
-static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		return atl1_mii_ioctl(netdev, ifr, cmd);
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-/*
- * atl1_tx_timeout - Respond to a Tx Hang
- * @netdev: network interface device structure
- */
-static void atl1_tx_timeout(struct net_device *netdev)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->tx_timeout_task);
-}
-
-/*
- * atl1_phy_config - Timer Call-back
- * @data: pointer to netdev cast into an unsigned long
- */
-static void atl1_phy_config(unsigned long data)
-{
-	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
-	struct atl1_hw *hw = &adapter->hw;
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	adapter->phy_timer_pending = false;
-	atl1_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_reg);
-	atl1_write_phy_reg(hw, MII_AT001_CR, hw->mii_1000t_ctrl_reg);
-	atl1_write_phy_reg(hw, MII_BMCR, MII_CR_RESET | MII_CR_AUTO_NEG_EN);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
-int atl1_reset(struct atl1_adapter *adapter)
-{
-	int ret;
-
-	ret = atl1_reset_hw(&adapter->hw);
-	if (ret != ATL1_SUCCESS)
-		return ret;
-	return atl1_init_hw(&adapter->hw);
-}
-
-/*
  * atl1_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2007,77 +2079,113 @@ static int atl1_close(struct net_device *netdev)
 	return 0;
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void atl1_poll_controller(struct net_device *netdev)
-{
-	disable_irq(netdev->irq);
-	atl1_intr(netdev->irq, netdev);
-	enable_irq(netdev->irq);
-}
-#endif
-
-/*
- * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
- * will assert. We do soft reset <0x1400=1> according
- * with the SPEC. BUT, it seemes that PCIE or DMA
- * state-machine will not be reset. DMAR_TO_INT will
- * assert again and again.
- */
-static void atl1_tx_timeout_task(struct work_struct *work)
+#ifdef CONFIG_PM
+static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	struct atl1_adapter *adapter =
-		container_of(work, struct atl1_adapter, tx_timeout_task);
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_hw *hw = &adapter->hw;
+	u32 ctrl = 0;
+	u32 wufc = adapter->wol;
 
 	netif_device_detach(netdev);
-	atl1_down(adapter);
-	atl1_up(adapter);
-	netif_device_attach(netdev);
-}
+	if (netif_running(netdev))
+		atl1_down(adapter);
 
-/*
- * atl1_link_chg_task - deal with link change event Out of interrupt context
- */
-static void atl1_link_chg_task(struct work_struct *work)
-{
-	struct atl1_adapter *adapter =
-               container_of(work, struct atl1_adapter, link_chg_task);
-	unsigned long flags;
+	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
+	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
+	if (ctrl & BMSR_LSTATUS)
+		wufc &= ~ATL1_WUFC_LNKC;
 
-	spin_lock_irqsave(&adapter->lock, flags);
-	atl1_check_link(adapter);
-	spin_unlock_irqrestore(&adapter->lock, flags);
+	/* reduce speed to 10/100M */
+	if (wufc) {
+		atl1_phy_enter_power_saving(hw);
+		/* if resume, let driver to re- setup link */
+		hw->phy_configured = false;
+		atl1_set_mac_addr(hw);
+		atl1_set_multi(netdev);
+
+		ctrl = 0;
+		/* turn on magic packet wol */
+		if (wufc & ATL1_WUFC_MAG)
+			ctrl = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
+
+		/* turn on Link change WOL */
+		if (wufc & ATL1_WUFC_LNKC)
+			ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
+		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
+
+		/* turn on all-multi mode if wake on multicast is enabled */
+		ctrl = ioread32(hw->hw_addr + REG_MAC_CTRL);
+		ctrl &= ~MAC_CTRL_DBG;
+		ctrl &= ~MAC_CTRL_PROMIS_EN;
+		if (wufc & ATL1_WUFC_MC)
+			ctrl |= MAC_CTRL_MC_ALL_EN;
+		else
+			ctrl &= ~MAC_CTRL_MC_ALL_EN;
+
+		/* turn on broadcast mode if wake on-BC is enabled */
+		if (wufc & ATL1_WUFC_BC)
+			ctrl |= MAC_CTRL_BC_EN;
+		else
+			ctrl &= ~MAC_CTRL_BC_EN;
+
+		/* enable RX */
+		ctrl |= MAC_CTRL_RX_EN;
+		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}
+
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
 }
 
-/*
- * atl1_pcie_patch - Patch for PCIE module
- */
-static void atl1_pcie_patch(struct atl1_adapter *adapter)
+static int atl1_resume(struct pci_dev *pdev)
 {
-	u32 value;
-	value = 0x6500;
-	iowrite32(value, adapter->hw.hw_addr + 0x12FC);
-	/* pcie flow control mode change */
-	value = ioread32(adapter->hw.hw_addr + 0x1008);
-	value |= 0x8000;
-	iowrite32(value, adapter->hw.hw_addr + 0x1008);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	u32 ret_val;
+
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev);
+
+	ret_val = pci_enable_device(pdev);
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
+	atl1_reset(adapter);
+
+	if (netif_running(netdev))
+		atl1_up(adapter);
+	netif_device_attach(netdev);
+
+	atl1_via_workaround(adapter);
+
+	return 0;
 }
+#else
+#define atl1_suspend NULL
+#define atl1_resume NULL
+#endif
 
-/*
- * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
- * on PCI Command register is disable.
- * The function enable this bit.
- * Brackett, 2006/03/15
- */
-static void atl1_via_workaround(struct atl1_adapter *adapter)
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void atl1_poll_controller(struct net_device *netdev)
 {
-	unsigned long value;
-
-	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
-	if (value & PCI_COMMAND_INTX_DISABLE)
-		value &= ~PCI_COMMAND_INTX_DISABLE;
-	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
+	disable_irq(netdev->irq);
+	atl1_intr(netdev->irq, netdev);
+	enable_irq(netdev->irq);
 }
+#endif
 
 /*
  * atl1_probe - Device Initialization Routine
@@ -2091,7 +2199,7 @@ static void atl1_via_workaround(struct atl1_adapter *adapter)
  * and a hardware reset occur.
  */
 static int __devinit atl1_probe(struct pci_dev *pdev,
-			      const struct pci_device_id *ent)
+	const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct atl1_adapter *adapter;
@@ -2145,7 +2253,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	}
 	/* get device revision number */
 	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr +
-					(REG_MASTER_CTRL + 2));
+		(REG_MASTER_CTRL + 2));
 	dev_info(&pdev->dev, "version %s\n", DRIVER_VERSION);
 
 	/* set default ring resource counts */
@@ -2298,7 +2406,8 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 	 * address, we need to save the permanent one.
 	 */
 	if (memcmp(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN)) {
-		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN);
+		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr,
+			ETH_ALEN);
 		atl1_set_mac_addr(&adapter->hw);
 	}
 
@@ -2310,112 +2419,11 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-#ifdef CONFIG_PM
-static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct atl1_hw *hw = &adapter->hw;
-	u32 ctrl = 0;
-	u32 wufc = adapter->wol;
-
-	netif_device_detach(netdev);
-	if (netif_running(netdev))
-		atl1_down(adapter);
-
-	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
-	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
-	if (ctrl & BMSR_LSTATUS)
-		wufc &= ~ATL1_WUFC_LNKC;
-
-	/* reduce speed to 10/100M */
-	if (wufc) {
-		atl1_phy_enter_power_saving(hw);
-		/* if resume, let driver to re- setup link */
-		hw->phy_configured = false;
-		atl1_set_mac_addr(hw);
-		atl1_set_multi(netdev);
-
-		ctrl = 0;
-		/* turn on magic packet wol */
-		if (wufc & ATL1_WUFC_MAG)
-			ctrl = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
-
-		/* turn on Link change WOL */
-		if (wufc & ATL1_WUFC_LNKC)
-			ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
-		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
-
-		/* turn on all-multi mode if wake on multicast is enabled */
-		ctrl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_DBG;
-		ctrl &= ~MAC_CTRL_PROMIS_EN;
-		if (wufc & ATL1_WUFC_MC)
-			ctrl |= MAC_CTRL_MC_ALL_EN;
-		else
-			ctrl &= ~MAC_CTRL_MC_ALL_EN;
-
-		/* turn on broadcast mode if wake on-BC is enabled */
-		if (wufc & ATL1_WUFC_BC)
-			ctrl |= MAC_CTRL_BC_EN;
-		else
-			ctrl &= ~MAC_CTRL_BC_EN;
-
-		/* enable RX */
-		ctrl |= MAC_CTRL_RX_EN;
-		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);	/* 4 == D3 cold */
-	} else {
-		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);	/* 4 == D3 cold */
-	}
-
-	pci_save_state(pdev);
-	pci_disable_device(pdev);
-
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return 0;
-}
-
-static int atl1_resume(struct pci_dev *pdev)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	u32 ret_val;
-
-	pci_set_power_state(pdev, 0);
-	pci_restore_state(pdev);
-
-	ret_val = pci_enable_device(pdev);
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
-	atl1_reset(adapter);
-
-	if (netif_running(netdev))
-		atl1_up(adapter);
-	netif_device_attach(netdev);
-
-	atl1_via_workaround(adapter);
-
-	return 0;
-}
-#else
-#define atl1_suspend NULL
-#define atl1_resume NULL
-#endif
-
 static struct pci_driver atl1_driver = {
 	.name = atl1_driver_name,
 	.id_table = atl1_pci_tbl,
 	.probe = atl1_probe,
 	.remove = __devexit_p(atl1_remove),
-	/* Power Managment Hooks */
-	/* probably broken right now -- CHS */
 	.suspend = atl1_suspend,
 	.resume = atl1_resume
 };
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f03f070..6628fa6 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,13 +39,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0067"
+#define DRV_VERSION	"EHEA_0070"
 
-/* EHEA capability flags */
+/* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
-#define DLPAR_MEM_ADD 2
-#define DLPAR_MEM_REM 4
-#define EHEA_CAPABILITIES (DLPAR_PORT_ADD_REM)
+#define DLPAR_MEM_ADD      2
+#define DLPAR_MEM_REM      4
+#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -113,6 +113,8 @@
 /* Memory Regions */
 #define EHEA_MR_ACC_CTRL       0x00800000
 
+#define EHEA_BUSMAP_START      0x8000000000000000ULL
+
 #define EHEA_WATCH_DOG_TIMEOUT 10*HZ
 
 /* utility functions */
@@ -186,6 +188,12 @@ struct h_epas {
 				   set to 0 if unused */
 };
 
+struct ehea_busmap {
+	unsigned int entries;		/* total number of entries */
+	unsigned int valid_sections;	/* number of valid sections */
+	u64 *vaddr;
+};
+
 struct ehea_qp;
 struct ehea_cq;
 struct ehea_eq;
@@ -382,6 +390,8 @@ struct ehea_adapter {
 	struct ehea_mr mr;
 	u32 pd;                    /* protection domain */
 	u64 max_mc_mac;            /* max number of multicast mac addresses */
+	int active_ports;
+	struct list_head list;
 };
 
 
@@ -431,6 +441,9 @@ struct port_res_cfg {
 	int max_entries_rq3;
 };
 
+enum ehea_flag_bits {
+	__EHEA_STOP_XFER
+};
 
 void ehea_set_ethtool_ops(struct net_device *netdev);
 int ehea_sense_port_attr(struct ehea_port *port);
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 383144d..1d1571c 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -79,6 +79,11 @@ MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
 
 static int port_name_cnt = 0;
+static LIST_HEAD(adapter_list);
+u64 ehea_driver_flags = 0;
+struct workqueue_struct *ehea_driver_wq;
+struct work_struct ehea_rereg_mr_task;
+
 
 static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 					const struct of_device_id *id);
@@ -238,13 +243,17 @@ static int ehea_refill_rq_def(struct ehea_port_res *pr,
 		rwqe->wr_id = EHEA_BMASK_SET(EHEA_WR_ID_TYPE, wqe_type)
 			    | EHEA_BMASK_SET(EHEA_WR_ID_INDEX, index);
 		rwqe->sg_list[0].l_key = pr->recv_mr.lkey;
-		rwqe->sg_list[0].vaddr = (u64)skb->data;
+		rwqe->sg_list[0].vaddr = ehea_map_vaddr(skb->data);
 		rwqe->sg_list[0].len = packet_size;
 		rwqe->data_segments = 1;
 
 		index++;
 		index &= max_index_mask;
+
+		if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags)))
+			goto out;
 	}
+
 	q_skba->index = index;
 
 	/* Ring doorbell */
@@ -253,7 +262,7 @@ static int ehea_refill_rq_def(struct ehea_port_res *pr,
 		ehea_update_rq2a(pr->qp, i);
 	else
 		ehea_update_rq3a(pr->qp, i);
-
+out:
 	return ret;
 }
 
@@ -1321,7 +1330,7 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 			sg1entry->len = skb_data_size - headersize;
 
 			tmp_addr = (u64)(skb->data + headersize);
-			sg1entry->vaddr = tmp_addr;
+			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
 			swqe->descriptors++;
 		}
 	} else
@@ -1352,7 +1361,7 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 			sg1entry->l_key = lkey;
 			sg1entry->len = skb_data_size - SWQE2_MAX_IMM;
 			tmp_addr = (u64)(skb->data + SWQE2_MAX_IMM);
-			sg1entry->vaddr = tmp_addr;
+			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
 			swqe->descriptors++;
 		}
 	} else {
@@ -1391,7 +1400,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 			sg1entry->len = frag->size;
 			tmp_addr =  (u64)(page_address(frag->page)
 					  + frag->page_offset);
-			sg1entry->vaddr = tmp_addr;
+			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
 			swqe->descriptors++;
 			sg1entry_contains_frag_data = 1;
 		}
@@ -1406,7 +1415,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 			tmp_addr = (u64)(page_address(frag->page)
 					 + frag->page_offset);
-			sgentry->vaddr = tmp_addr;
+			sgentry->vaddr = ehea_map_vaddr(tmp_addr);
 			swqe->descriptors++;
 		}
 	}
@@ -1878,6 +1887,9 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ehea_dump(swqe, 512, "swqe");
 	}
 
+	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags)))
+		goto out;
+
 	ehea_post_swqe(pr->qp, swqe);
 	pr->tx_packets++;
 
@@ -1892,7 +1904,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	dev->trans_start = jiffies;
 	spin_unlock(&pr->xmit_lock);
-
+out:
 	return NETDEV_TX_OK;
 }
 
@@ -2220,6 +2232,9 @@ out_dereg_bc:
 out_clean_pr:
 	ehea_clean_all_portres(port);
 out:
+	if (ret)
+		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
+
 	return ret;
 }
 
@@ -2259,8 +2274,13 @@ static int ehea_down(struct net_device *dev)
 			msleep(1);
 
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-	ret = ehea_clean_all_portres(port);
 	port->state = EHEA_PORT_DOWN;
+
+	ret = ehea_clean_all_portres(port);
+	if (ret)
+		ehea_info("Failed freeing resources for %s. ret=%i",
+			  dev->name, ret);
+
 	return ret;
 }
 
@@ -2292,15 +2312,11 @@ static void ehea_reset_port(struct work_struct *work)
 	netif_stop_queue(dev);
 	netif_poll_disable(dev);
 
-	ret = ehea_down(dev);
-	if (ret)
-		ehea_error("ehea_down failed. not all resources are freed");
+	ehea_down(dev);
 
 	ret = ehea_up(dev);
-	if (ret) {
-		ehea_error("Reset device %s failed: ret=%d", dev->name, ret);
+	if (ret)
 		goto out;
-	}
 
 	if (netif_msg_timer(port))
 		ehea_info("Device %s resetted successfully", dev->name);
@@ -2312,6 +2328,88 @@ out:
 	return;
 }
 
+static void ehea_rereg_mrs(struct work_struct *work)
+{
+	int ret, i;
+	struct ehea_adapter *adapter;
+
+	ehea_info("LPAR memory enlarged - re-initializing driver");
+
+	list_for_each_entry(adapter, &adapter_list, list)
+		if (adapter->active_ports) {
+			/* Shutdown all ports */
+			for (i = 0; i < EHEA_MAX_PORTS; i++) {
+				struct ehea_port *port = adapter->port[i];
+
+				if (port) {
+					struct net_device *dev = port->netdev;
+
+					if (dev->flags & IFF_UP) {
+						ehea_info("stopping %s",
+							  dev->name);
+						down(&port->port_lock);
+						netif_stop_queue(dev);
+						netif_poll_disable(dev);
+						ehea_down(dev);
+						up(&port->port_lock);
+					}
+				}
+			}
+
+			/* Unregister old memory region */
+			ret = ehea_rem_mr(&adapter->mr);
+			if (ret) {
+				ehea_error("unregister MR failed - driver"
+					   " inoperable!");
+				goto out;
+			}
+		}
+
+	ehea_destroy_busmap();
+
+	ret = ehea_create_busmap();
+	if (ret)
+		goto out;
+
+	clear_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
+
+	list_for_each_entry(adapter, &adapter_list, list)
+		if (adapter->active_ports) {
+			/* Register new memory region */
+			ret = ehea_reg_kernel_mr(adapter, &adapter->mr);
+			if (ret) {
+				ehea_error("register MR failed - driver"
+					   " inoperable!");
+				goto out;
+			}
+
+			/* Restart all ports */
+			for (i = 0; i < EHEA_MAX_PORTS; i++) {
+				struct ehea_port *port = adapter->port[i];
+
+				if (port) {
+					struct net_device *dev = port->netdev;
+
+					if (dev->flags & IFF_UP) {
+						ehea_info("restarting %s",
+							  dev->name);
+						down(&port->port_lock);
+
+						ret = ehea_up(dev);
+						if (!ret) {
+							netif_poll_enable(dev);
+							netif_wake_queue(dev);
+						}
+
+						up(&port->port_lock);
+					}
+				}
+			}
+		}
+out:
+	return;
+}
+
 static void ehea_tx_watchdog(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -2573,6 +2671,8 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	ehea_info("%s: Jumbo frames are %sabled", dev->name,
 		  jumbo == 1 ? "en" : "dis");
 
+	adapter->active_ports++;
+
 	return port;
 
 out_unreg_port:
@@ -2596,6 +2696,7 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
+	port->adapter->active_ports--;
 }
 
 static int ehea_setup_ports(struct ehea_adapter *adapter)
@@ -2788,6 +2889,8 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 		goto out;
 	}
 
+	list_add(&adapter->list, &adapter_list);
+
 	adapter->ebus_dev = dev;
 
 	adapter_handle = of_get_property(dev->ofdev.node, "ibm,hea-handle",
@@ -2891,7 +2994,10 @@ static int __devexit ehea_remove(struct ibmebus_dev *dev)
 
 	ehea_destroy_eq(adapter->neq);
 	ehea_remove_adapter_mr(adapter);
+	list_del(&adapter->list);
+
 	kfree(adapter);
+
 	return 0;
 }
 
@@ -2939,9 +3045,18 @@ int __init ehea_module_init(void)
 	printk(KERN_INFO "IBM eHEA ethernet device driver (Release %s)\n",
 	       DRV_VERSION);
 
+	ehea_driver_wq = create_workqueue("ehea_driver_wq");
+
+	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
+
 	ret = check_module_parm();
 	if (ret)
 		goto out;
+
+	ret = ehea_create_busmap();
+	if (ret)
+		goto out;
+
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
@@ -2965,6 +3080,7 @@ static void __exit ehea_module_exit(void)
 {
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
+	ehea_destroy_busmap();
 }
 
 module_init(ehea_module_init);
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ehea/ehea_phyp.h
index d17a45a..89b6353 100644
--- a/drivers/net/ehea/ehea_phyp.h
+++ b/drivers/net/ehea/ehea_phyp.h
@@ -60,6 +60,9 @@ static inline u32 get_longbusy_msecs(int long_busy_ret_code)
 	}
 }
 
+/* Number of pages which can be registered at once by H_REGISTER_HEA_RPAGES */
+#define EHEA_MAX_RPAGE 512
+
 /* Notification Event Queue (NEQ) Entry bit masks */
 #define NEQE_EVENT_CODE		EHEA_BMASK_IBM(2, 7)
 #define NEQE_PORTNUM  		EHEA_BMASK_IBM(32, 47)
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 29eaa46..a36fa6c 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -31,6 +31,13 @@
 #include "ehea_phyp.h"
 #include "ehea_qmr.h"
 
+
+struct ehea_busmap ehea_bmap = { 0, 0, NULL };
+extern u64 ehea_driver_flags;
+extern struct workqueue_struct *ehea_driver_wq;
+extern struct work_struct ehea_rereg_mr_task;
+
+
 static void *hw_qpageit_get_inc(struct hw_queue *queue)
 {
 	void *retvalue = hw_qeit_get(queue);
@@ -547,18 +554,84 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	return 0;
 }
 
+int ehea_create_busmap( void )
+{
+	u64 vaddr = EHEA_BUSMAP_START;
+	unsigned long abs_max_pfn = 0;
+	unsigned long sec_max_pfn;
+	int i;
+
+	/*
+	 * Sections are not in ascending order -> Loop over all sections and
+	 * find the highest PFN to compute the required map size.
+	*/
+	ehea_bmap.valid_sections = 0;
+
+	for (i = 0; i < NR_MEM_SECTIONS; i++)
+		if (valid_section_nr(i)) {
+			sec_max_pfn = section_nr_to_pfn(i);
+			if (sec_max_pfn > abs_max_pfn)
+				abs_max_pfn = sec_max_pfn;
+			ehea_bmap.valid_sections++;
+		}
+
+	ehea_bmap.entries = abs_max_pfn / EHEA_PAGES_PER_SECTION + 1;
+	ehea_bmap.vaddr = vmalloc(ehea_bmap.entries * sizeof(*ehea_bmap.vaddr));
+
+	if (!ehea_bmap.vaddr)
+		return -ENOMEM;
+
+	for (i = 0 ; i < ehea_bmap.entries; i++) {
+		unsigned long pfn = section_nr_to_pfn(i);
+
+		if (pfn_valid(pfn)) {
+			ehea_bmap.vaddr[i] = vaddr;
+			vaddr += EHEA_SECTSIZE;
+		} else
+			ehea_bmap.vaddr[i] = 0;
+	}
+
+	return 0;
+}
+
+void ehea_destroy_busmap( void )
+{
+	vfree(ehea_bmap.vaddr);
+}
+
+u64 ehea_map_vaddr(void *caddr)
+{
+	u64 mapped_addr;
+	unsigned long index = __pa(caddr) >> SECTION_SIZE_BITS;
+
+	if (likely(index < ehea_bmap.entries)) {
+		mapped_addr = ehea_bmap.vaddr[index];
+		if (likely(mapped_addr))
+			mapped_addr |= (((unsigned long)caddr)
+					& (EHEA_SECTSIZE - 1));
+		else
+			mapped_addr = -1;
+	} else
+		mapped_addr = -1;
+
+	if (unlikely(mapped_addr == -1))
+		if (!test_and_set_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
+			queue_work(ehea_driver_wq, &ehea_rereg_mr_task);
+
+	return mapped_addr;
+}
+
 int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 {
-	int i, k, ret;
-	u64 hret, pt_abs, start, end, nr_pages;
-	u32 acc_ctrl = EHEA_MR_ACC_CTRL;
+	int ret;
 	u64 *pt;
+	void *pg;
+	u64 hret, pt_abs, i, j, m, mr_len;
+	u32 acc_ctrl = EHEA_MR_ACC_CTRL;
 
-	start = KERNELBASE;
-	end = (u64)high_memory;
-	nr_pages = (end - start) / EHEA_PAGESIZE;
+	mr_len = ehea_bmap.valid_sections * EHEA_SECTSIZE;
 
-	pt =  kzalloc(PAGE_SIZE, GFP_KERNEL);
+	pt =  kzalloc(EHEA_MAX_RPAGE * sizeof(u64), GFP_KERNEL);
 	if (!pt) {
 		ehea_error("no mem");
 		ret = -ENOMEM;
@@ -566,7 +639,8 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 	}
 	pt_abs = virt_to_abs(pt);
 
-	hret = ehea_h_alloc_resource_mr(adapter->handle, start, end - start,
+	hret = ehea_h_alloc_resource_mr(adapter->handle,
+					EHEA_BUSMAP_START, mr_len,
 					acc_ctrl, adapter->pd,
 					&mr->handle, &mr->lkey);
 	if (hret != H_SUCCESS) {
@@ -575,49 +649,43 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 		goto out;
 	}
 
-	mr->vaddr = KERNELBASE;
-	k = 0;
-
-	while (nr_pages > 0) {
-		if (nr_pages > 1) {
-			u64 num_pages = min(nr_pages, (u64)512);
-			for (i = 0; i < num_pages; i++)
-				pt[i] = virt_to_abs((void*)(((u64)start) +
-							    ((k++) *
-							     EHEA_PAGESIZE)));
-
-			hret = ehea_h_register_rpage_mr(adapter->handle,
-							mr->handle, 0,
-							0, (u64)pt_abs,
-							num_pages);
-			nr_pages -= num_pages;
-		} else {
-			u64 abs_adr = virt_to_abs((void*)(((u64)start) +
-							  (k * EHEA_PAGESIZE)));
-
-			hret = ehea_h_register_rpage_mr(adapter->handle,
-							mr->handle, 0,
-							0, abs_adr,1);
-			nr_pages--;
-		}
-
-		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED)) {
-			ehea_h_free_resource(adapter->handle,
-					     mr->handle, FORCE_FREE);
-			ehea_error("register_rpage_mr failed");
-			ret = -EIO;
-			goto out;
+	for (i = 0 ; i < ehea_bmap.entries; i++)
+		if (ehea_bmap.vaddr[i]) {
+			void *sectbase = __va(i << SECTION_SIZE_BITS);
+			unsigned long k = 0;
+
+			for (j = 0; j < (PAGES_PER_SECTION / EHEA_MAX_RPAGE);
+			      j++) {
+
+				for (m = 0; m < EHEA_MAX_RPAGE; m++) {
+					pg = sectbase + ((k++) * EHEA_PAGESIZE);
+					pt[m] = virt_to_abs(pg);
+				}
+
+				hret = ehea_h_register_rpage_mr(adapter->handle,
+								mr->handle,
+								0, 0, pt_abs,
+								EHEA_MAX_RPAGE);
+				if ((hret != H_SUCCESS)
+				    && (hret != H_PAGE_REGISTERED)) {
+					ehea_h_free_resource(adapter->handle,
+							     mr->handle,
+							     FORCE_FREE);
+					ehea_error("register_rpage_mr failed");
+					ret = -EIO;
+					goto out;
+				}
+			}
 		}
-	}
 
 	if (hret != H_SUCCESS) {
-		ehea_h_free_resource(adapter->handle, mr->handle,
-				     FORCE_FREE);
-		ehea_error("register_rpage failed for last page");
+		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
+		ehea_error("registering mr failed");
 		ret = -EIO;
 		goto out;
 	}
 
+	mr->vaddr = EHEA_BUSMAP_START;
 	mr->adapter = adapter;
 	ret = 0;
 out:
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index c0eb3e0..b71f845 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -36,8 +36,14 @@
  * page size of ehea hardware queues
  */
 
-#define EHEA_PAGESHIFT  12
-#define EHEA_PAGESIZE   4096UL
+#define EHEA_PAGESHIFT         12
+#define EHEA_PAGESIZE          (1UL << EHEA_PAGESHIFT)
+#define EHEA_SECTSIZE          (1UL << 24)
+#define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> PAGE_SHIFT)
+
+#if (1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE
+#error eHEA module can't work if kernel sectionsize < ehea sectionsize
+#endif
 
 /* Some abbreviations used here:
  *
@@ -372,4 +378,8 @@ int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
+int ehea_create_busmap( void );
+void ehea_destroy_busmap( void );
+u64 ehea_map_vaddr(void *caddr);
+
 #endif	/* __EHEA_QMR_H__ */
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 42ba1c0..a361dba 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -550,6 +550,8 @@ union ring_type {
 /* PHY defines */
 #define PHY_OUI_MARVELL	0x5043
 #define PHY_OUI_CICADA	0x03f1
+#define PHY_OUI_VITESSE	0x01c1
+#define PHY_OUI_REALTEK	0x01c1
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
@@ -557,12 +559,36 @@ union ring_type {
 #define PHYID2_MODEL_MASK		0x03f0
 #define PHY_MODEL_MARVELL_E3016		0x220
 #define PHY_MARVELL_E3016_INITMASK	0x0300
-#define PHY_INIT1	0x0f000
-#define PHY_INIT2	0x0e00
-#define PHY_INIT3	0x01000
-#define PHY_INIT4	0x0200
-#define PHY_INIT5	0x0004
-#define PHY_INIT6	0x02000
+#define PHY_CICADA_INIT1	0x0f000
+#define PHY_CICADA_INIT2	0x0e00
+#define PHY_CICADA_INIT3	0x01000
+#define PHY_CICADA_INIT4	0x0200
+#define PHY_CICADA_INIT5	0x0004
+#define PHY_CICADA_INIT6	0x02000
+#define PHY_VITESSE_INIT_REG1	0x1f
+#define PHY_VITESSE_INIT_REG2	0x10
+#define PHY_VITESSE_INIT_REG3	0x11
+#define PHY_VITESSE_INIT_REG4	0x12
+#define PHY_VITESSE_INIT_MSK1	0xc
+#define PHY_VITESSE_INIT_MSK2	0x0180
+#define PHY_VITESSE_INIT1	0x52b5
+#define PHY_VITESSE_INIT2	0xaf8a
+#define PHY_VITESSE_INIT3	0x8
+#define PHY_VITESSE_INIT4	0x8f8a
+#define PHY_VITESSE_INIT5	0xaf86
+#define PHY_VITESSE_INIT6	0x8f86
+#define PHY_VITESSE_INIT7	0xaf82
+#define PHY_VITESSE_INIT8	0x0100
+#define PHY_VITESSE_INIT9	0x8f82
+#define PHY_VITESSE_INIT10	0x0
+#define PHY_REALTEK_INIT_REG1	0x1f
+#define PHY_REALTEK_INIT_REG2	0x19
+#define PHY_REALTEK_INIT_REG3	0x13
+#define PHY_REALTEK_INIT1	0x0000
+#define PHY_REALTEK_INIT2	0x8e00
+#define PHY_REALTEK_INIT3	0x0001
+#define PHY_REALTEK_INIT4	0xad17
+
 #define PHY_GIGABIT	0x0100
 
 #define PHY_TIMEOUT	0x1
@@ -1096,6 +1122,28 @@ static int phy_init(struct net_device *dev)
 			return PHY_ERROR;
 		}
 	}
+	if (np->phy_oui == PHY_OUI_REALTEK) {
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
 
 	/* set advertise register */
 	reg = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
@@ -1141,14 +1189,14 @@ static int phy_init(struct net_device *dev)
 	/* phy vendor specific configuration */
 	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII) ) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
-		phy_reserved &= ~(PHY_INIT1 | PHY_INIT2);
-		phy_reserved |= (PHY_INIT3 | PHY_INIT4);
+		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
+		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
 		if (mii_rw(dev, np->phyaddr, MII_RESV1, phy_reserved)) {
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
-		phy_reserved |= PHY_INIT5;
+		phy_reserved |= PHY_CICADA_INIT5;
 		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, phy_reserved)) {
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
@@ -1156,12 +1204,106 @@ static int phy_init(struct net_device *dev)
 	}
 	if (np->phy_oui == PHY_OUI_CICADA) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_SREVISION, MII_READ);
-		phy_reserved |= PHY_INIT6;
+		phy_reserved |= PHY_CICADA_INIT6;
 		if (mii_rw(dev, np->phyaddr, MII_SREVISION, phy_reserved)) {
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
+	if (np->phy_oui == PHY_OUI_VITESSE) {
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT2)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
+		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
+		phy_reserved |= PHY_VITESSE_INIT3;
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT4)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT5)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
+		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
+		phy_reserved |= PHY_VITESSE_INIT3;
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT6)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT7)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
+		phy_reserved &= ~PHY_VITESSE_INIT_MSK2;
+		phy_reserved |= PHY_VITESSE_INIT8;
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT9)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT10)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
+	if (np->phy_oui == PHY_OUI_REALTEK) {
+		/* reset could have cleared these out, set them back */
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
+
 	/* some phys clear out pause advertisment on reset, set it back */
 	mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg);
 
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 5dd34a1..ac3596f 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -31,7 +31,6 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-#include <asm/ocp.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 0e04f7a..a4bb026 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -17,13 +17,12 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/mii.h>
-#include <linux/mutex.h>
 #include <linux/dma-mapping.h>
-#include <linux/ethtool.h>
 #include <linux/platform_device.h>
+#include <linux/phy.h>
 
 #include <asm/arch/board.h>
+#include <asm/arch/cpu.h>
 
 #include "macb.h"
 
@@ -85,172 +84,202 @@ static void __init macb_get_hwaddr(struct macb *bp)
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 }
 
-static void macb_enable_mdio(struct macb *bp)
+static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
-	unsigned long flags;
-	u32 reg;
-
-	spin_lock_irqsave(&bp->lock, flags);
-	reg = macb_readl(bp, NCR);
-	reg |= MACB_BIT(MPE);
-	macb_writel(bp, NCR, reg);
-	macb_writel(bp, IER, MACB_BIT(MFD));
-	spin_unlock_irqrestore(&bp->lock, flags);
-}
-
-static void macb_disable_mdio(struct macb *bp)
-{
-	unsigned long flags;
-	u32 reg;
-
-	spin_lock_irqsave(&bp->lock, flags);
-	reg = macb_readl(bp, NCR);
-	reg &= ~MACB_BIT(MPE);
-	macb_writel(bp, NCR, reg);
-	macb_writel(bp, IDR, MACB_BIT(MFD));
-	spin_unlock_irqrestore(&bp->lock, flags);
-}
-
-static int macb_mdio_read(struct net_device *dev, int phy_id, int location)
-{
-	struct macb *bp = netdev_priv(dev);
+	struct macb *bp = bus->priv;
 	int value;
 
-	mutex_lock(&bp->mdio_mutex);
-
-	macb_enable_mdio(bp);
 	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
 			      | MACB_BF(RW, MACB_MAN_READ)
-			      | MACB_BF(PHYA, phy_id)
-			      | MACB_BF(REGA, location)
+			      | MACB_BF(PHYA, mii_id)
+			      | MACB_BF(REGA, regnum)
 			      | MACB_BF(CODE, MACB_MAN_CODE)));
 
-	wait_for_completion(&bp->mdio_complete);
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
+		cpu_relax();
 
 	value = MACB_BFEXT(DATA, macb_readl(bp, MAN));
-	macb_disable_mdio(bp);
-	mutex_unlock(&bp->mdio_mutex);
 
 	return value;
 }
 
-static void macb_mdio_write(struct net_device *dev, int phy_id,
-			    int location, int val)
+static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+			   u16 value)
 {
-	struct macb *bp = netdev_priv(dev);
-
-	dev_dbg(&bp->pdev->dev, "mdio_write %02x:%02x <- %04x\n",
-		phy_id, location, val);
-
-	mutex_lock(&bp->mdio_mutex);
-	macb_enable_mdio(bp);
+	struct macb *bp = bus->priv;
 
 	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
 			      | MACB_BF(RW, MACB_MAN_WRITE)
-			      | MACB_BF(PHYA, phy_id)
-			      | MACB_BF(REGA, location)
+			      | MACB_BF(PHYA, mii_id)
+			      | MACB_BF(REGA, regnum)
 			      | MACB_BF(CODE, MACB_MAN_CODE)
-			      | MACB_BF(DATA, val)));
+			      | MACB_BF(DATA, value)));
 
-	wait_for_completion(&bp->mdio_complete);
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
+		cpu_relax();
 
-	macb_disable_mdio(bp);
-	mutex_unlock(&bp->mdio_mutex);
+	return 0;
 }
 
-static int macb_phy_probe(struct macb *bp)
+static int macb_mdio_reset(struct mii_bus *bus)
 {
-	int phy_address;
-	u16 phyid1, phyid2;
+	return 0;
+}
 
-	for (phy_address = 0; phy_address < 32; phy_address++) {
-		phyid1 = macb_mdio_read(bp->dev, phy_address, MII_PHYSID1);
-		phyid2 = macb_mdio_read(bp->dev, phy_address, MII_PHYSID2);
+static void macb_handle_link_change(struct net_device *dev)
+{
+	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
+	unsigned long flags;
 
-		if (phyid1 != 0xffff && phyid1 != 0x0000
-		    && phyid2 != 0xffff && phyid2 != 0x0000)
-			break;
+	int status_change = 0;
+
+	spin_lock_irqsave(&bp->lock, flags);
+
+	if (phydev->link) {
+		if ((bp->speed != phydev->speed) ||
+		    (bp->duplex != phydev->duplex)) {
+			u32 reg;
+
+			reg = macb_readl(bp, NCFGR);
+			reg &= ~(MACB_BIT(SPD) | MACB_BIT(FD));
+
+			if (phydev->duplex)
+				reg |= MACB_BIT(FD);
+			if (phydev->speed)
+				reg |= MACB_BIT(SPD);
+
+			macb_writel(bp, NCFGR, reg);
+
+			bp->speed = phydev->speed;
+			bp->duplex = phydev->duplex;
+			status_change = 1;
+		}
 	}
 
-	if (phy_address == 32)
-		return -ENODEV;
+	if (phydev->link != bp->link) {
+		if (phydev->link)
+			netif_schedule(dev);
+		else {
+			bp->speed = 0;
+			bp->duplex = -1;
+		}
+		bp->link = phydev->link;
 
-	dev_info(&bp->pdev->dev,
-		 "detected PHY at address %d (ID %04x:%04x)\n",
-		 phy_address, phyid1, phyid2);
+		status_change = 1;
+	}
 
-	bp->mii.phy_id = phy_address;
-	return 0;
+	spin_unlock_irqrestore(&bp->lock, flags);
+
+	if (status_change) {
+		if (phydev->link)
+			printk(KERN_INFO "%s: link up (%d/%s)\n",
+			       dev->name, phydev->speed,
+			       DUPLEX_FULL == phydev->duplex ? "Full":"Half");
+		else
+			printk(KERN_INFO "%s: link down\n", dev->name);
+	}
 }
 
-static void macb_set_media(struct macb *bp, int media)
+/* based on au1000_eth. c*/
+static int macb_mii_probe(struct net_device *dev)
 {
-	u32 reg;
+	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	struct eth_platform_data *pdata;
+	int phy_addr;
 
-	spin_lock_irq(&bp->lock);
-	reg = macb_readl(bp, NCFGR);
-	reg &= ~(MACB_BIT(SPD) | MACB_BIT(FD));
-	if (media & (ADVERTISE_100HALF | ADVERTISE_100FULL))
-		reg |= MACB_BIT(SPD);
-	if (media & ADVERTISE_FULL)
-		reg |= MACB_BIT(FD);
-	macb_writel(bp, NCFGR, reg);
-	spin_unlock_irq(&bp->lock);
+	/* find the first phy */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (bp->mii_bus.phy_map[phy_addr]) {
+			phydev = bp->mii_bus.phy_map[phy_addr];
+			break;
+		}
+	}
+
+	if (!phydev) {
+		printk (KERN_ERR "%s: no PHY found\n", dev->name);
+		return -1;
+	}
+
+	pdata = bp->pdev->dev.platform_data;
+	/* TODO : add pin_irq */
+
+	/* attach the mac to the phy */
+	if (pdata && pdata->is_rmii) {
+		phydev = phy_connect(dev, phydev->dev.bus_id,
+			&macb_handle_link_change, 0, PHY_INTERFACE_MODE_RMII);
+	} else {
+		phydev = phy_connect(dev, phydev->dev.bus_id,
+			&macb_handle_link_change, 0, PHY_INTERFACE_MODE_MII);
+	}
+
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	/* mask with MAC supported features */
+	phydev->supported &= PHY_BASIC_FEATURES;
+
+	phydev->advertising = phydev->supported;
+
+	bp->link = 0;
+	bp->speed = 0;
+	bp->duplex = -1;
+	bp->phy_dev = phydev;
+
+	return 0;
 }
 
-static void macb_check_media(struct macb *bp, int ok_to_print, int init_media)
+static int macb_mii_init(struct macb *bp)
 {
-	struct mii_if_info *mii = &bp->mii;
-	unsigned int old_carrier, new_carrier;
-	int advertise, lpa, media, duplex;
+	struct eth_platform_data *pdata;
+	int err = -ENXIO, i;
 
-	/* if forced media, go no further */
-	if (mii->force_media)
-		return;
+	/* Enable managment port */
+	macb_writel(bp, NCR, MACB_BIT(MPE));
 
-	/* check current and old link status */
-	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
-	new_carrier = (unsigned int) mii_link_ok(mii);
+	bp->mii_bus.name = "MACB_mii_bus",
+	bp->mii_bus.read = &macb_mdio_read,
+	bp->mii_bus.write = &macb_mdio_write,
+	bp->mii_bus.reset = &macb_mdio_reset,
+	bp->mii_bus.id = bp->pdev->id,
+	bp->mii_bus.priv = bp,
+	bp->mii_bus.dev = &bp->dev->dev;
+	pdata = bp->pdev->dev.platform_data;
 
-	/* if carrier state did not change, assume nothing else did */
-	if (!init_media && old_carrier == new_carrier)
-		return;
+	if (pdata)
+		bp->mii_bus.phy_mask = pdata->phy_mask;
 
-	/* no carrier, nothing much to do */
-	if (!new_carrier) {
-		netif_carrier_off(mii->dev);
-		printk(KERN_INFO "%s: link down\n", mii->dev->name);
-		return;
+	bp->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bp->mii_bus.irq) {
+		err = -ENOMEM;
+		goto err_out;
 	}
 
-	/*
-	 * we have carrier, see who's on the other end
-	 */
-	netif_carrier_on(mii->dev);
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bp->mii_bus.irq[i] = PHY_POLL;
 
-	/* get MII advertise and LPA values */
-	if (!init_media && mii->advertising) {
-		advertise = mii->advertising;
-	} else {
-		advertise = mii->mdio_read(mii->dev, mii->phy_id, MII_ADVERTISE);
-		mii->advertising = advertise;
-	}
-	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
+	platform_set_drvdata(bp->dev, &bp->mii_bus);
 
-	/* figure out media and duplex from advertise and LPA values */
-	media = mii_nway_result(lpa & advertise);
-	duplex = (media & ADVERTISE_FULL) ? 1 : 0;
+	if (mdiobus_register(&bp->mii_bus))
+		goto err_out_free_mdio_irq;
 
-	if (ok_to_print)
-		printk(KERN_INFO "%s: link up, %sMbps, %s-duplex, lpa 0x%04X\n",
-		       mii->dev->name,
-		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ? "100" : "10",
-		       duplex ? "full" : "half", lpa);
+	if (macb_mii_probe(bp->dev) != 0) {
+		goto err_out_unregister_bus;
+	}
 
-	mii->full_duplex = duplex;
+	return 0;
 
-	/* Let the MAC know about the new link state */
-	macb_set_media(bp, media);
+err_out_unregister_bus:
+	mdiobus_unregister(&bp->mii_bus);
+err_out_free_mdio_irq:
+	kfree(bp->mii_bus.irq);
+err_out:
+	return err;
 }
 
 static void macb_update_stats(struct macb *bp)
@@ -265,16 +294,6 @@ static void macb_update_stats(struct macb *bp)
 		*p += __raw_readl(reg);
 }
 
-static void macb_periodic_task(struct work_struct *work)
-{
-	struct macb *bp = container_of(work, struct macb, periodic_task.work);
-
-	macb_update_stats(bp);
-	macb_check_media(bp, 1, 0);
-
-	schedule_delayed_work(&bp->periodic_task, HZ);
-}
-
 static void macb_tx(struct macb *bp)
 {
 	unsigned int tail;
@@ -519,9 +538,6 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	spin_lock(&bp->lock);
 
 	while (status) {
-		if (status & MACB_BIT(MFD))
-			complete(&bp->mdio_complete);
-
 		/* close possible race with dev_close */
 		if (unlikely(!netif_running(dev))) {
 			macb_writel(bp, IDR, ~0UL);
@@ -535,7 +551,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				 * until we have processed the buffers
 				 */
 				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
-				dev_dbg(&bp->pdev->dev, "scheduling RX softirq\n");
+				dev_dbg(&bp->pdev->dev,
+					"scheduling RX softirq\n");
 				__netif_rx_schedule(dev);
 			}
 		}
@@ -765,7 +782,7 @@ static void macb_init_hw(struct macb *bp)
 	macb_writel(bp, TBQP, bp->tx_ring_dma);
 
 	/* Enable TX and RX */
-	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE));
+	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
 
 	/* Enable interrupts */
 	macb_writel(bp, IER, (MACB_BIT(RCOMP)
@@ -776,18 +793,126 @@ static void macb_init_hw(struct macb *bp)
 			      | MACB_BIT(TCOMP)
 			      | MACB_BIT(ISR_ROVR)
 			      | MACB_BIT(HRESP)));
+
 }
 
-static void macb_init_phy(struct net_device *dev)
+/*
+ * The hash address register is 64 bits long and takes up two
+ * locations in the memory map.  The least significant bits are stored
+ * in EMAC_HSL and the most significant bits in EMAC_HSH.
+ *
+ * The unicast hash enable and the multicast hash enable bits in the
+ * network configuration register enable the reception of hash matched
+ * frames. The destination address is reduced to a 6 bit index into
+ * the 64 bit hash register using the following hash function.  The
+ * hash function is an exclusive or of every sixth bit of the
+ * destination address.
+ *
+ * hi[5] = da[5] ^ da[11] ^ da[17] ^ da[23] ^ da[29] ^ da[35] ^ da[41] ^ da[47]
+ * hi[4] = da[4] ^ da[10] ^ da[16] ^ da[22] ^ da[28] ^ da[34] ^ da[40] ^ da[46]
+ * hi[3] = da[3] ^ da[09] ^ da[15] ^ da[21] ^ da[27] ^ da[33] ^ da[39] ^ da[45]
+ * hi[2] = da[2] ^ da[08] ^ da[14] ^ da[20] ^ da[26] ^ da[32] ^ da[38] ^ da[44]
+ * hi[1] = da[1] ^ da[07] ^ da[13] ^ da[19] ^ da[25] ^ da[31] ^ da[37] ^ da[43]
+ * hi[0] = da[0] ^ da[06] ^ da[12] ^ da[18] ^ da[24] ^ da[30] ^ da[36] ^ da[42]
+ *
+ * da[0] represents the least significant bit of the first byte
+ * received, that is, the multicast/unicast indicator, and da[47]
+ * represents the most significant bit of the last byte received.  If
+ * the hash index, hi[n], points to a bit that is set in the hash
+ * register then the frame will be matched according to whether the
+ * frame is multicast or unicast.  A multicast match will be signalled
+ * if the multicast hash enable bit is set, da[0] is 1 and the hash
+ * index points to a bit set in the hash register.  A unicast match
+ * will be signalled if the unicast hash enable bit is set, da[0] is 0
+ * and the hash index points to a bit set in the hash register.  To
+ * receive all multicast frames, the hash register should be set with
+ * all ones and the multicast hash enable bit should be set in the
+ * network configuration register.
+ */
+
+static inline int hash_bit_value(int bitnr, __u8 *addr)
 {
+	if (addr[bitnr / 8] & (1 << (bitnr % 8)))
+		return 1;
+	return 0;
+}
+
+/*
+ * Return the hash index value for the specified address.
+ */
+static int hash_get_index(__u8 *addr)
+{
+	int i, j, bitval;
+	int hash_index = 0;
+
+	for (j = 0; j < 6; j++) {
+		for (i = 0, bitval = 0; i < 8; i++)
+			bitval ^= hash_bit_value(i*6 + j, addr);
+
+		hash_index |= (bitval << j);
+	}
+
+	return hash_index;
+}
+
+/*
+ * Add multicast addresses to the internal multicast-hash table.
+ */
+static void macb_sethashtable(struct net_device *dev)
+{
+	struct dev_mc_list *curr;
+	unsigned long mc_filter[2];
+	unsigned int i, bitnr;
+	struct macb *bp = netdev_priv(dev);
+
+	mc_filter[0] = mc_filter[1] = 0;
+
+	curr = dev->mc_list;
+	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+		if (!curr) break;	/* unexpected end of list */
+
+		bitnr = hash_get_index(curr->dmi_addr);
+		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
+	}
+
+	macb_writel(bp, HRB, mc_filter[0]);
+	macb_writel(bp, HRT, mc_filter[1]);
+}
+
+/*
+ * Enable/Disable promiscuous and multicast modes.
+ */
+static void macb_set_rx_mode(struct net_device *dev)
+{
+	unsigned long cfg;
 	struct macb *bp = netdev_priv(dev);
 
-	/* Set some reasonable default settings */
-	macb_mdio_write(dev, bp->mii.phy_id, MII_ADVERTISE,
-			ADVERTISE_CSMA | ADVERTISE_ALL);
-	macb_mdio_write(dev, bp->mii.phy_id, MII_BMCR,
-			(BMCR_SPEED100 | BMCR_ANENABLE
-			 | BMCR_ANRESTART | BMCR_FULLDPLX));
+	cfg = macb_readl(bp, NCFGR);
+
+	if (dev->flags & IFF_PROMISC)
+		/* Enable promiscuous mode */
+		cfg |= MACB_BIT(CAF);
+	else if (dev->flags & (~IFF_PROMISC))
+		 /* Disable promiscuous mode */
+		cfg &= ~MACB_BIT(CAF);
+
+	if (dev->flags & IFF_ALLMULTI) {
+		/* Enable all multicast mode */
+		macb_writel(bp, HRB, -1);
+		macb_writel(bp, HRT, -1);
+		cfg |= MACB_BIT(NCFGR_MTI);
+	} else if (dev->mc_count > 0) {
+		/* Enable specific multicasts */
+		macb_sethashtable(dev);
+		cfg |= MACB_BIT(NCFGR_MTI);
+	} else if (dev->flags & (~IFF_ALLMULTI)) {
+		/* Disable all multicast mode */
+		macb_writel(bp, HRB, 0);
+		macb_writel(bp, HRT, 0);
+		cfg &= ~MACB_BIT(NCFGR_MTI);
+	}
+
+	macb_writel(bp, NCFGR, cfg);
 }
 
 static int macb_open(struct net_device *dev)
@@ -797,6 +922,10 @@ static int macb_open(struct net_device *dev)
 
 	dev_dbg(&bp->pdev->dev, "open\n");
 
+	/* if the phy is not yet register, retry later*/
+	if (!bp->phy_dev)
+		return -EAGAIN;
+
 	if (!is_valid_ether_addr(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
@@ -810,12 +939,11 @@ static int macb_open(struct net_device *dev)
 
 	macb_init_rings(bp);
 	macb_init_hw(bp);
-	macb_init_phy(dev);
 
-	macb_check_media(bp, 1, 1);
-	netif_start_queue(dev);
+	/* schedule a link state check */
+	phy_start(bp->phy_dev);
 
-	schedule_delayed_work(&bp->periodic_task, HZ);
+	netif_start_queue(dev);
 
 	return 0;
 }
@@ -825,10 +953,11 @@ static int macb_close(struct net_device *dev)
 	struct macb *bp = netdev_priv(dev);
 	unsigned long flags;
 
-	cancel_rearming_delayed_work(&bp->periodic_task);
-
 	netif_stop_queue(dev);
 
+	if (bp->phy_dev)
+		phy_stop(bp->phy_dev);
+
 	spin_lock_irqsave(&bp->lock, flags);
 	macb_reset_hw(bp);
 	netif_carrier_off(dev);
@@ -845,6 +974,9 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 	struct net_device_stats *nstat = &bp->stats;
 	struct macb_stats *hwstat = &bp->hw_stats;
 
+	/* read stats from hardware */
+	macb_update_stats(bp);
+
 	/* Convert HW stats into netdevice stats */
 	nstat->rx_errors = (hwstat->rx_fcs_errors +
 			    hwstat->rx_align_errors +
@@ -882,18 +1014,27 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
 
-	return mii_ethtool_gset(&bp->mii, cmd);
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(phydev, cmd);
 }
 
 static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
+
+	if (!phydev)
+		return -ENODEV;
 
-	return mii_ethtool_sset(&bp->mii, cmd);
+	return phy_ethtool_sset(phydev, cmd);
 }
 
-static void macb_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+static void macb_get_drvinfo(struct net_device *dev,
+			     struct ethtool_drvinfo *info)
 {
 	struct macb *bp = netdev_priv(dev);
 
@@ -902,104 +1043,34 @@ static void macb_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *inf
 	strcpy(info->bus_info, bp->pdev->dev.bus_id);
 }
 
-static int macb_nway_reset(struct net_device *dev)
-{
-	struct macb *bp = netdev_priv(dev);
-	return mii_nway_restart(&bp->mii);
-}
-
 static struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
 	.get_drvinfo		= macb_get_drvinfo,
-	.nway_reset		= macb_nway_reset,
 	.get_link		= ethtool_op_get_link,
 };
 
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct macb *bp = netdev_priv(dev);
+	struct phy_device *phydev = bp->phy_dev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	return generic_mii_ioctl(&bp->mii, if_mii(rq), cmd, NULL);
-}
-
-static ssize_t macb_mii_show(const struct device *_dev, char *buf,
-			unsigned long addr)
-{
-	struct net_device *dev = to_net_dev(_dev);
-	struct macb *bp = netdev_priv(dev);
-	ssize_t ret = -EINVAL;
-
-	if (netif_running(dev)) {
-		int value;
-		value = macb_mdio_read(dev, bp->mii.phy_id, addr);
-		ret = sprintf(buf, "0x%04x\n", (uint16_t)value);
-	}
-
-	return ret;
-}
-
-#define MII_ENTRY(name, addr)					\
-static ssize_t show_##name(struct device *_dev,			\
-			   struct device_attribute *attr,	\
-			   char *buf)				\
-{								\
-	return macb_mii_show(_dev, buf, addr);			\
-}								\
-static DEVICE_ATTR(name, S_IRUGO, show_##name, NULL)
-
-MII_ENTRY(bmcr, MII_BMCR);
-MII_ENTRY(bmsr, MII_BMSR);
-MII_ENTRY(physid1, MII_PHYSID1);
-MII_ENTRY(physid2, MII_PHYSID2);
-MII_ENTRY(advertise, MII_ADVERTISE);
-MII_ENTRY(lpa, MII_LPA);
-MII_ENTRY(expansion, MII_EXPANSION);
-
-static struct attribute *macb_mii_attrs[] = {
-	&dev_attr_bmcr.attr,
-	&dev_attr_bmsr.attr,
-	&dev_attr_physid1.attr,
-	&dev_attr_physid2.attr,
-	&dev_attr_advertise.attr,
-	&dev_attr_lpa.attr,
-	&dev_attr_expansion.attr,
-	NULL,
-};
-
-static struct attribute_group macb_mii_group = {
-	.name	= "mii",
-	.attrs	= macb_mii_attrs,
-};
-
-static void macb_unregister_sysfs(struct net_device *net)
-{
-	struct device *_dev = &net->dev;
+	if (!phydev)
+		return -ENODEV;
 
-	sysfs_remove_group(&_dev->kobj, &macb_mii_group);
+	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }
 
-static int macb_register_sysfs(struct net_device *net)
-{
-	struct device *_dev = &net->dev;
-	int ret;
-
-	ret = sysfs_create_group(&_dev->kobj, &macb_mii_group);
-	if (ret)
-		printk(KERN_WARNING
-		       "%s: sysfs mii attribute registration failed: %d\n",
-		       net->name, ret);
-	return ret;
-}
 static int __devinit macb_probe(struct platform_device *pdev)
 {
 	struct eth_platform_data *pdata;
 	struct resource *regs;
 	struct net_device *dev;
 	struct macb *bp;
+	struct phy_device *phydev;
 	unsigned long pclk_hz;
 	u32 config;
 	int err = -ENXIO;
@@ -1073,6 +1144,7 @@ static int __devinit macb_probe(struct platform_device *pdev)
 	dev->stop = macb_close;
 	dev->hard_start_xmit = macb_start_xmit;
 	dev->get_stats = macb_get_stats;
+	dev->set_multicast_list = macb_set_rx_mode;
 	dev->do_ioctl = macb_ioctl;
 	dev->poll = macb_poll;
 	dev->weight = 64;
@@ -1080,10 +1152,6 @@ static int __devinit macb_probe(struct platform_device *pdev)
 
 	dev->base_addr = regs->start;
 
-	INIT_DELAYED_WORK(&bp->periodic_task, macb_periodic_task);
-	mutex_init(&bp->mdio_mutex);
-	init_completion(&bp->mdio_complete);
-
 	/* Set MII management clock divider */
 	pclk_hz = clk_get_rate(bp->pclk);
 	if (pclk_hz <= 20000000)
@@ -1096,20 +1164,9 @@ static int __devinit macb_probe(struct platform_device *pdev)
 		config = MACB_BF(CLK, MACB_CLK_DIV64);
 	macb_writel(bp, NCFGR, config);
 
-	bp->mii.dev = dev;
-	bp->mii.mdio_read = macb_mdio_read;
-	bp->mii.mdio_write = macb_mdio_write;
-	bp->mii.phy_id_mask = 0x1f;
-	bp->mii.reg_num_mask = 0x1f;
-
 	macb_get_hwaddr(bp);
-	err = macb_phy_probe(bp);
-	if (err) {
-		dev_err(&pdev->dev, "Failed to detect PHY, aborting.\n");
-		goto err_out_free_irq;
-	}
-
 	pdata = pdev->dev.platform_data;
+
 	if (pdata && pdata->is_rmii)
 #if defined(CONFIG_ARCH_AT91)
 		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
@@ -1131,9 +1188,11 @@ static int __devinit macb_probe(struct platform_device *pdev)
 		goto err_out_free_irq;
 	}
 
-	platform_set_drvdata(pdev, dev);
+	if (macb_mii_init(bp) != 0) {
+		goto err_out_unregister_netdev;
+	}
 
-	macb_register_sysfs(dev);
+	platform_set_drvdata(pdev, dev);
 
 	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d "
 	       "(%02x:%02x:%02x:%02x:%02x:%02x)\n",
@@ -1141,8 +1200,15 @@ static int __devinit macb_probe(struct platform_device *pdev)
 	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
 
+	phydev = bp->phy_dev;
+	printk(KERN_INFO "%s: attached PHY driver [%s] "
+		"(mii_bus:phy_addr=%s, irq=%d)\n",
+		dev->name, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+
 	return 0;
 
+err_out_unregister_netdev:
+	unregister_netdev(dev);
 err_out_free_irq:
 	free_irq(dev->irq, dev);
 err_out_iounmap:
@@ -1153,7 +1219,9 @@ err_out_disable_clocks:
 	clk_put(bp->hclk);
 #endif
 	clk_disable(bp->pclk);
+#ifndef CONFIG_ARCH_AT91
 err_out_put_pclk:
+#endif
 	clk_put(bp->pclk);
 err_out_free_dev:
 	free_netdev(dev);
@@ -1171,7 +1239,8 @@ static int __devexit macb_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
-		macb_unregister_sysfs(dev);
+		mdiobus_unregister(&bp->mii_bus);
+		kfree(bp->mii_bus.irq);
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index b3bb218..4e3283e 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -383,11 +383,11 @@ struct macb {
 
 	unsigned int		rx_pending, tx_pending;
 
-	struct delayed_work	periodic_task;
-
-	struct mutex		mdio_mutex;
-	struct completion	mdio_complete;
-	struct mii_if_info	mii;
+	struct mii_bus		mii_bus;
+	struct phy_device	*phy_dev;
+	unsigned int 		link;
+	unsigned int 		speed;
+	unsigned int 		duplex;
 };
 
 #endif /* _MACB_H */
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e1732c1..deca653 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1060,7 +1060,6 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 	struct myri10ge_tx_buf *tx = &mgp->tx;
 	struct sk_buff *skb;
 	int idx, len;
-	int limit = 0;
 
 	while (tx->pkt_done != mcp_index) {
 		idx = tx->done & tx->mask;
@@ -1091,11 +1090,6 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 							      bus), len,
 					       PCI_DMA_TODEVICE);
 		}
-
-		/* limit potential for livelock by only handling
-		 * 2 full tx rings per call */
-		if (unlikely(++limit > 2 * tx->mask))
-			break;
 	}
 	/* start the queue if we've stopped it */
 	if (netif_queue_stopped(mgp->dev)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index fa29a40..7d54935 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -796,12 +796,14 @@ static void free_shared_mem(struct s2io_nic *nic)
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int lst_size, lst_per_page;
-	struct net_device *dev = nic->dev;
+	struct net_device *dev;
 	int page_num = 0;
 
 	if (!nic)
 		return;
 
+	dev = nic->dev;
+
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index bc62b01..943988e 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -305,6 +305,9 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x8086, 0x07d3),	// "blob" bootloader
 	.driver_info =	(unsigned long) &blob_info,
 }, {
+	USB_DEVICE (0x1286, 0x8001),    // "blob" bootloader
+	.driver_info =  (unsigned long) &blob_info,
+}, {
 	// Linux Ethernet/RNDIS gadget on pxa210/25x/26x, second config
 	// e.g. Gumstix, current OpenZaurus, ...
 	USB_DEVICE_VER (0x0525, 0xa4a2, 0x0203, 0x0203),
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 2d3a180..1c54908 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -52,6 +52,8 @@
 
 #include "airo.h"
 
+#define DRV_NAME "airo"
+
 #ifdef CONFIG_PCI
 static struct pci_device_id card_ids[] = {
 	{ 0x14b9, 1, PCI_ANY_ID, PCI_ANY_ID, },
@@ -71,7 +73,7 @@ static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state);
 static int airo_pci_resume(struct pci_dev *pdev);
 
 static struct pci_driver airo_driver = {
-	.name     = "airo",
+	.name     = DRV_NAME,
 	.id_table = card_ids,
 	.probe    = airo_pci_probe,
 	.remove   = __devexit_p(airo_pci_remove),
@@ -1092,7 +1094,7 @@ static int get_dec_u16( char *buffer, int *start, int limit );
 static void OUT4500( struct airo_info *, u16 register, u16 value );
 static unsigned short IN4500( struct airo_info *, u16 register );
 static u16 setup_card(struct airo_info*, u8 *mac, int lock);
-static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock );
+static int enable_MAC(struct airo_info *ai, int lock);
 static void disable_MAC(struct airo_info *ai, int lock);
 static void enable_interrupts(struct airo_info*);
 static void disable_interrupts(struct airo_info*);
@@ -1250,7 +1252,7 @@ static int flashputbuf(struct airo_info *ai);
 static int flashrestart(struct airo_info *ai,struct net_device *dev);
 
 #define airo_print(type, name, fmt, args...) \
-	{ printk(type "airo(%s): " fmt "\n", name, ##args); }
+	printk(type DRV_NAME "(%s): " fmt "\n", name, ##args)
 
 #define airo_print_info(name, fmt, args...) \
 	airo_print(KERN_INFO, name, fmt, ##args)
@@ -1926,28 +1928,54 @@ static int readStatsRid(struct airo_info*ai, StatsRid *sr, int rid, int lock) {
 	return rc;
 }
 
+static void try_auto_wep(struct airo_info *ai)
+{
+	if (auto_wep && !(ai->flags & FLAG_RADIO_DOWN)) {
+		ai->expires = RUN_AT(3*HZ);
+		wake_up_interruptible(&ai->thr_wait);
+	}
+}
+
 static int airo_open(struct net_device *dev) {
-	struct airo_info *info = dev->priv;
-	Resp rsp;
+	struct airo_info *ai = dev->priv;
+	int rc = 0;
 
-	if (test_bit(FLAG_FLASHING, &info->flags))
+	if (test_bit(FLAG_FLASHING, &ai->flags))
 		return -EIO;
 
 	/* Make sure the card is configured.
 	 * Wireless Extensions may postpone config changes until the card
 	 * is open (to pipeline changes and speed-up card setup). If
 	 * those changes are not yet commited, do it now - Jean II */
-	if (test_bit (FLAG_COMMIT, &info->flags)) {
-		disable_MAC(info, 1);
-		writeConfigRid(info, 1);
+	if (test_bit(FLAG_COMMIT, &ai->flags)) {
+		disable_MAC(ai, 1);
+		writeConfigRid(ai, 1);
 	}
 
-	if (info->wifidev != dev) {
+	if (ai->wifidev != dev) {
+		clear_bit(JOB_DIE, &ai->jobs);
+		ai->airo_thread_task = kthread_run(airo_thread, dev, dev->name);
+		if (IS_ERR(ai->airo_thread_task))
+			return (int)PTR_ERR(ai->airo_thread_task);
+
+		rc = request_irq(dev->irq, airo_interrupt, IRQF_SHARED,
+			dev->name, dev);
+		if (rc) {
+			airo_print_err(dev->name,
+				"register interrupt %d failed, rc %d",
+				dev->irq, rc);
+			set_bit(JOB_DIE, &ai->jobs);
+			kthread_stop(ai->airo_thread_task);
+			return rc;
+		}
+
 		/* Power on the MAC controller (which may have been disabled) */
-		clear_bit(FLAG_RADIO_DOWN, &info->flags);
-		enable_interrupts(info);
+		clear_bit(FLAG_RADIO_DOWN, &ai->flags);
+		enable_interrupts(ai);
+
+		try_auto_wep(ai);
 	}
-	enable_MAC(info, &rsp, 1);
+	enable_MAC(ai, 1);
 
 	netif_start_queue(dev);
 	return 0;
@@ -2338,14 +2366,13 @@ static int airo_set_mac_address(struct net_device *dev, void *p)
 {
 	struct airo_info *ai = dev->priv;
 	struct sockaddr *addr = p;
-	Resp rsp;
 
 	readConfigRid(ai, 1);
 	memcpy (ai->config.macAddr, addr->sa_data, dev->addr_len);
 	set_bit (FLAG_COMMIT, &ai->flags);
 	disable_MAC(ai, 1);
 	writeConfigRid (ai, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 	memcpy (ai->dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (ai->wifidev)
 		memcpy (ai->wifidev->dev_addr, addr->sa_data, dev->addr_len);
@@ -2392,6 +2419,11 @@ static int airo_close(struct net_device *dev) {
 		disable_MAC(ai, 1);
 #endif
 		disable_interrupts( ai );
+
+		free_irq(dev->irq, dev);
+
+		set_bit(JOB_DIE, &ai->jobs);
+		kthread_stop(ai->airo_thread_task);
 	}
 	return 0;
 }
@@ -2403,7 +2435,6 @@ void stop_airo_card( struct net_device *dev, int freeres )
 	set_bit(FLAG_RADIO_DOWN, &ai->flags);
 	disable_MAC(ai, 1);
 	disable_interrupts(ai);
-	free_irq( dev->irq, dev );
 	takedown_proc_entry( dev, ai );
 	if (test_bit(FLAG_REGISTERED, &ai->flags)) {
 		unregister_netdev( dev );
@@ -2414,9 +2445,6 @@ void stop_airo_card( struct net_device *dev, int freeres )
 		}
 		clear_bit(FLAG_REGISTERED, &ai->flags);
 	}
-	set_bit(JOB_DIE, &ai->jobs);
-	kthread_stop(ai->airo_thread_task);
-
 	/*
 	 * Clean out tx queue
 	 */
@@ -2554,8 +2582,7 @@ static int mpi_init_descriptors (struct airo_info *ai)
  * 2) Map PCI memory for issueing commands.
  * 3) Allocate memory (shared) to send and receive ethernet frames.
  */
-static int mpi_map_card(struct airo_info *ai, struct pci_dev *pci,
-		    const char *name)
+static int mpi_map_card(struct airo_info *ai, struct pci_dev *pci)
 {
 	unsigned long mem_start, mem_len, aux_start, aux_len;
 	int rc = -1;
@@ -2569,35 +2596,35 @@ static int mpi_map_card(struct airo_info *ai, struct pci_dev *pci,
 	aux_start = pci_resource_start(pci, 2);
 	aux_len = AUXMEMSIZE;
 
-	if (!request_mem_region(mem_start, mem_len, name)) {
-		airo_print_err(ai->dev->name, "Couldn't get region %x[%x] for %s",
-		       (int)mem_start, (int)mem_len, name);
+	if (!request_mem_region(mem_start, mem_len, DRV_NAME)) {
+		airo_print_err("", "Couldn't get region %x[%x]",
+			(int)mem_start, (int)mem_len);
 		goto out;
 	}
-	if (!request_mem_region(aux_start, aux_len, name)) {
-		airo_print_err(ai->dev->name, "Couldn't get region %x[%x] for %s",
-		       (int)aux_start, (int)aux_len, name);
+	if (!request_mem_region(aux_start, aux_len, DRV_NAME)) {
+		airo_print_err("", "Couldn't get region %x[%x]",
+			(int)aux_start, (int)aux_len);
 		goto free_region1;
 	}
 
 	ai->pcimem = ioremap(mem_start, mem_len);
 	if (!ai->pcimem) {
-		airo_print_err(ai->dev->name, "Couldn't map region %x[%x] for %s",
-		       (int)mem_start, (int)mem_len, name);
+		airo_print_err("", "Couldn't map region %x[%x]",
+			(int)mem_start, (int)mem_len);
 		goto free_region2;
 	}
 	ai->pciaux = ioremap(aux_start, aux_len);
 	if (!ai->pciaux) {
-		airo_print_err(ai->dev->name, "Couldn't map region %x[%x] for %s",
-		       (int)aux_start, (int)aux_len, name);
+		airo_print_err("", "Couldn't map region %x[%x]",
+			(int)aux_start, (int)aux_len);
 		goto free_memmap;
 	}
 
 	/* Reserve PKTSIZE for each fid and 2K for the Rids */
 	ai->shared = pci_alloc_consistent(pci, PCI_SHARED_LEN, &ai->shared_dma);
 	if (!ai->shared) {
-		airo_print_err(ai->dev->name, "Couldn't alloc_consistent %d",
-		       PCI_SHARED_LEN);
+		airo_print_err("", "Couldn't alloc_consistent %d",
+			PCI_SHARED_LEN);
 		goto free_auxmap;
 	}
 
@@ -2742,7 +2769,7 @@ static int airo_networks_allocate(struct airo_info *ai)
 	    kzalloc(AIRO_MAX_NETWORK_COUNT * sizeof(BSSListElement),
 		    GFP_KERNEL);
 	if (!ai->networks) {
-		airo_print_warn(ai->dev->name, "Out of memory allocating beacons");
+		airo_print_warn("", "Out of memory allocating beacons");
 		return -ENOMEM;
 	}
 
@@ -2770,7 +2797,6 @@ static int airo_test_wpa_capable(struct airo_info *ai)
 {
 	int status;
 	CapabilityRid cap_rid;
-	const char *name = ai->dev->name;
 
 	status = readCapabilityRid(ai, &cap_rid, 1);
 	if (status != SUCCESS) return 0;
@@ -2778,12 +2804,12 @@ static int airo_test_wpa_capable(struct airo_info *ai)
 	/* Only firmware versions 5.30.17 or better can do WPA */
 	if ((cap_rid.softVer > 0x530)
 	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 17))) {
-		airo_print_info(name, "WPA is supported.");
+		airo_print_info("", "WPA is supported.");
 		return 1;
 	}
 
 	/* No WPA support */
-	airo_print_info(name, "WPA unsupported (only firmware versions 5.30.17"
+	airo_print_info("", "WPA unsupported (only firmware versions 5.30.17"
 		" and greater support WPA.  Detected %s)", cap_rid.prodVer);
 	return 0;
 }
@@ -2797,23 +2823,19 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	int i, rc;
 
 	/* Create the network device object. */
-        dev = alloc_etherdev(sizeof(*ai));
-        if (!dev) {
+	dev = alloc_netdev(sizeof(*ai), "", ether_setup);
+	if (!dev) {
 		airo_print_err("", "Couldn't alloc_etherdev");
 		return NULL;
-        }
-	if (dev_alloc_name(dev, dev->name) < 0) {
-		airo_print_err("", "Couldn't get name!");
-		goto err_out_free;
 	}
 
 	ai = dev->priv;
 	ai->wifidev = NULL;
-	ai->flags = 0;
+	ai->flags = 1 << FLAG_RADIO_DOWN;
 	ai->jobs = 0;
 	ai->dev = dev;
 	if (pci && (pci->device == 0x5000 || pci->device == 0xa504)) {
-		airo_print_dbg(dev->name, "Found an MPI350 card");
+		airo_print_dbg("", "Found an MPI350 card");
 		set_bit(FLAG_MPI, &ai->flags);
 	}
 	spin_lock_init(&ai->aux_lock);
@@ -2821,14 +2843,11 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	ai->config.len = 0;
 	ai->pci = pci;
 	init_waitqueue_head (&ai->thr_wait);
-	ai->airo_thread_task = kthread_run(airo_thread, dev, dev->name);
-	if (IS_ERR(ai->airo_thread_task))
-		goto err_out_free;
 	ai->tfm = NULL;
 	add_airo_dev(ai);
 
 	if (airo_networks_allocate (ai))
-		goto err_out_thr;
+		goto err_out_free;
 	airo_networks_initialize (ai);
 
 	/* The Airo-specific entries in the device structure. */
@@ -2851,27 +2870,22 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	dev->base_addr = port;
 
 	SET_NETDEV_DEV(dev, dmdev);
+	SET_MODULE_OWNER(dev);
 
 	reset_card (dev, 1);
 	msleep(400);
 
-	rc = request_irq( dev->irq, airo_interrupt, IRQF_SHARED, dev->name, dev );
-	if (rc) {
-		airo_print_err(dev->name, "register interrupt %d failed, rc %d",
-				irq, rc);
-		goto err_out_nets;
-	}
 	if (!is_pcmcia) {
-		if (!request_region( dev->base_addr, 64, dev->name )) {
+		if (!request_region(dev->base_addr, 64, DRV_NAME)) {
 			rc = -EBUSY;
 			airo_print_err(dev->name, "Couldn't request region");
-			goto err_out_irq;
+			goto err_out_nets;
 		}
 	}
 
 	if (test_bit(FLAG_MPI,&ai->flags)) {
-		if (mpi_map_card(ai, pci, dev->name)) {
-			airo_print_err(dev->name, "Could not map memory");
+		if (mpi_map_card(ai, pci)) {
+			airo_print_err("", "Could not map memory");
 			goto err_out_res;
 		}
 	}
@@ -2899,6 +2913,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 		ai->bssListRidLen = sizeof(BSSListRid) - sizeof(BSSListRidExtra);
 	}
 
+	strcpy(dev->name, "eth%d");
 	rc = register_netdev(dev);
 	if (rc) {
 		airo_print_err(dev->name, "Couldn't register_netdev");
@@ -2921,8 +2936,6 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	if (setup_proc_entry(dev, dev->priv) < 0)
 		goto err_out_wifi;
 
-	netif_start_queue(dev);
-	SET_MODULE_OWNER(dev);
 	return dev;
 
 err_out_wifi:
@@ -2940,14 +2953,9 @@ err_out_map:
 err_out_res:
 	if (!is_pcmcia)
 	        release_region( dev->base_addr, 64 );
-err_out_irq:
-	free_irq(dev->irq, dev);
 err_out_nets:
 	airo_networks_free(ai);
-err_out_thr:
 	del_airo_dev(ai);
-	set_bit(JOB_DIE, &ai->jobs);
-	kthread_stop(ai->airo_thread_task);
 err_out_free:
 	free_netdev(dev);
 	return NULL;
@@ -3529,9 +3537,11 @@ static u16 IN4500( struct airo_info *ai, u16 reg ) {
 	return rc;
 }
 
-static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock ) {
+static int enable_MAC(struct airo_info *ai, int lock)
+{
 	int rc;
-        Cmd cmd;
+	Cmd cmd;
+	Resp rsp;
 
 	/* FLAG_RADIO_OFF : Radio disabled via /proc or Wireless Extensions
 	 * FLAG_RADIO_DOWN : Radio disabled via "ifconfig ethX down"
@@ -3547,7 +3557,7 @@ static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock ) {
 	if (!test_bit(FLAG_ENABLED, &ai->flags)) {
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd = MAC_ENABLE;
-		rc = issuecommand(ai, &cmd, rsp);
+		rc = issuecommand(ai, &cmd, &rsp);
 		if (rc == SUCCESS)
 			set_bit(FLAG_ENABLED, &ai->flags);
 	} else
@@ -3557,8 +3567,12 @@ static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock ) {
 	    up(&ai->sem);
 
 	if (rc)
-		airo_print_err(ai->dev->name, "%s: Cannot enable MAC, err=%d",
-			__FUNCTION__, rc);
+		airo_print_err(ai->dev->name, "Cannot enable MAC");
+	else if ((rsp.status & 0xFF00) != 0) {
+		airo_print_err(ai->dev->name, "Bad MAC enable reason=%x, "
+			"rid=%x, offset=%d", rsp.rsp0, rsp.rsp1, rsp.rsp2);
+		rc = ERROR;
+	}
 	return rc;
 }
 
@@ -3902,12 +3916,9 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 		if ( status != SUCCESS ) return ERROR;
 	}
 
-	status = enable_MAC(ai, &rsp, lock);
-	if ( status != SUCCESS || (rsp.status & 0xFF00) != 0) {
-		airo_print_err(ai->dev->name, "Bad MAC enable reason = %x, rid = %x,"
-			" offset = %d", rsp.rsp0, rsp.rsp1, rsp.rsp2 );
+	status = enable_MAC(ai, lock);
+	if (status != SUCCESS)
 		return ERROR;
-	}
 
 	/* Grab the initial wep key, we gotta save it for auto_wep */
 	rc = readWepKeyRid(ai, &wkr, 1, lock);
@@ -3919,10 +3930,7 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 		rc = readWepKeyRid(ai, &wkr, 0, lock);
 	} while(lastindex != wkr.kindex);
 
-	if (auto_wep) {
-		ai->expires = RUN_AT(3*HZ);
-		wake_up_interruptible(&ai->thr_wait);
-	}
+	try_auto_wep(ai);
 
 	return SUCCESS;
 }
@@ -4004,7 +4012,7 @@ static int bap_setup(struct airo_info *ai, u16 rid, u16 offset, int whichbap )
 		}
 		if ( !(max_tries--) ) {
 			airo_print_err(ai->dev->name,
-				"airo: BAP setup error too many retries\n");
+				"BAP setup error too many retries\n");
 			return ERROR;
 		}
 		// -- PC4500 missed it, try again
@@ -5152,7 +5160,6 @@ static void proc_SSID_on_close( struct inode *inode, struct file *file ) {
 	struct net_device *dev = dp->data;
 	struct airo_info *ai = dev->priv;
 	SsidRid SSID_rid;
-	Resp rsp;
 	int i;
 	int offset = 0;
 
@@ -5177,7 +5184,7 @@ static void proc_SSID_on_close( struct inode *inode, struct file *file ) {
 		SSID_rid.len = sizeof(SSID_rid);
 	disable_MAC(ai, 1);
 	writeSsidRid(ai, &SSID_rid, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 }
 
 static inline u8 hexVal(char c) {
@@ -5193,7 +5200,6 @@ static void proc_APList_on_close( struct inode *inode, struct file *file ) {
 	struct net_device *dev = dp->data;
 	struct airo_info *ai = dev->priv;
 	APListRid APList_rid;
-	Resp rsp;
 	int i;
 
 	if ( !data->writelen ) return;
@@ -5218,18 +5224,17 @@ static void proc_APList_on_close( struct inode *inode, struct file *file ) {
 	}
 	disable_MAC(ai, 1);
 	writeAPListRid(ai, &APList_rid, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 }
 
 /* This function wraps PC4500_writerid with a MAC disable */
 static int do_writerid( struct airo_info *ai, u16 rid, const void *rid_data,
 			int len, int dummy ) {
 	int rc;
-	Resp rsp;
 
 	disable_MAC(ai, 1);
 	rc = PC4500_writerid(ai, rid, rid_data, len, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 	return rc;
 }
 
@@ -5260,7 +5265,6 @@ static int set_wep_key(struct airo_info *ai, u16 index,
 		       const char *key, u16 keylen, int perm, int lock ) {
 	static const unsigned char macaddr[ETH_ALEN] = { 0x01, 0, 0, 0, 0, 0 };
 	WepKeyRid wkr;
-	Resp rsp;
 
 	memset(&wkr, 0, sizeof(wkr));
 	if (keylen == 0) {
@@ -5280,7 +5284,7 @@ static int set_wep_key(struct airo_info *ai, u16 index,
 
 	if (perm) disable_MAC(ai, lock);
 	writeWepKeyRid(ai, &wkr, perm, lock);
-	if (perm) enable_MAC(ai, &rsp, lock);
+	if (perm) enable_MAC(ai, lock);
 	return 0;
 }
 
@@ -5548,7 +5552,6 @@ static int proc_close( struct inode *inode, struct file *file )
    changed. */
 static void timer_func( struct net_device *dev ) {
 	struct airo_info *apriv = dev->priv;
-	Resp rsp;
 
 /* We don't have a link so try changing the authtype */
 	readConfigRid(apriv, 0);
@@ -5575,7 +5578,7 @@ static void timer_func( struct net_device *dev ) {
 	}
 	set_bit (FLAG_COMMIT, &apriv->flags);
 	writeConfigRid(apriv, 0);
-	enable_MAC(apriv, &rsp, 0);
+	enable_MAC(apriv, 0);
 	up(&apriv->sem);
 
 /* Schedule check to see if the change worked */
@@ -5597,8 +5600,10 @@ static int __devinit airo_pci_probe(struct pci_dev *pdev,
 			dev = _init_airo_card(pdev->irq, pdev->resource[0].start, 0, pdev, &pdev->dev);
 	else
 			dev = _init_airo_card(pdev->irq, pdev->resource[2].start, 0, pdev, &pdev->dev);
-	if (!dev)
+	if (!dev) {
+		pci_disable_device(pdev);
 		return -ENODEV;
+	}
 
 	pci_set_drvdata(pdev, dev);
 	return 0;
@@ -5610,6 +5615,8 @@ static void __devexit airo_pci_remove(struct pci_dev *pdev)
 
 	airo_print_info(dev->name, "Unregistering...");
 	stop_airo_card(dev, 1);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
 }
 
 static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -5646,7 +5653,6 @@ static int airo_pci_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct airo_info *ai = dev->priv;
-	Resp rsp;
 	pci_power_t prev_state = pdev->current_state;
 
 	pci_set_power_state(pdev, PCI_D0);
@@ -5679,7 +5685,7 @@ static int airo_pci_resume(struct pci_dev *pdev)
 		ai->APList = NULL;
 	}
 	writeConfigRid(ai, 0);
-	enable_MAC(ai, &rsp, 0);
+	enable_MAC(ai, 0);
 	ai->power = PMSG_ON;
 	netif_device_attach(dev);
 	netif_wake_queue(dev);
@@ -5903,7 +5909,6 @@ static int airo_set_essid(struct net_device *dev,
 			  char *extra)
 {
 	struct airo_info *local = dev->priv;
-	Resp rsp;
 	SsidRid SSID_rid;		/* SSIDs */
 
 	/* Reload the list of current SSID */
@@ -5935,7 +5940,7 @@ static int airo_set_essid(struct net_device *dev,
 	/* Write it to the card */
 	disable_MAC(local, 1);
 	writeSsidRid(local, &SSID_rid, 1);
-	enable_MAC(local, &rsp, 1);
+	enable_MAC(local, 1);
 
 	return 0;
 }
@@ -6000,7 +6005,7 @@ static int airo_set_wap(struct net_device *dev,
 		memcpy(APList_rid.ap[0], awrq->sa_data, ETH_ALEN);
 		disable_MAC(local, 1);
 		writeAPListRid(local, &APList_rid, 1);
-		enable_MAC(local, &rsp, 1);
+		enable_MAC(local, 1);
 	}
 	return 0;
 }
@@ -7454,7 +7459,6 @@ static int airo_config_commit(struct net_device *dev,
 			      char *extra)			/* NULL */
 {
 	struct airo_info *local = dev->priv;
-	Resp rsp;
 
 	if (!test_bit (FLAG_COMMIT, &local->flags))
 		return 0;
@@ -7479,7 +7483,7 @@ static int airo_config_commit(struct net_device *dev,
 	if (down_interruptible(&local->sem))
 		return -ERESTARTSYS;
 	writeConfigRid(local, 0);
-	enable_MAC(local, &rsp, 0);
+	enable_MAC(local, 0);
 	if (test_bit (FLAG_RESET, &local->flags))
 		airo_set_promisc(local);
 	else
@@ -7746,7 +7750,6 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
 	unsigned char *iobuf;
 	int len;
 	struct airo_info *ai = dev->priv;
-	Resp rsp;
 
 	if (test_bit(FLAG_FLASHING, &ai->flags))
 		return -EIO;
@@ -7758,7 +7761,7 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
 		if (test_bit(FLAG_COMMIT, &ai->flags)) {
 			disable_MAC (ai, 1);
 			writeConfigRid (ai, 1);
-			enable_MAC (ai, &rsp, 1);
+			enable_MAC(ai, 1);
 		}
 		break;
 	case AIROGSLIST:    ridcode = RID_SSID;         break;
@@ -7815,7 +7818,6 @@ static int writerids(struct net_device *dev, aironet_ioctl *comp) {
 	struct airo_info *ai = dev->priv;
 	int  ridcode;
         int  enabled;
-	Resp      rsp;
 	static int (* writer)(struct airo_info *, u16 rid, const void *, int, int);
 	unsigned char *iobuf;
 
@@ -7849,7 +7851,7 @@ static int writerids(struct net_device *dev, aironet_ioctl *comp) {
 		 * same with MAC off
 		 */
 	case AIROPMACON:
-		if (enable_MAC(ai, &rsp, 1) != 0)
+		if (enable_MAC(ai, 1) != 0)
 			return -EIO;
 		return 0;
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index d51daf8..072ede7 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1768,7 +1768,8 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 
 		if (priv->stop_rf_kill) {
 			priv->stop_rf_kill = 0;
-			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   round_jiffies(HZ));
 		}
 
 		deferred = 1;
@@ -2098,7 +2099,7 @@ static void isr_indicate_rf_kill(struct ipw2100_priv *priv, u32 status)
 	/* Make sure the RF Kill check timer is running */
 	priv->stop_rf_kill = 0;
 	cancel_delayed_work(&priv->rf_kill);
-	queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+	queue_delayed_work(priv->workqueue, &priv->rf_kill, round_jiffies(HZ));
 }
 
 static void isr_scan_complete(struct ipw2100_priv *priv, u32 status)
@@ -4233,7 +4234,8 @@ static int ipw_radio_kill_sw(struct ipw2100_priv *priv, int disable_radio)
 			/* Make sure the RF_KILL check timer is running */
 			priv->stop_rf_kill = 0;
 			cancel_delayed_work(&priv->rf_kill);
-			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   round_jiffies(HZ));
 		} else
 			schedule_reset(priv);
 	}
@@ -5969,7 +5971,8 @@ static void ipw2100_rf_kill(struct work_struct *work)
 	if (rf_kill_active(priv)) {
 		IPW_DEBUG_RF_KILL("RF Kill active, rescheduling GPIO check\n");
 		if (!priv->stop_rf_kill)
-			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   round_jiffies(HZ));
 		goto exit_unlock;
 	}
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 7cb2052..aa32a97 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1751,7 +1751,7 @@ static int ipw_radio_kill_sw(struct ipw_priv *priv, int disable_radio)
 			/* Make sure the RF_KILL check timer is running */
 			cancel_delayed_work(&priv->rf_kill);
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   2 * HZ);
+					   round_jiffies(2 * HZ));
 		} else
 			queue_work(priv->workqueue, &priv->up);
 	}
@@ -4690,7 +4690,8 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 			else if (priv->config & CFG_BACKGROUND_SCAN
 				 && priv->status & STATUS_ASSOCIATED)
 				queue_delayed_work(priv->workqueue,
-						   &priv->request_scan, HZ);
+						   &priv->request_scan,
+						   round_jiffies(HZ));
 
 			/* Send an empty event to user space.
 			 * We don't send the received data on the event because
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 13f6528..4a8f5dc 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -240,7 +240,7 @@ static int wlan_cmd_802_11_enable_rsn(wlan_private * priv,
 		if (*enable)
 			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
 		else
-			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
+			penableRSN->enable = cpu_to_le16(cmd_disable_rsn);
 	}
 
 	lbs_deb_leave(LBS_DEB_CMD);
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 88d9d2d..769c86f 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -439,7 +439,6 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 	ret = 0;
 
 done:
-	skb->protocol = __constant_htons(0x0019);	/* ETH_P_80211_RAW */
 	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", ret);
 	return ret;
 }
diff --git a/drivers/net/wireless/libertas/version.h b/drivers/net/wireless/libertas/version.h
deleted file mode 100644
index 8b13789..0000000
--- a/drivers/net/wireless/libertas/version.h
+++ /dev/null
@@ -1 +0,0 @@
-
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index f42b796..2fcc3bf 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1719,9 +1719,6 @@ static int wlan_set_encodeext(struct net_device *dev,
 			pkey->type = KEY_TYPE_ID_TKIP;
 		} else if (alg == IW_ENCODE_ALG_CCMP) {
 			pkey->type = KEY_TYPE_ID_AES;
-		} else {
-			ret = -EINVAL;
-			goto out;
 		}
 
 		/* If WPA isn't enabled yet, do that now */
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 283be4a..585f599 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1853,7 +1853,6 @@ prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
-	struct list_head *ptr;
 	struct sockaddr *addr = (struct sockaddr *) extra;
 
 	if (addr->sa_family != ARPHRD_ETHER)
@@ -1861,11 +1860,9 @@ prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 
 	if (down_interruptible(&acl->sem))
 		return -ERESTARTSYS;
-	for (ptr = acl->mac_list.next; ptr != &acl->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, _list);
-
+	list_for_each_entry(entry, &acl->mac_list, _list) {
 		if (memcmp(entry->addr, addr->sa_data, ETH_ALEN) == 0) {
-			list_del(ptr);
+			list_del(&entry->_list);
 			acl->size--;
 			kfree(entry);
 			up(&acl->sem);
@@ -1883,7 +1880,6 @@ prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
-	struct list_head *ptr;
 	struct sockaddr *dst = (struct sockaddr *) extra;
 
 	dwrq->length = 0;
@@ -1891,9 +1887,7 @@ prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
 	if (down_interruptible(&acl->sem))
 		return -ERESTARTSYS;
 
-	for (ptr = acl->mac_list.next; ptr != &acl->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, _list);
-
+	list_for_each_entry(entry, &acl->mac_list, _list) {
 		memcpy(dst->sa_data, entry->addr, ETH_ALEN);
 		dst->sa_family = ARPHRD_ETHER;
 		dwrq->length++;
@@ -1960,7 +1954,6 @@ prism54_get_policy(struct net_device *ndev, struct iw_request_info *info,
 static int
 prism54_mac_accept(struct islpci_acl *acl, char *mac)
 {
-	struct list_head *ptr;
 	struct mac_entry *entry;
 	int res = 0;
 
@@ -1972,8 +1965,7 @@ prism54_mac_accept(struct islpci_acl *acl, char *mac)
 		return 1;
 	}
 
-	for (ptr = acl->mac_list.next; ptr != &acl->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, _list);
+	list_for_each_entry(entry, &acl->mac_list, _list) {
 		if (memcmp(entry->addr, mac, ETH_ALEN) == 0) {
 			res = 1;
 			break;
@@ -2216,11 +2208,9 @@ prism54_wpa_bss_ie_init(islpci_private *priv)
 void
 prism54_wpa_bss_ie_clean(islpci_private *priv)
 {
-	struct list_head *ptr, *n;
+	struct islpci_bss_wpa_ie *bss, *n;
 
-	list_for_each_safe(ptr, n, &priv->bss_wpa_list) {
-		struct islpci_bss_wpa_ie *bss;
-		bss = list_entry(ptr, struct islpci_bss_wpa_ie, list);
+	list_for_each_entry_safe(bss, n, &priv->bss_wpa_list, list) {
 		kfree(bss);
 	}
 }
diff --git a/drivers/net/wireless/rtl8187_rtl8225.c b/drivers/net/wireless/rtl8187_rtl8225.c
index e25a09f..efc4120 100644
--- a/drivers/net/wireless/rtl8187_rtl8225.c
+++ b/drivers/net/wireless/rtl8187_rtl8225.c
@@ -67,7 +67,7 @@ static void rtl8225_write_bitbang(struct ieee80211_hw *dev, u8 addr, u16 data)
 	msleep(2);
 }
 
-static void rtl8225_write_8051(struct ieee80211_hw *dev, u8 addr, u16 data)
+static void rtl8225_write_8051(struct ieee80211_hw *dev, u8 addr, __le16 data)
 {
 	struct rtl8187_priv *priv = dev->priv;
 	u16 reg80, reg82, reg84;
@@ -106,7 +106,7 @@ void rtl8225_write(struct ieee80211_hw *dev, u8 addr, u16 data)
 	struct rtl8187_priv *priv = dev->priv;
 
 	if (priv->asic_rev)
-		rtl8225_write_8051(dev, addr, data);
+		rtl8225_write_8051(dev, addr, cpu_to_le16(data));
 	else
 		rtl8225_write_bitbang(dev, addr, data);
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 5b624bf..c39f198 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -49,8 +49,9 @@ void zd_chip_clear(struct zd_chip *chip)
 	ZD_MEMCLEAR(chip, sizeof(*chip));
 }
 
-static int scnprint_mac_oui(const u8 *addr, char *buffer, size_t size)
+static int scnprint_mac_oui(struct zd_chip *chip, char *buffer, size_t size)
 {
+	u8 *addr = zd_usb_to_netdev(&chip->usb)->dev_addr;
 	return scnprintf(buffer, size, "%02x-%02x-%02x",
 		         addr[0], addr[1], addr[2]);
 }
@@ -61,10 +62,10 @@ static int scnprint_id(struct zd_chip *chip, char *buffer, size_t size)
 	int i = 0;
 
 	i = scnprintf(buffer, size, "zd1211%s chip ",
-		      chip->is_zd1211b ? "b" : "");
+		      zd_chip_is_zd1211b(chip) ? "b" : "");
 	i += zd_usb_scnprint_id(&chip->usb, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
-	i += scnprint_mac_oui(chip->e2p_mac, buffer+i, size-i);
+	i += scnprint_mac_oui(chip, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
 	i += zd_rf_scnprint_id(&chip->rf, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " pa%1x %c%c%c%c%c", chip->pa_type,
@@ -366,64 +367,9 @@ error:
 	return r;
 }
 
-static int _read_mac_addr(struct zd_chip *chip, u8 *mac_addr,
-	                  const zd_addr_t *addr)
-{
-	int r;
-	u32 parts[2];
-
-	r = zd_ioread32v_locked(chip, parts, (const zd_addr_t *)addr, 2);
-	if (r) {
-		dev_dbg_f(zd_chip_dev(chip),
-			"error: couldn't read e2p macs. Error number %d\n", r);
-		return r;
-	}
-
-	mac_addr[0] = parts[0];
-	mac_addr[1] = parts[0] >>  8;
-	mac_addr[2] = parts[0] >> 16;
-	mac_addr[3] = parts[0] >> 24;
-	mac_addr[4] = parts[1];
-	mac_addr[5] = parts[1] >>  8;
-
-	return 0;
-}
-
-static int read_e2p_mac_addr(struct zd_chip *chip)
-{
-	static const zd_addr_t addr[2] = { E2P_MAC_ADDR_P1, E2P_MAC_ADDR_P2 };
-
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	return _read_mac_addr(chip, chip->e2p_mac, (const zd_addr_t *)addr);
-}
-
 /* MAC address: if custom mac addresses are to to be used CR_MAC_ADDR_P1 and
  *              CR_MAC_ADDR_P2 must be overwritten
  */
-void zd_get_e2p_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	mutex_lock(&chip->mutex);
-	memcpy(mac_addr, chip->e2p_mac, ETH_ALEN);
-	mutex_unlock(&chip->mutex);
-}
-
-static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
-	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
-}
-
-int zd_read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	int r;
-
-	dev_dbg_f(zd_chip_dev(chip), "\n");
-	mutex_lock(&chip->mutex);
-	r = read_mac_addr(chip, mac_addr);
-	mutex_unlock(&chip->mutex);
-	return r;
-}
-
 int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr)
 {
 	int r;
@@ -444,12 +390,6 @@ int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr)
 
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32a_locked(chip, reqs, ARRAY_SIZE(reqs));
-#ifdef DEBUG
-	{
-		u8 tmp[ETH_ALEN];
-		read_mac_addr(chip, tmp);
-	}
-#endif /* DEBUG */
 	mutex_unlock(&chip->mutex);
 	return r;
 }
@@ -809,7 +749,7 @@ out:
 
 static int hw_reset_phy(struct zd_chip *chip)
 {
-	return chip->is_zd1211b ? zd1211b_hw_reset_phy(chip) :
+	return zd_chip_is_zd1211b(chip) ? zd1211b_hw_reset_phy(chip) :
 		                  zd1211_hw_reset_phy(chip);
 }
 
@@ -874,7 +814,7 @@ static int hw_init_hmac(struct zd_chip *chip)
 	if (r)
 		return r;
 
-	return chip->is_zd1211b ?
+	return zd_chip_is_zd1211b(chip) ?
 		zd1211b_hw_init_hmac(chip) : zd1211_hw_init_hmac(chip);
 }
 
@@ -1136,8 +1076,15 @@ static int read_fw_regs_offset(struct zd_chip *chip)
 	return 0;
 }
 
+/* Read mac address using pre-firmware interface */
+int zd_chip_read_mac_addr_fw(struct zd_chip *chip, u8 *addr)
+{
+	dev_dbg_f(zd_chip_dev(chip), "\n");
+	return zd_usb_read_fw(&chip->usb, E2P_MAC_ADDR_P1, addr,
+		ETH_ALEN);
+}
 
-int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
+int zd_chip_init_hw(struct zd_chip *chip)
 {
 	int r;
 	u8 rf_type;
@@ -1145,7 +1092,6 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 	dev_dbg_f(zd_chip_dev(chip), "\n");
 
 	mutex_lock(&chip->mutex);
-	chip->is_zd1211b = (device_type == DEVICE_ZD1211B) != 0;
 
 #ifdef DEBUG
 	r = test_init(chip);
@@ -1201,10 +1147,6 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 		goto out;
 #endif /* DEBUG */
 
-	r = read_e2p_mac_addr(chip);
-	if (r)
-		goto out;
-
 	r = read_cal_int_tables(chip);
 	if (r)
 		goto out;
@@ -1259,7 +1201,7 @@ static int update_channel_integration_and_calibration(struct zd_chip *chip,
 	r = update_pwr_int(chip, channel);
 	if (r)
 		return r;
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		static const struct zd_ioreq16 ioreqs[] = {
 			{ CR69, 0x28 },
 			{},
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 79d0288..f469857 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -704,7 +704,6 @@ struct zd_chip {
 	struct mutex mutex;
 	/* Base address of FW_REG_ registers */
 	zd_addr_t fw_regs_base;
-	u8 e2p_mac[ETH_ALEN];
 	/* EepSetPoint in the vendor driver */
 	u8 pwr_cal_values[E2P_CHANNEL_COUNT];
 	/* integration values in the vendor driver */
@@ -715,7 +714,7 @@ struct zd_chip {
 	unsigned int pa_type:4,
 		patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
 		new_phy_layout:1, al2230s_bit:1,
-		is_zd1211b:1, supports_tx_led:1;
+		supports_tx_led:1;
 };
 
 static inline struct zd_chip *zd_usb_to_chip(struct zd_usb *usb)
@@ -734,9 +733,15 @@ void zd_chip_init(struct zd_chip *chip,
 	         struct net_device *netdev,
 	         struct usb_interface *intf);
 void zd_chip_clear(struct zd_chip *chip);
-int zd_chip_init_hw(struct zd_chip *chip, u8 device_type);
+int zd_chip_read_mac_addr_fw(struct zd_chip *chip, u8 *addr);
+int zd_chip_init_hw(struct zd_chip *chip);
 int zd_chip_reset(struct zd_chip *chip);
 
+static inline int zd_chip_is_zd1211b(struct zd_chip *chip)
+{
+	return chip->usb.is_zd1211b;
+}
+
 static inline int zd_ioread16v_locked(struct zd_chip *chip, u16 *values,
 	                              const zd_addr_t *addresses,
 				      unsigned int count)
@@ -825,8 +830,6 @@ static inline u8 _zd_chip_get_channel(struct zd_chip *chip)
 }
 u8  zd_chip_get_channel(struct zd_chip *chip);
 int zd_read_regdomain(struct zd_chip *chip, u8 *regdomain);
-void zd_get_e2p_mac_addr(struct zd_chip *chip, u8 *mac_addr);
-int zd_read_mac_addr(struct zd_chip *chip, u8 *mac_addr);
 int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr);
 int zd_chip_switch_radio_on(struct zd_chip *chip);
 int zd_chip_switch_radio_off(struct zd_chip *chip);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 6753d24..f6c487a 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -86,38 +86,46 @@ out:
 	return r;
 }
 
-int zd_mac_init_hw(struct zd_mac *mac, u8 device_type)
+int zd_mac_preinit_hw(struct zd_mac *mac)
 {
 	int r;
-	struct zd_chip *chip = &mac->chip;
 	u8 addr[ETH_ALEN];
+
+	r = zd_chip_read_mac_addr_fw(&mac->chip, addr);
+	if (r)
+		return r;
+
+	memcpy(mac->netdev->dev_addr, addr, ETH_ALEN);
+	return 0;
+}
+
+int zd_mac_init_hw(struct zd_mac *mac)
+{
+	int r;
+	struct zd_chip *chip = &mac->chip;
 	u8 default_regdomain;
 
 	r = zd_chip_enable_int(chip);
 	if (r)
 		goto out;
-	r = zd_chip_init_hw(chip, device_type);
+	r = zd_chip_init_hw(chip);
 	if (r)
 		goto disable_int;
 
-	zd_get_e2p_mac_addr(chip, addr);
-	r = zd_write_mac_addr(chip, addr);
-	if (r)
-		goto disable_int;
 	ZD_ASSERT(!irqs_disabled());
-	spin_lock_irq(&mac->lock);
-	memcpy(mac->netdev->dev_addr, addr, ETH_ALEN);
-	spin_unlock_irq(&mac->lock);
 
 	r = zd_read_regdomain(chip, &default_regdomain);
 	if (r)
 		goto disable_int;
 	if (!zd_regdomain_supported(default_regdomain)) {
-		dev_dbg_f(zd_mac_dev(mac),
-			  "Regulatory Domain %#04x is not supported.\n",
-		          default_regdomain);
-		r = -EINVAL;
-		goto disable_int;
+		/* The vendor driver overrides the regulatory domain and
+		 * allowed channel registers and unconditionally restricts
+		 * available channels to 1-11 everywhere. Match their
+		 * questionable behaviour only for regdomains which we don't
+		 * recognise. */
+		dev_warn(zd_mac_dev(mac),  "Unrecognised regulatory domain: "
+			"%#04x. Defaulting to FCC.\n", default_regdomain);
+		default_regdomain = ZD_REGDOMAIN_FCC;
 	}
 	spin_lock_irq(&mac->lock);
 	mac->regdomain = mac->default_regdomain = default_regdomain;
@@ -164,14 +172,25 @@ int zd_mac_open(struct net_device *netdev)
 {
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct zd_chip *chip = &mac->chip;
+	struct zd_usb *usb = &chip->usb;
 	int r;
 
+	if (!usb->initialized) {
+		r = zd_usb_init_hw(usb);
+		if (r)
+			goto out;
+	}
+
 	tasklet_enable(&mac->rx_tasklet);
 
 	r = zd_chip_enable_int(chip);
 	if (r < 0)
 		goto out;
 
+	r = zd_write_mac_addr(chip, netdev->dev_addr);
+	if (r)
+		goto disable_int;
+
 	r = zd_chip_set_basic_rates(chip, CR_RATES_80211B | CR_RATES_80211G);
 	if (r < 0)
 		goto disable_int;
@@ -251,9 +270,11 @@ int zd_mac_set_mac_address(struct net_device *netdev, void *p)
 	dev_dbg_f(zd_mac_dev(mac),
 		  "Setting MAC to " MAC_FMT "\n", MAC_ARG(addr->sa_data));
 
-	r = zd_write_mac_addr(chip, addr->sa_data);
-	if (r)
-		return r;
+	if (netdev->flags & IFF_UP) {
+		r = zd_write_mac_addr(chip, addr->sa_data);
+		if (r)
+			return r;
+	}
 
 	spin_lock_irqsave(&mac->lock, flags);
 	memcpy(netdev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -855,7 +876,7 @@ static int fill_ctrlset(struct zd_mac *mac,
 	/* ZD1211B: Computing the length difference this way, gives us
 	 * flexibility to compute the packet length.
 	 */
-	cs->packet_length = cpu_to_le16(mac->chip.is_zd1211b ?
+	cs->packet_length = cpu_to_le16(zd_chip_is_zd1211b(&mac->chip) ?
 			packet_length - frag_len : packet_length);
 
 	/*
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index faf4c78..9f9344e 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -189,7 +189,8 @@ int zd_mac_init(struct zd_mac *mac,
 		struct usb_interface *intf);
 void zd_mac_clear(struct zd_mac *mac);
 
-int zd_mac_init_hw(struct zd_mac *mac, u8 device_type);
+int zd_mac_preinit_hw(struct zd_mac *mac);
+int zd_mac_init_hw(struct zd_mac *mac);
 
 int zd_mac_open(struct net_device *netdev);
 int zd_mac_stop(struct net_device *netdev);
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.c b/drivers/net/wireless/zd1211rw/zd_rf.c
index 7407409..abe5d38 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -34,7 +34,7 @@ static const char * const rfs[] = {
 	[AL2210_RF]	= "AL2210_RF",
 	[MAXIM_NEW_RF]	= "MAXIM_NEW_RF",
 	[UW2453_RF]	= "UW2453_RF",
-	[UNKNOWN_A_RF]	= "UNKNOWN_A_RF",
+	[AL2230S_RF]	= "AL2230S_RF",
 	[RALINK_RF]	= "RALINK_RF",
 	[INTERSIL_RF]	= "INTERSIL_RF",
 	[RF2959_RF]	= "RF2959_RF",
@@ -77,6 +77,7 @@ int zd_rf_init_hw(struct zd_rf *rf, u8 type)
 		r = zd_rf_init_rf2959(rf);
 		break;
 	case AL2230_RF:
+	case AL2230S_RF:
 		r = zd_rf_init_al2230(rf);
 		break;
 	case AL7230B_RF:
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.h b/drivers/net/wireless/zd1211rw/zd_rf.h
index c6dfd82..30502f2 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -26,7 +26,7 @@
 #define AL2210_RF			0x7
 #define MAXIM_NEW_RF			0x8
 #define UW2453_RF			0x9
-#define UNKNOWN_A_RF			0xa
+#define AL2230S_RF			0xa
 #define RALINK_RF			0xb
 #define INTERSIL_RF			0xc
 #define RF2959_RF			0xd
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
index e7a4ecf..006774d 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -21,6 +21,8 @@
 #include "zd_usb.h"
 #include "zd_chip.h"
 
+#define IS_AL2230S(chip) ((chip)->al2230s_bit || (chip)->rf.type == AL2230S_RF)
+
 static const u32 zd1211_al2230_table[][3] = {
 	RF_CHANNEL( 1) = { 0x03f790, 0x033331, 0x00000d, },
 	RF_CHANNEL( 2) = { 0x03f790, 0x0b3331, 0x00000d, },
@@ -176,7 +178,7 @@ static int zd1211_al2230_init_hw(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit) {
+	if (IS_AL2230S(chip)) {
 		r = zd_iowrite16a_locked(chip, ioreqs_init_al2230s,
 			ARRAY_SIZE(ioreqs_init_al2230s));
 		if (r)
@@ -188,7 +190,7 @@ static int zd1211_al2230_init_hw(struct zd_rf *rf)
 		return r;
 
 	/* improve band edge for AL2230S */
-	if (chip->al2230s_bit)
+	if (IS_AL2230S(chip))
 		r = zd_rfwrite_locked(chip, 0x000824, RF_RV_BITS);
 	else
 		r = zd_rfwrite_locked(chip, 0x0005a4, RF_RV_BITS);
@@ -314,7 +316,7 @@ static int zd1211b_al2230_init_hw(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit) {
+	if (IS_AL2230S(chip)) {
 		r = zd_iowrite16a_locked(chip, ioreqs_init_al2230s,
 			ARRAY_SIZE(ioreqs_init_al2230s));
 		if (r)
@@ -328,7 +330,7 @@ static int zd1211b_al2230_init_hw(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit)
+	if (IS_AL2230S(chip))
 		r = zd_rfwrite_locked(chip, 0x241000, RF_RV_BITS);
 	else
 		r = zd_rfwrite_locked(chip, 0x25a000, RF_RV_BITS);
@@ -422,7 +424,7 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
 	rf->switch_radio_off = al2230_switch_radio_off;
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		rf->init_hw = zd1211b_al2230_init_hw;
 		rf->set_channel = zd1211b_al2230_set_channel;
 		rf->switch_radio_on = zd1211b_al2230_switch_radio_on;
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
index f4e8b6a..73d0bb2 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
@@ -473,7 +473,7 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		rf->init_hw = zd1211b_al7230b_init_hw;
 		rf->switch_radio_on = zd1211b_al7230b_switch_radio_on;
 		rf->set_channel = zd1211b_al7230b_set_channel;
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c b/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
index 2d736bd..cc70d40 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
@@ -265,7 +265,7 @@ int zd_rf_init_rf2959(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		dev_err(zd_chip_dev(chip),
 		       "RF2959 is currently not supported for ZD1211B"
 		       " devices\n");
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
index 414e40d..857dcf3 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
@@ -486,7 +486,7 @@ static int uw2453_switch_radio_on(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->is_zd1211b)
+	if (zd_chip_is_zd1211b(chip))
 		ioreqs[1].value = 0x7f;
 
 	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 740a219..a1a5474 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -71,6 +71,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3413), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0411, 0x00da), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
@@ -195,26 +196,27 @@ static u16 get_word(const void *data, u16 offset)
 	return le16_to_cpu(p[offset]);
 }
 
-static char *get_fw_name(char *buffer, size_t size, u8 device_type,
+static char *get_fw_name(struct zd_usb *usb, char *buffer, size_t size,
 	               const char* postfix)
 {
 	scnprintf(buffer, size, "%s%s",
-		device_type == DEVICE_ZD1211B ?
+		usb->is_zd1211b ?
 			FW_ZD1211B_PREFIX : FW_ZD1211_PREFIX,
 		postfix);
 	return buffer;
 }
 
-static int handle_version_mismatch(struct usb_device *udev, u8 device_type,
+static int handle_version_mismatch(struct zd_usb *usb,
 	const struct firmware *ub_fw)
 {
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	const struct firmware *ur_fw = NULL;
 	int offset;
 	int r = 0;
 	char fw_name[128];
 
 	r = request_fw_file(&ur_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type, "ur"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "ur"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -237,11 +239,12 @@ error:
 	return r;
 }
 
-static int upload_firmware(struct usb_device *udev, u8 device_type)
+static int upload_firmware(struct zd_usb *usb)
 {
 	int r;
 	u16 fw_bcdDevice;
 	u16 bcdDevice;
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	const struct firmware *ub_fw = NULL;
 	const struct firmware *uph_fw = NULL;
 	char fw_name[128];
@@ -249,7 +252,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 	bcdDevice = get_bcdDevice(udev);
 
 	r = request_fw_file(&ub_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type,  "ub"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "ub"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -264,7 +267,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 			dev_warn(&udev->dev, "device has old bootcode, please "
 				"report success or failure\n");
 
-		r = handle_version_mismatch(udev, device_type, ub_fw);
+		r = handle_version_mismatch(usb, ub_fw);
 		if (r)
 			goto error;
 	} else {
@@ -275,7 +278,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 
 
 	r = request_fw_file(&uph_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type, "uphr"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "uphr"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -294,6 +297,30 @@ error:
 	return r;
 }
 
+/* Read data from device address space using "firmware interface" which does
+ * not require firmware to be loaded. */
+int zd_usb_read_fw(struct zd_usb *usb, zd_addr_t addr, u8 *data, u16 len)
+{
+	int r;
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
+
+	r = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
+		USB_REQ_FIRMWARE_READ_DATA, USB_DIR_IN | 0x40, addr, 0,
+		data, len, 5000);
+	if (r < 0) {
+		dev_err(&udev->dev,
+			"read over firmware interface failed: %d\n", r);
+		return r;
+	} else if (r != len) {
+		dev_err(&udev->dev,
+			"incomplete read over firmware interface: %d/%d\n",
+			r, len);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 #define urb_dev(urb) (&(urb)->dev->dev)
 
 static inline void handle_regs_int(struct urb *urb)
@@ -920,9 +947,42 @@ static int eject_installer(struct usb_interface *intf)
 	return 0;
 }
 
+int zd_usb_init_hw(struct zd_usb *usb)
+{
+	int r;
+	struct zd_mac *mac = zd_usb_to_mac(usb);
+
+	dev_dbg_f(zd_usb_dev(usb), "\n");
+
+	r = upload_firmware(usb);
+	if (r) {
+		dev_err(zd_usb_dev(usb),
+		       "couldn't load firmware. Error number %d\n", r);
+		return r;
+	}
+
+	r = usb_reset_configuration(zd_usb_to_usbdev(usb));
+	if (r) {
+		dev_dbg_f(zd_usb_dev(usb),
+			"couldn't reset configuration. Error number %d\n", r);
+		return r;
+	}
+
+	r = zd_mac_init_hw(mac);
+	if (r) {
+		dev_dbg_f(zd_usb_dev(usb),
+		         "couldn't initialize mac. Error number %d\n", r);
+		return r;
+	}
+
+	usb->initialized = 1;
+	return 0;
+}
+
 static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	int r;
+	struct zd_usb *usb;
 	struct usb_device *udev = interface_to_usbdev(intf);
 	struct net_device *netdev = NULL;
 
@@ -950,26 +1010,10 @@ static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 		goto error;
 	}
 
-	r = upload_firmware(udev, id->driver_info);
-	if (r) {
-		dev_err(&intf->dev,
-		       "couldn't load firmware. Error number %d\n", r);
-		goto error;
-	}
+	usb = &zd_netdev_mac(netdev)->chip.usb;
+	usb->is_zd1211b = (id->driver_info == DEVICE_ZD1211B) != 0;
 
-	r = usb_reset_configuration(udev);
-	if (r) {
-		dev_dbg_f(&intf->dev,
-			"couldn't reset configuration. Error number %d\n", r);
-		goto error;
-	}
-
-	/* At this point the interrupt endpoint is not generally enabled. We
-	 * save the USB bandwidth until the network device is opened. But
-	 * notify that the initialization of the MAC will require the
-	 * interrupts to be temporary enabled.
-	 */
-	r = zd_mac_init_hw(zd_netdev_mac(netdev), id->driver_info);
+	r = zd_mac_preinit_hw(zd_netdev_mac(netdev));
 	if (r) {
 		dev_dbg_f(&intf->dev,
 		         "couldn't initialize mac. Error number %d\n", r);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index 506ea6a..961a7a1 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -188,6 +188,7 @@ struct zd_usb {
 	struct zd_usb_rx rx;
 	struct zd_usb_tx tx;
 	struct usb_interface *intf;
+	u8 is_zd1211b:1, initialized:1;
 };
 
 #define zd_usb_dev(usb) (&usb->intf->dev)
@@ -236,6 +237,8 @@ int zd_usb_iowrite16v(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 
 int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
 
+int zd_usb_read_fw(struct zd_usb *usb, zd_addr_t addr, u8 *data, u16 len);
+
 extern struct workqueue_struct *zd_workqueue;
 
 #endif /* _ZD_USB_H */
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index b34eb82..ec18bae 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -211,6 +211,10 @@ struct qeth_perf_stats {
 	/* initial values when measuring starts */
 	unsigned long initial_rx_packets;
 	unsigned long initial_tx_packets;
+	/* inbound scatter gather data */
+	unsigned int sg_skbs_rx;
+	unsigned int sg_frags_rx;
+	unsigned int sg_alloc_page_rx;
 };
 
 /* Routing stuff */
@@ -341,6 +345,9 @@ qeth_is_ipa_enabled(struct qeth_ipa_info *ipa, enum qeth_ipa_funcs func)
 
 #define QETH_IP_HEADER_SIZE 40
 
+/* large receive scatter gather copy break */
+#define QETH_RX_SG_CB (PAGE_SIZE >> 1)
+
 struct qeth_hdr_layer3 {
 	__u8  id;
 	__u8  flags;
@@ -771,6 +778,7 @@ struct qeth_card_options {
 	int layer2;
 	enum qeth_large_send_types large_send;
 	int performance_stats;
+	int rx_sg_cb;
 };
 
 /*
@@ -828,6 +836,7 @@ struct qeth_card {
 	int (*orig_hard_header)(struct sk_buff *,struct net_device *,
 				unsigned short,void *,void *,unsigned);
 	struct qeth_osn_info osn_info;
+	atomic_t force_alloc_skb;
 };
 
 struct qeth_card_list_struct {
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 86b0c44..57f6943 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -1054,6 +1054,7 @@ qeth_set_intial_options(struct qeth_card *card)
 	else
 		card->options.layer2 = 0;
 	card->options.performance_stats = 0;
+	card->options.rx_sg_cb = QETH_RX_SG_CB;
 }
 
 /**
@@ -1934,6 +1935,7 @@ qeth_send_control_data(struct qeth_card *card, int len,
 			atomic_inc(&reply->received);
 			wake_up(&reply->wait_q);
 		}
+		cpu_relax();
 	};
 	rc = reply->rc;
 	qeth_put_reply(reply);
@@ -2258,6 +2260,89 @@ qeth_get_skb(unsigned int length, struct qeth_hdr *hdr)
 	return skb;
 }
 
+static inline int
+qeth_create_skb_frag(struct qdio_buffer_element *element,
+		     struct sk_buff **pskb,
+		     int offset, int *pfrag, int data_len)
+{
+	struct page *page = virt_to_page(element->addr);
+	if (*pfrag == 0) {
+		/* the upper protocol layers assume that there is data in the
+		 * skb itself. Copy a small amount (64 bytes) to make them
+		 * happy. */
+		*pskb = dev_alloc_skb(64 + QETH_FAKE_LL_LEN_ETH);
+		if (!(*pskb))
+			return -ENOMEM;
+		skb_reserve(*pskb, QETH_FAKE_LL_LEN_ETH);
+		if (data_len <= 64) {
+			memcpy(skb_put(*pskb, data_len), element->addr + offset,
+				data_len);
+		} else {
+			get_page(page);
+			memcpy(skb_put(*pskb, 64), element->addr + offset, 64);
+			skb_fill_page_desc(*pskb, *pfrag, page, offset + 64,
+				data_len - 64);
+			(*pskb)->data_len += data_len - 64;
+			(*pskb)->len	  += data_len - 64;
+			(*pskb)->truesize += data_len - 64;
+		}
+	} else {
+		get_page(page);
+		skb_fill_page_desc(*pskb, *pfrag, page, offset, data_len);
+		(*pskb)->data_len += data_len;
+		(*pskb)->len	  += data_len;
+		(*pskb)->truesize += data_len;
+	}
+	(*pfrag)++;
+	return 0;
+}
+
+static inline struct qeth_buffer_pool_entry *
+qeth_find_free_buffer_pool_entry(struct qeth_card *card)
+{
+	struct list_head *plh;
+	struct qeth_buffer_pool_entry *entry;
+	int i, free;
+	struct page *page;
+
+	if (list_empty(&card->qdio.in_buf_pool.entry_list))
+		return NULL;
+
+	list_for_each(plh, &card->qdio.in_buf_pool.entry_list) {
+		entry = list_entry(plh, struct qeth_buffer_pool_entry, list);
+		free = 1;
+		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+			if (page_count(virt_to_page(entry->elements[i])) > 1) {
+				free = 0;
+				break;
+			}
+		}
+		if (free) {
+			list_del_init(&entry->list);
+			return entry;
+		}
+	}
+
+	/* no free buffer in pool so take first one and swap pages */
+	entry = list_entry(card->qdio.in_buf_pool.entry_list.next,
+			struct qeth_buffer_pool_entry, list);
+	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+		if (page_count(virt_to_page(entry->elements[i])) > 1) {
+			page = alloc_page(GFP_ATOMIC|GFP_DMA);
+			if (!page) {
+				return NULL;
+			} else {
+				free_page((unsigned long)entry->elements[i]);
+				entry->elements[i] = page_address(page);
+				if (card->options.performance_stats)
+					card->perf_stats.sg_alloc_page_rx++;
+			}
+		}
+	}
+	list_del_init(&entry->list);
+	return entry;
+}
+
 static struct sk_buff *
 qeth_get_next_skb(struct qeth_card *card, struct qdio_buffer *buffer,
 		  struct qdio_buffer_element **__element, int *__offset,
@@ -2269,6 +2354,8 @@ qeth_get_next_skb(struct qeth_card *card, struct qdio_buffer *buffer,
 	int skb_len;
 	void *data_ptr;
 	int data_len;
+	int use_rx_sg = 0;
+	int frag = 0;
 
 	QETH_DBF_TEXT(trace,6,"nextskb");
 	/* qeth_hdr must not cross element boundaries */
@@ -2293,23 +2380,43 @@ qeth_get_next_skb(struct qeth_card *card, struct qdio_buffer *buffer,
 
 	if (!skb_len)
 		return NULL;
-	if (card->options.fake_ll){
-		if(card->dev->type == ARPHRD_IEEE802_TR){
-			if (!(skb = qeth_get_skb(skb_len+QETH_FAKE_LL_LEN_TR, *hdr)))
-				goto no_mem;
-			skb_reserve(skb,QETH_FAKE_LL_LEN_TR);
+	if ((skb_len >= card->options.rx_sg_cb) &&
+	    (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
+	    (!atomic_read(&card->force_alloc_skb))) {
+		use_rx_sg = 1;
+	} else {
+		if (card->options.fake_ll) {
+			if (card->dev->type == ARPHRD_IEEE802_TR) {
+				if (!(skb = qeth_get_skb(skb_len +
+						QETH_FAKE_LL_LEN_TR, *hdr)))
+					goto no_mem;
+				skb_reserve(skb, QETH_FAKE_LL_LEN_TR);
+			} else {
+				if (!(skb = qeth_get_skb(skb_len +
+						QETH_FAKE_LL_LEN_ETH, *hdr)))
+					goto no_mem;
+				skb_reserve(skb, QETH_FAKE_LL_LEN_ETH);
+			}
 		} else {
-			if (!(skb = qeth_get_skb(skb_len+QETH_FAKE_LL_LEN_ETH, *hdr)))
+			skb = qeth_get_skb(skb_len, *hdr);
+			if (!skb)
 				goto no_mem;
-			skb_reserve(skb,QETH_FAKE_LL_LEN_ETH);
 		}
-	} else if (!(skb = qeth_get_skb(skb_len, *hdr)))
-		goto no_mem;
+	}
+
 	data_ptr = element->addr + offset;
 	while (skb_len) {
 		data_len = min(skb_len, (int)(element->length - offset));
-		if (data_len)
-			memcpy(skb_put(skb, data_len), data_ptr, data_len);
+		if (data_len) {
+			if (use_rx_sg) {
+				if (qeth_create_skb_frag(element, &skb, offset,
+				    &frag, data_len))
+					goto no_mem;
+			} else {
+				memcpy(skb_put(skb, data_len), data_ptr,
+					data_len);
+			}
+		}
 		skb_len -= data_len;
 		if (skb_len){
 			if (qeth_is_last_sbale(element)){
@@ -2331,6 +2438,10 @@ qeth_get_next_skb(struct qeth_card *card, struct qdio_buffer *buffer,
 	}
 	*__element = element;
 	*__offset = offset;
+	if (use_rx_sg && card->options.performance_stats) {
+		card->perf_stats.sg_skbs_rx++;
+		card->perf_stats.sg_frags_rx += skb_shinfo(skb)->nr_frags;
+	}
 	return skb;
 no_mem:
 	if (net_ratelimit()){
@@ -2608,28 +2719,15 @@ qeth_process_inbound_buffer(struct qeth_card *card,
 	}
 }
 
-static struct qeth_buffer_pool_entry *
-qeth_get_buffer_pool_entry(struct qeth_card *card)
-{
-	struct qeth_buffer_pool_entry *entry;
-
-	QETH_DBF_TEXT(trace, 6, "gtbfplen");
-	if (!list_empty(&card->qdio.in_buf_pool.entry_list)) {
-		entry = list_entry(card->qdio.in_buf_pool.entry_list.next,
-				struct qeth_buffer_pool_entry, list);
-		list_del_init(&entry->list);
-		return entry;
-	}
-	return NULL;
-}
-
-static void
+static int
 qeth_init_input_buffer(struct qeth_card *card, struct qeth_qdio_buffer *buf)
 {
 	struct qeth_buffer_pool_entry *pool_entry;
 	int i;
- 
-	pool_entry = qeth_get_buffer_pool_entry(card);
+
+	pool_entry = qeth_find_free_buffer_pool_entry(card);
+	if (!pool_entry)
+		return 1;
 	/*
 	 * since the buffer is accessed only from the input_tasklet
 	 * there shouldn't be a need to synchronize; also, since we use
@@ -2648,6 +2746,7 @@ qeth_init_input_buffer(struct qeth_card *card, struct qeth_qdio_buffer *buf)
 			buf->buffer->element[i].flags = 0;
 	}
 	buf->state = QETH_QDIO_BUF_EMPTY;
+	return 0;
 }
 
 static void
@@ -2682,6 +2781,7 @@ qeth_queue_input_buffer(struct qeth_card *card, int index)
 	int count;
 	int i;
 	int rc;
+	int newcount = 0;
 
 	QETH_DBF_TEXT(trace,6,"queinbuf");
 	count = (index < queue->next_buf_to_init)?
@@ -2692,9 +2792,27 @@ qeth_queue_input_buffer(struct qeth_card *card, int index)
 	/* only requeue at a certain threshold to avoid SIGAs */
 	if (count >= QETH_IN_BUF_REQUEUE_THRESHOLD(card)){
 		for (i = queue->next_buf_to_init;
-		     i < queue->next_buf_to_init + count; ++i)
-			qeth_init_input_buffer(card,
-				&queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q]);
+		     i < queue->next_buf_to_init + count; ++i) {
+			if (qeth_init_input_buffer(card,
+				&queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q])) {
+				break;
+			} else {
+				newcount++;
+			}
+		}
+
+		if (newcount < count) {
+			/* we are in memory shortage so we switch back to
+			   traditional skb allocation and drop packages */
+			if (atomic_cmpxchg(&card->force_alloc_skb, 0, 1))
+				printk(KERN_WARNING
+					"qeth: switch to alloc skb\n");
+			count = newcount;
+		} else {
+			if (atomic_cmpxchg(&card->force_alloc_skb, 1, 0))
+				printk(KERN_WARNING "qeth: switch to sg\n");
+		}
+
 		/*
 		 * according to old code it should be avoided to requeue all
 		 * 128 buffers in order to benefit from PCI avoidance.
@@ -6494,6 +6612,7 @@ qeth_hardsetup_card(struct qeth_card *card)
 
 	QETH_DBF_TEXT(setup, 2, "hrdsetup");
 
+	atomic_set(&card->force_alloc_skb, 0);
 retry:
 	if (retries < 3){
 		PRINT_WARN("Retrying to do IDX activates.\n");
diff --git a/drivers/s390/net/qeth_proc.c b/drivers/s390/net/qeth_proc.c
index 89d56c8..f1ff165 100644
--- a/drivers/s390/net/qeth_proc.c
+++ b/drivers/s390/net/qeth_proc.c
@@ -212,6 +212,12 @@ qeth_perf_procfile_seq_show(struct seq_file *s, void *it)
 		      "  Skb fragments sent in SG mode          : %u\n\n",
 		      card->perf_stats.sg_skbs_sent,
 		      card->perf_stats.sg_frags_sent);
+	seq_printf(s, "  Skbs received in SG mode               : %u\n"
+		      "  Skb fragments received in SG mode      : %u\n"
+		      "  Page allocations for rx SG mode        : %u\n\n",
+		      card->perf_stats.sg_skbs_rx,
+		      card->perf_stats.sg_frags_rx,
+		      card->perf_stats.sg_alloc_page_rx);
 	seq_printf(s, "  large_send tx (in Kbytes)              : %u\n"
 		      "  large_send count                       : %u\n\n",
 		      card->perf_stats.large_send_bytes >> 10,
diff --git a/include/asm-arm/arch-at91/board.h b/include/asm-arm/arch-at91/board.h
index 0ce6ee9..d96b10f 100644
--- a/include/asm-arm/arch-at91/board.h
+++ b/include/asm-arm/arch-at91/board.h
@@ -64,6 +64,7 @@ extern void __init at91_add_device_mmc(short mmc_id, struct at91_mmc_data *data)
 
  /* Ethernet (EMAC & MACB) */
 struct at91_eth_data {
+	u32		phy_mask;
 	u8		phy_irq_pin;	/* PHY IRQ */
 	u8		is_rmii;	/* using RMII interface? */
 };
diff --git a/include/asm-avr32/arch-at32ap/board.h b/include/asm-avr32/arch-at32ap/board.h
index 9fd2e32..9744804 100644
--- a/include/asm-avr32/arch-at32ap/board.h
+++ b/include/asm-avr32/arch-at32ap/board.h
@@ -21,6 +21,7 @@ void at32_map_usart(unsigned int hw_id, unsigned int line);
 struct platform_device *at32_add_device_usart(unsigned int id);
 
 struct eth_platform_data {
+	u32	phy_mask;
 	u8	is_rmii;
 };
 struct platform_device *
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index cc8110b..afb6c66 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -271,8 +271,11 @@ ieee80211softmac_assoc_work(struct work_struct *work)
 			 */
 			dprintk(KERN_INFO PFX "Associate: Scanning for networks first.\n");
 			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
-			if (ieee80211softmac_start_scan(mac))
+			if (ieee80211softmac_start_scan(mac)) {
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
+				mac->associnfo.associating = 0;
+				mac->associnfo.associated = 0;
+			}
 			goto out;
 		} else {
 			mac->associnfo.associating = 0;
