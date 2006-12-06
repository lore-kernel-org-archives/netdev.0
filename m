From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/7] chelsio: spaces, tabs and friends
Date: Wed, 6 Dec 2006 01:16:40 +0100
Message-ID: <20061206001640.GC2377@electric-eye.fr.zoreil.com>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58026 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758614AbWLFARF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:17:05 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/common.h    |    2 +-
 drivers/net/chelsio/cpl5_cmd.h  |   18 +++---
 drivers/net/chelsio/cxgb2.c     |   64 +++++++++++-----------
 drivers/net/chelsio/elmer0.h    |   40 +++++++-------
 drivers/net/chelsio/espi.c      |   41 +++++++-------
 drivers/net/chelsio/fpga_defs.h |    6 +-
 drivers/net/chelsio/gmac.h      |   11 +++-
 drivers/net/chelsio/ixf1010.c   |    4 +-
 drivers/net/chelsio/mv88e1xxx.c |   17 +++----
 drivers/net/chelsio/pm3393.c    |    8 ++--
 drivers/net/chelsio/sge.c       |  115 ++++++++++++++++++++-------------------
 drivers/net/chelsio/subr.c      |   83 ++++++++++++++--------------
 drivers/net/chelsio/tp.c        |   62 ++++++++++-----------
 drivers/net/chelsio/vsc7326.c   |   57 ++++++++++----------
 drivers/net/chelsio/vsc8244.c   |   38 ++++++-------
 15 files changed, 283 insertions(+), 283 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index b265941..7000c52 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -324,7 +324,7 @@ struct board_info {
 	unsigned char           mdio_phybaseaddr;
 	struct gmac            *gmac;
 	struct gphy            *gphy;
-	struct mdio_ops	       *mdio_ops;
+	struct mdio_ops        *mdio_ops;
 	const char             *desc;
 };
 
diff --git a/drivers/net/chelsio/cpl5_cmd.h b/drivers/net/chelsio/cpl5_cmd.h
index 35f565b..e36d45b 100644
--- a/drivers/net/chelsio/cpl5_cmd.h
+++ b/drivers/net/chelsio/cpl5_cmd.h
@@ -103,7 +103,7 @@ enum CPL_opcode {
 	CPL_MIGRATE_C2T_RPL   = 0xDD,
 	CPL_ERROR             = 0xD7,
 
-    /* internal: driver -> TOM */
+	/* internal: driver -> TOM */
 	CPL_MSS_CHANGE        = 0xE1
 };
 
@@ -159,8 +159,8 @@ enum {                // TX_PKT_LSO ethe
 };
 
 union opcode_tid {
-    u32 opcode_tid;
-    u8 opcode;
+	u32 opcode_tid;
+	u8 opcode;
 };
 
 #define S_OPCODE 24
@@ -234,7 +234,7 @@ struct cpl_pass_accept_req {
 	u32 local_ip;
 	u32 peer_ip;
 	u32 tos_tid;
-    struct tcp_options tcp_options;
+	struct tcp_options tcp_options;
 	u8  dst_mac[6];
 	u16 vlan_tag;
 	u8  src_mac[6];
@@ -250,12 +250,12 @@ struct cpl_pass_accept_rpl {
 	u32 peer_ip;
 	u32 opt0h;
 	union {
-	u32 opt0l;
-	struct {
-	    u8 rsvd[3];
-	    u8 status;
+		u32 opt0l;
+		struct {
+		    u8 rsvd[3];
+		    u8 status;
+		};
 	};
-    };
 };
 
 struct cpl_act_open_req {
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 53bec67..cb639d4 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -69,14 +69,14 @@ static inline void cancel_mac_stats_upda
 	cancel_delayed_work(&ap->stats_update_task);
 }
 
-#define MAX_CMDQ_ENTRIES 16384
-#define MAX_CMDQ1_ENTRIES 1024
-#define MAX_RX_BUFFERS 16384
-#define MAX_RX_JUMBO_BUFFERS 16384
+#define MAX_CMDQ_ENTRIES	16384
+#define MAX_CMDQ1_ENTRIES	1024
+#define MAX_RX_BUFFERS		16384
+#define MAX_RX_JUMBO_BUFFERS	16384
 #define MAX_TX_BUFFERS_HIGH	16384U
 #define MAX_TX_BUFFERS_LOW	1536U
 #define MAX_TX_BUFFERS		1460U
-#define MIN_FL_ENTRIES 32
+#define MIN_FL_ENTRIES		32
 
 #define DFLT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK | \
 			 NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP |\
@@ -143,7 +143,7 @@ static void link_report(struct port_info
 			case SPEED_100:   s = "100Mbps"; break;
 		}
 
-	printk(KERN_INFO "%s: link up, %s, %s-duplex\n",
+		printk(KERN_INFO "%s: link up, %s, %s-duplex\n",
 		       p->dev->name, s,
 		       p->link_config.duplex == DUPLEX_FULL ? "full" : "half");
 	}
@@ -234,7 +234,7 @@ static int cxgb_up(struct adapter *adapt
 
 	t1_sge_start(adapter->sge);
 	t1_interrupts_enable(adapter);
- out_err:
+out_err:
 	return err;
 }
 
@@ -750,7 +750,7 @@ static int set_sge_param(struct net_devi
 		return -EINVAL;
 
 	if (adapter->flags & FULL_INIT_DONE)
-	return -EBUSY;
+		return -EBUSY;
 
 	adapter->params.sge.freelQ_size[!jumbo_fl] = e->rx_pending;
 	adapter->params.sge.freelQ_size[jumbo_fl] = e->rx_jumbo_pending;
@@ -776,7 +776,7 @@ static int set_coalesce(struct net_devic
 	} else {
 		adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
 	}
- 	adapter->params.sge.coalesce_enable = c->use_adaptive_rx_coalesce;
+	adapter->params.sge.coalesce_enable = c->use_adaptive_rx_coalesce;
 	adapter->params.sge.sample_interval_usecs = c->rate_sample_interval;
 	t1_sge_set_coalesce_params(adapter->sge, &adapter->params.sge);
 	return 0;
@@ -794,9 +794,9 @@ static int get_coalesce(struct net_devic
 
 static int get_eeprom_len(struct net_device *dev)
 {
- 	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->priv;
 
- 	return t1_is_asic(adapter) ? EEPROM_SIZE : 0;
+	return t1_is_asic(adapter) ? EEPROM_SIZE : 0;
 }
 
 #define EEPROM_MAGIC(ap) \
@@ -860,7 +860,7 @@ static int t1_ioctl(struct net_device *d
 		u32 val;
 
 		if (!phy->mdio_read)
-	    return -EOPNOTSUPP;
+			return -EOPNOTSUPP;
 		phy->mdio_read(adapter, data->phy_id, 0, data->reg_num & 0x1f,
 			       &val);
 		data->val_out = val;
@@ -872,7 +872,7 @@ static int t1_ioctl(struct net_device *d
 		if (!capable(CAP_NET_ADMIN))
 		    return -EPERM;
 		if (!phy->mdio_write)
-	    return -EOPNOTSUPP;
+			return -EOPNOTSUPP;
 		phy->mdio_write(adapter, data->phy_id, 0, data->reg_num & 0x1f,
 			        data->val_in);
 		break;
@@ -891,9 +891,9 @@ static int t1_change_mtu(struct net_devi
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 
 	if (!mac->ops->set_mtu)
-	return -EOPNOTSUPP;
+		return -EOPNOTSUPP;
 	if (new_mtu < 68)
-	return -EINVAL;
+		return -EINVAL;
 	if ((ret = mac->ops->set_mtu(mac, new_mtu)))
 		return ret;
 	dev->mtu = new_mtu;
@@ -1218,9 +1218,9 @@ static int __devinit init_one(struct pci
 
 	return 0;
 
- out_release_adapter_res:
+out_release_adapter_res:
 	t1_free_sw_modules(adapter);
- out_free_dev:
+out_free_dev:
 	if (adapter) {
 		if (adapter->regs)
 			iounmap(adapter->regs);
@@ -1229,7 +1229,7 @@ static int __devinit init_one(struct pci
 				free_netdev(adapter->port[i].dev);
 	}
 	pci_release_regions(pdev);
- out_disable_pdev:
+out_disable_pdev:
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	return err;
@@ -1280,20 +1280,20 @@ static int t1_clock(struct adapter *adap
 	int M_MEM_VAL;
 
 	enum {
-		M_CORE_BITS = 9,
-		T_CORE_VAL = 0,
-		T_CORE_BITS = 2,
-		N_CORE_VAL = 0,
-		N_CORE_BITS = 2,
-		M_MEM_BITS = 9,
-		T_MEM_VAL = 0,
-		T_MEM_BITS = 2,
-		N_MEM_VAL = 0,
-		N_MEM_BITS = 2,
-		NP_LOAD = 1 << 17,
-		S_LOAD_MEM = 1 << 5,
-		S_LOAD_CORE = 1 << 6,
-		S_CLOCK = 1 << 3
+		M_CORE_BITS	= 9,
+		T_CORE_VAL	= 0,
+		T_CORE_BITS	= 2,
+		N_CORE_VAL	= 0,
+		N_CORE_BITS	= 2,
+		M_MEM_BITS	= 9,
+		T_MEM_VAL	= 0,
+		T_MEM_BITS	= 2,
+		N_MEM_VAL	= 0,
+		N_MEM_BITS	= 2,
+		NP_LOAD		= 1 << 17,
+		S_LOAD_MEM	= 1 << 5,
+		S_LOAD_CORE	= 1 << 6,
+		S_CLOCK		= 1 << 3
 	};
 
 	if (!t1_is_T1B(adapter))
diff --git a/drivers/net/chelsio/elmer0.h b/drivers/net/chelsio/elmer0.h
index 9ebecaa..eef655c 100644
--- a/drivers/net/chelsio/elmer0.h
+++ b/drivers/net/chelsio/elmer0.h
@@ -46,14 +46,14 @@ enum {
 };
 
 /* ELMER0 registers */
-#define A_ELMER0_VERSION 0x100000
-#define A_ELMER0_PHY_CFG 0x100004
-#define A_ELMER0_INT_ENABLE 0x100008
-#define A_ELMER0_INT_CAUSE 0x10000c
-#define A_ELMER0_GPI_CFG 0x100010
-#define A_ELMER0_GPI_STAT 0x100014
-#define A_ELMER0_GPO 0x100018
-#define A_ELMER0_PORT0_MI1_CFG 0x400000
+#define A_ELMER0_VERSION	0x100000
+#define A_ELMER0_PHY_CFG	0x100004
+#define A_ELMER0_INT_ENABLE	0x100008
+#define A_ELMER0_INT_CAUSE	0x10000c
+#define A_ELMER0_GPI_CFG	0x100010
+#define A_ELMER0_GPI_STAT	0x100014
+#define A_ELMER0_GPO		0x100018
+#define A_ELMER0_PORT0_MI1_CFG	0x400000
 
 #define S_MI1_MDI_ENABLE    0
 #define V_MI1_MDI_ENABLE(x) ((x) << S_MI1_MDI_ENABLE)
@@ -111,18 +111,18 @@ enum {
 #define V_MI1_OP_BUSY(x) ((x) << S_MI1_OP_BUSY)
 #define F_MI1_OP_BUSY    V_MI1_OP_BUSY(1U)
 
-#define A_ELMER0_PORT1_MI1_CFG 0x500000
-#define A_ELMER0_PORT1_MI1_ADDR 0x500004
-#define A_ELMER0_PORT1_MI1_DATA 0x500008
-#define A_ELMER0_PORT1_MI1_OP 0x50000c
-#define A_ELMER0_PORT2_MI1_CFG 0x600000
-#define A_ELMER0_PORT2_MI1_ADDR 0x600004
-#define A_ELMER0_PORT2_MI1_DATA 0x600008
-#define A_ELMER0_PORT2_MI1_OP 0x60000c
-#define A_ELMER0_PORT3_MI1_CFG 0x700000
-#define A_ELMER0_PORT3_MI1_ADDR 0x700004
-#define A_ELMER0_PORT3_MI1_DATA 0x700008
-#define A_ELMER0_PORT3_MI1_OP 0x70000c
+#define A_ELMER0_PORT1_MI1_CFG	0x500000
+#define A_ELMER0_PORT1_MI1_ADDR	0x500004
+#define A_ELMER0_PORT1_MI1_DATA	0x500008
+#define A_ELMER0_PORT1_MI1_OP	0x50000c
+#define A_ELMER0_PORT2_MI1_CFG	0x600000
+#define A_ELMER0_PORT2_MI1_ADDR	0x600004
+#define A_ELMER0_PORT2_MI1_DATA	0x600008
+#define A_ELMER0_PORT2_MI1_OP	0x60000c
+#define A_ELMER0_PORT3_MI1_CFG	0x700000
+#define A_ELMER0_PORT3_MI1_ADDR	0x700004
+#define A_ELMER0_PORT3_MI1_DATA	0x700008
+#define A_ELMER0_PORT3_MI1_OP	0x70000c
 
 /* Simple bit definition for GPI and GP0 registers. */
 #define     ELMER0_GP_BIT0              0x0001
diff --git a/drivers/net/chelsio/espi.c b/drivers/net/chelsio/espi.c
index 44d2603..d7c5406 100644
--- a/drivers/net/chelsio/espi.c
+++ b/drivers/net/chelsio/espi.c
@@ -202,9 +202,9 @@ static void espi_setup_for_pm3393(adapte
 
 static void espi_setup_for_vsc7321(adapter_t *adapter)
 {
-        writel(0x1f4, adapter->regs + A_ESPI_SCH_TOKEN0);
-        writel(0x1f401f4, adapter->regs + A_ESPI_SCH_TOKEN1);
-        writel(0x1f4, adapter->regs + A_ESPI_SCH_TOKEN2);
+	writel(0x1f4, adapter->regs + A_ESPI_SCH_TOKEN0);
+	writel(0x1f401f4, adapter->regs + A_ESPI_SCH_TOKEN1);
+	writel(0x1f4, adapter->regs + A_ESPI_SCH_TOKEN2);
 	writel(0xa00, adapter->regs + A_ESPI_RX_FIFO_ALMOST_FULL_WATERMARK);
 	writel(0x1ff, adapter->regs + A_ESPI_RX_FIFO_ALMOST_EMPTY_WATERMARK);
 	writel(1, adapter->regs + A_ESPI_CALENDAR_LENGTH);
@@ -247,10 +247,10 @@ int t1_espi_init(struct peespi *espi, in
 		writel(V_OUT_OF_SYNC_COUNT(4) |
 		       V_DIP2_PARITY_ERR_THRES(3) |
 		       V_DIP4_THRES(1), adapter->regs + A_ESPI_MISC_CONTROL);
-        	writel(nports == 4 ? 0x200040 : 0x1000080,
+		writel(nports == 4 ? 0x200040 : 0x1000080,
 		       adapter->regs + A_ESPI_MAXBURST1_MAXBURST2);
 	} else
-        	writel(0x800100, adapter->regs + A_ESPI_MAXBURST1_MAXBURST2);
+		writel(0x800100, adapter->regs + A_ESPI_MAXBURST1_MAXBURST2);
 
 	if (mac_type == CHBT_MAC_PM3393)
 		espi_setup_for_pm3393(adapter);
@@ -341,32 +341,31 @@ u32 t1_espi_get_mon(adapter_t *adapter,
  * compare with t1_espi_get_mon(), it reads espiInTxSop[0 ~ 3] in
  * one shot, since there is no per port counter on the out side.
  */
-int
-t1_espi_get_mon_t204(adapter_t *adapter, u32 *valp, u8 wait)
+int t1_espi_get_mon_t204(adapter_t *adapter, u32 *valp, u8 wait)
 {
-        struct peespi *espi = adapter->espi;
+	struct peespi *espi = adapter->espi;
 	u8 i, nport = (u8)adapter->params.nports;
 
-        if (!wait) {
-                if (!spin_trylock(&espi->lock))
-                        return -1;
-        } else
-                spin_lock(&espi->lock);
+	if (!wait) {
+		if (!spin_trylock(&espi->lock))
+			return -1;
+	} else
+		spin_lock(&espi->lock);
 
-	if ( (espi->misc_ctrl & MON_MASK) != F_MONITORED_DIRECTION ) {
+	if ((espi->misc_ctrl & MON_MASK) != F_MONITORED_DIRECTION) {
 		espi->misc_ctrl = (espi->misc_ctrl & ~MON_MASK) |
 					F_MONITORED_DIRECTION;
-                writel(espi->misc_ctrl, adapter->regs + A_ESPI_MISC_CONTROL);
- 	}
+		writel(espi->misc_ctrl, adapter->regs + A_ESPI_MISC_CONTROL);
+	}
 	for (i = 0 ; i < nport; i++, valp++) {
 		if (i) {
 			writel(espi->misc_ctrl | V_MONITORED_PORT_NUM(i),
 			       adapter->regs + A_ESPI_MISC_CONTROL);
 		}
-                *valp = readl(adapter->regs + A_ESPI_SCH_TOKEN3);
-        }
+		*valp = readl(adapter->regs + A_ESPI_SCH_TOKEN3);
+	}
 
-        writel(espi->misc_ctrl, adapter->regs + A_ESPI_MISC_CONTROL);
-        spin_unlock(&espi->lock);
-        return 0;
+	writel(espi->misc_ctrl, adapter->regs + A_ESPI_MISC_CONTROL);
+	spin_unlock(&espi->lock);
+	return 0;
 }
diff --git a/drivers/net/chelsio/fpga_defs.h b/drivers/net/chelsio/fpga_defs.h
index 17a3c2b..ccdb2bc 100644
--- a/drivers/net/chelsio/fpga_defs.h
+++ b/drivers/net/chelsio/fpga_defs.h
@@ -98,9 +98,9 @@
 #define A_MI0_DATA_INT 0xb10
 
 /* GMAC registers */
-#define A_GMAC_MACID_LO 0x28
-#define A_GMAC_MACID_HI 0x2c
-#define A_GMAC_CSR 0x30
+#define A_GMAC_MACID_LO	0x28
+#define A_GMAC_MACID_HI	0x2c
+#define A_GMAC_CSR	0x30
 
 #define S_INTERFACE    0
 #define M_INTERFACE    0x3
diff --git a/drivers/net/chelsio/gmac.h b/drivers/net/chelsio/gmac.h
index a2b8ad9..006a2eb 100644
--- a/drivers/net/chelsio/gmac.h
+++ b/drivers/net/chelsio/gmac.h
@@ -42,8 +42,15 @@
 
 #include "common.h"
 
-enum { MAC_STATS_UPDATE_FAST, MAC_STATS_UPDATE_FULL };
-enum { MAC_DIRECTION_RX = 1, MAC_DIRECTION_TX = 2 };
+enum {
+	MAC_STATS_UPDATE_FAST,
+	MAC_STATS_UPDATE_FULL
+};
+
+enum {
+	MAC_DIRECTION_RX = 1,
+	MAC_DIRECTION_TX = 2
+};
 
 struct cmac_statistics {
 	/* Transmit */
diff --git a/drivers/net/chelsio/ixf1010.c b/drivers/net/chelsio/ixf1010.c
index 91a5bf7..c40a88d 100644
--- a/drivers/net/chelsio/ixf1010.c
+++ b/drivers/net/chelsio/ixf1010.c
@@ -358,8 +358,8 @@ static void enable_port(struct cmac *mac
 	val |= (1 << index);
 	t1_tpi_write(adapter, REG_PORT_ENABLE, val);
 
-       	index <<= 2;
-        if (is_T2(adapter)) {
+	index <<= 2;
+	if (is_T2(adapter)) {
 		/* T204: set the Fifo water level & threshold */
 		t1_tpi_write(adapter, RX_FIFO_HIGH_WATERMARK_BASE + index, 0x740);
 		t1_tpi_write(adapter, RX_FIFO_LOW_WATERMARK_BASE + index, 0x730);
diff --git a/drivers/net/chelsio/mv88e1xxx.c b/drivers/net/chelsio/mv88e1xxx.c
index 75fac85..c7c5854 100644
--- a/drivers/net/chelsio/mv88e1xxx.c
+++ b/drivers/net/chelsio/mv88e1xxx.c
@@ -73,9 +73,8 @@ static int mv88e1xxx_interrupt_enable(st
 
 		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
 		elmer |= ELMER0_GP_BIT1;
-		if (is_T2(cphy->adapter)) {
-		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
-                }
+		if (is_T2(cphy->adapter))
+		    elmer |= ELMER0_GP_BIT2 | ELMER0_GP_BIT3 | ELMER0_GP_BIT4;
 		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
 	}
 	return 0;
@@ -92,9 +91,8 @@ static int mv88e1xxx_interrupt_disable(s
 
 		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
 		elmer &= ~ELMER0_GP_BIT1;
-		if (is_T2(cphy->adapter)) {
+		if (is_T2(cphy->adapter))
 		    elmer &= ~(ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4);
-                }
 		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
 	}
 	return 0;
@@ -112,9 +110,8 @@ static int mv88e1xxx_interrupt_clear(str
 	if (t1_is_asic(cphy->adapter)) {
 		t1_tpi_read(cphy->adapter, A_ELMER0_INT_CAUSE, &elmer);
 		elmer |= ELMER0_GP_BIT1;
-		if (is_T2(cphy->adapter)) {
+		if (is_T2(cphy->adapter))
 		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
-                }
 		t1_tpi_write(cphy->adapter, A_ELMER0_INT_CAUSE, elmer);
 	}
 	return 0;
@@ -300,7 +297,7 @@ static int mv88e1xxx_interrupt_handler(s
 
 	/*
 	 * Loop until cause reads zero. Need to handle bouncing interrupts.
-         */
+	 */
 	while (1) {
 		u32 cause;
 
@@ -379,11 +376,11 @@ static struct cphy *mv88e1xxx_phy_create
 	}
 	(void) mv88e1xxx_downshift_set(cphy, 1);   /* Enable downshift */
 
-        /* LED */
+	/* LED */
 	if (is_T2(adapter)) {
 		(void) simple_mdio_write(cphy,
 				MV88E1XXX_LED_CONTROL_REGISTER, 0x1);
-        }
+	}
 
 	return cphy;
 }
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
index 63cabeb..76a7ca9 100644
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -455,8 +455,8 @@ static void pm3393_rmon_update(struct ad
 static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 							      int flag)
 {
-	u64	ro;
-	u32	val0, val1, val2, val3;
+	u64 ro;
+	u32 val0, val1, val2, val3;
 
 	/* Snap the counters */
 	pmwrite(mac, SUNI1x10GEXP_REG_MSTAT_CONTROL,
@@ -534,9 +534,9 @@ static int pm3393_macaddress_set(struct
 	/* Store local copy */
 	memcpy(cmac->instance->mac_addr, ma, 6);
 
-	lo = ((u32) ma[1] << 8) | (u32) ma[0];
+	lo  = ((u32) ma[1] << 8) | (u32) ma[0];
 	mid = ((u32) ma[3] << 8) | (u32) ma[2];
-	hi = ((u32) ma[5] << 8) | (u32) ma[4];
+	hi  = ((u32) ma[5] << 8) | (u32) ma[4];
 
 	/* Disable Rx/Tx MAC before configuring it. */
 	if (enabled)
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 0ca8d87..f168f99 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -195,7 +195,7 @@ struct cmdQ {
 	struct cmdQ_e  *entries;        /* HW command descriptor Q */
 	struct cmdQ_ce *centries;       /* SW command context descriptor Q */
 	dma_addr_t	dma_addr;       /* DMA addr HW command descriptor Q */
- 	spinlock_t	lock;           /* Lock to protect cmdQ enqueuing */
+	spinlock_t	lock;           /* Lock to protect cmdQ enqueuing */
 };
 
 struct freelQ {
@@ -241,9 +241,9 @@ struct sched_port {
 /* Per T204 device */
 struct sched {
 	ktime_t         last_updated;   /* last time quotas were computed */
-	unsigned int 	max_avail;	/* max bits to be sent to any port */
-	unsigned int 	port;		/* port index (round robin ports) */
-	unsigned int 	num;		/* num skbs in per port queues */
+	unsigned int	max_avail;	/* max bits to be sent to any port */
+	unsigned int	port;		/* port index (round robin ports) */
+	unsigned int	num;		/* num skbs in per port queues */
 	struct sched_port p[MAX_NPORTS];
 	struct tasklet_struct sched_tsk;/* tasklet used to run scheduler */
 };
@@ -259,10 +259,10 @@ static void restart_sched(unsigned long)
  * contention.
  */
 struct sge {
-	struct adapter *adapter; 	/* adapter backpointer */
+	struct adapter *adapter;	/* adapter backpointer */
 	struct net_device *netdev;      /* netdevice backpointer */
-	struct freelQ 	freelQ[SGE_FREELQ_N]; /* buffer free lists */
-	struct respQ 	respQ;		/* response Q */
+	struct freelQ	freelQ[SGE_FREELQ_N]; /* buffer free lists */
+	struct respQ	respQ;		/* response Q */
 	unsigned long   stopped_tx_queues; /* bitmap of suspended Tx queues */
 	unsigned int	rx_pkt_pad;     /* RX padding for L2 packets */
 	unsigned int	jumbo_fl;       /* jumbo freelist Q index */
@@ -460,7 +460,7 @@ static struct sk_buff *sched_skb(struct
 	if (credits < MAX_SKB_FRAGS + 1)
 		goto out;
 
- again:
+again:
 	for (i = 0; i < MAX_NPORTS; i++) {
 		s->port = ++s->port & (MAX_NPORTS - 1);
 		skbq = &s->p[s->port].skbq;
@@ -483,8 +483,8 @@ static struct sk_buff *sched_skb(struct
 	if (update-- && sched_update_avail(sge))
 		goto again;
 
- out:
- 	/* If there are more pending skbs, we use the hardware to schedule us
+out:
+	/* If there are more pending skbs, we use the hardware to schedule us
 	 * again.
 	 */
 	if (s->num && !skb) {
@@ -641,14 +641,14 @@ static void free_cmdQ_buffers(struct sge
 			if (likely(pci_unmap_len(ce, dma_len))) {
 				pci_unmap_single(pdev,
 						 pci_unmap_addr(ce, dma_addr),
-			 			 pci_unmap_len(ce, dma_len),
+						 pci_unmap_len(ce, dma_len),
 						 PCI_DMA_TODEVICE);
 				q->sop = 0;
 			}
 		} else {
 			if (likely(pci_unmap_len(ce, dma_len))) {
 				pci_unmap_page(pdev, pci_unmap_addr(ce, dma_addr),
-			 		       pci_unmap_len(ce, dma_len),
+					       pci_unmap_len(ce, dma_len),
 					       PCI_DMA_TODEVICE);
 			}
 		}
@@ -770,7 +770,7 @@ void t1_set_vlan_accel(struct adapter *a
 static void configure_sge(struct sge *sge, struct sge_params *p)
 {
 	struct adapter *ap = sge->adapter;
-	
+
 	writel(0, ap->regs + A_SG_CONTROL);
 	setup_ring_params(ap, sge->cmdQ[0].dma_addr, sge->cmdQ[0].size,
 			  A_SG_CMD0BASELWR, A_SG_CMD0BASEUPR, A_SG_CMD0SIZE);
@@ -850,7 +850,6 @@ static void refill_free_list(struct sge
 	struct freelQ_e *e = &q->entries[q->pidx];
 	unsigned int dma_len = q->rx_buffer_size - q->dma_offset;
 
-
 	while (q->credits < q->size) {
 		struct sk_buff *skb;
 		dma_addr_t mapping;
@@ -881,7 +880,6 @@ static void refill_free_list(struct sge
 		}
 		q->credits++;
 	}
-
 }
 
 /*
@@ -1075,12 +1073,12 @@ static inline struct sk_buff *get_packet
 			skb_put(skb, len);
 			pci_dma_sync_single_for_cpu(pdev,
 					    pci_unmap_addr(ce, dma_addr),
- 					    pci_unmap_len(ce, dma_len),
+					    pci_unmap_len(ce, dma_len),
 					    PCI_DMA_FROMDEVICE);
 			memcpy(skb->data, ce->skb->data + dma_pad, len);
 			pci_dma_sync_single_for_device(pdev,
 					    pci_unmap_addr(ce, dma_addr),
- 					    pci_unmap_len(ce, dma_len),
+					    pci_unmap_len(ce, dma_len),
 					    PCI_DMA_FROMDEVICE);
 		} else if (!drop_thres)
 			goto use_orig_buf;
@@ -1137,6 +1135,7 @@ static void unexpected_offload(struct ad
 static inline unsigned int compute_large_page_tx_descs(struct sk_buff *skb)
 {
 	unsigned int count = 0;
+
 	if (PAGE_SIZE > SGE_TX_DESC_MAX_PLEN) {
 		unsigned int nfrags = skb_shinfo(skb)->nr_frags;
 		unsigned int i, len = skb->len - skb->data_len;
@@ -1343,7 +1342,7 @@ static void restart_sched(unsigned long
 	while ((skb = sched_skb(sge, NULL, credits)) != NULL) {
 		unsigned int genbit, pidx, count;
 	        count = 1 + skb_shinfo(skb)->nr_frags;
-       		count += compute_large_page_tx_descs(skb);
+		count += compute_large_page_tx_descs(skb);
 		q->in_use += count;
 		genbit = q->genbit;
 		pidx = q->pidx;
@@ -1462,11 +1461,11 @@ static void restart_tx_queues(struct sge
 }
 
 /*
- * update_tx_info is called from the interrupt handler/NAPI to return cmdQ0 
+ * update_tx_info is called from the interrupt handler/NAPI to return cmdQ0
  * information.
  */
-static unsigned int update_tx_info(struct adapter *adapter, 
-					  unsigned int flags, 
+static unsigned int update_tx_info(struct adapter *adapter,
+					  unsigned int flags,
 					  unsigned int pr0)
 {
 	struct sge *sge = adapter->sge;
@@ -1509,14 +1508,14 @@ static int process_responses(struct adap
 	int budget_left = budget;
 	unsigned int flags = 0;
 	unsigned int cmdq_processed[SGE_CMDQ_N] = {0, 0};
-	
+
 
 	while (likely(budget_left && e->GenerationBit == q->genbit)) {
 		flags |= e->Qsleeping;
-		
+
 		cmdq_processed[0] += e->Cmdq0CreditReturn;
 		cmdq_processed[1] += e->Cmdq1CreditReturn;
-		
+
 		/* We batch updates to the TX side to avoid cacheline
 		 * ping-pong of TX state information on MP where the sender
 		 * might run on a different CPU than this function...
@@ -1565,7 +1564,7 @@ static int process_responses(struct adap
 		--budget_left;
 	}
 
-	flags = update_tx_info(adapter, flags, cmdq_processed[0]); 
+	flags = update_tx_info(adapter, flags, cmdq_processed[0]);
 	sge->cmdQ[1].processed += cmdq_processed[1];
 
 	budget -= budget_left;
@@ -1592,7 +1591,7 @@ static int process_pure_responses(struct
 
 		cmdq_processed[0] += e->Cmdq0CreditReturn;
 		cmdq_processed[1] += e->Cmdq1CreditReturn;
-		
+
 		e++;
 		if (unlikely(++q->cidx == q->size)) {
 			q->cidx = 0;
@@ -1608,7 +1607,7 @@ static int process_pure_responses(struct
 		sge->stats.pure_rsps++;
 	} while (e->GenerationBit == q->genbit && !e->DataValid);
 
-	flags = update_tx_info(adapter, flags, cmdq_processed[0]); 
+	flags = update_tx_info(adapter, flags, cmdq_processed[0]);
 	sge->cmdQ[1].processed += cmdq_processed[1];
 
 	return e->GenerationBit == q->genbit;
@@ -1696,11 +1695,11 @@ static irqreturn_t t1_interrupt_napi(int
 	}  else if (readl(adapter->regs + A_PL_CAUSE) & F_PL_INTR_SGE_DATA) {
 	        printk(KERN_ERR "data interrupt while NAPI running\n");
 	}
-	
+
 	handled = t1_slow_intr_handler(adapter);
 	if (!handled)
 		sge->stats.unhandled_irqs++;
- unlock:
+unlock:
 	spin_unlock(&adapter->async_lock);
 	return IRQ_RETVAL(handled != 0);
 }
@@ -1811,7 +1810,7 @@ static int t1_sge_tx(struct sk_buff *skb
 	 * through the scheduler.
 	 */
 	if (sge->tx_sched && !qid && skb->dev) {
-	use_sched:
+use_sched:
 		use_sched_skb = 1;
 		/* Note that the scheduler might return a different skb than
 		 * the one passed in.
@@ -1915,7 +1914,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 		cpl = (struct cpl_tx_pkt *)hdr;
 	} else {
 		/*
-	 	 * Packets shorter than ETH_HLEN can break the MAC, drop them
+		 * Packets shorter than ETH_HLEN can break the MAC, drop them
 		 * early.  Also, we may get oversized packets because some
 		 * parts of the kernel don't handle our unusual hard_header_len
 		 * right, drop those too.
@@ -1999,9 +1998,9 @@ send:
 	 * then silently discard to avoid leak.
 	 */
 	if (unlikely(ret != NETDEV_TX_OK && skb != orig_skb)) {
- 		dev_kfree_skb_any(skb);
+		dev_kfree_skb_any(skb);
 		ret = NETDEV_TX_OK;
- 	}
+	}
 	return ret;
 }
 
@@ -2115,31 +2114,35 @@ static void espibug_workaround_t204(unsi
 
 	if (adapter->open_device_map & PORT_MASK) {
 		int i;
-		if (t1_espi_get_mon_t204(adapter, &(seop[0]), 0) < 0) {
+
+		if (t1_espi_get_mon_t204(adapter, &(seop[0]), 0) < 0)
 			return;
-		}
+
 		for (i = 0; i < nports; i++) {
-	        	struct sk_buff *skb = sge->espibug_skb[i];
-			if ( (netif_running(adapter->port[i].dev)) &&
-			     !(netif_queue_stopped(adapter->port[i].dev)) &&
-			     (seop[i] && ((seop[i] & 0xfff) == 0)) &&
-			     skb ) {
-	                	if (!skb->cb[0]) {
-	                        	u8 ch_mac_addr[ETH_ALEN] =
-	                            	{0x0, 0x7, 0x43, 0x0, 0x0, 0x0};
-	                        	memcpy(skb->data + sizeof(struct cpl_tx_pkt),
-	                               	ch_mac_addr, ETH_ALEN);
-	                        	memcpy(skb->data + skb->len - 10,
-						ch_mac_addr, ETH_ALEN);
-	                        	skb->cb[0] = 0xff;
-	                	}
-
-	                	/* bump the reference count to avoid freeing of
-	                 	 * the skb once the DMA has completed.
-	                 	 */
-	                	skb = skb_get(skb);
-	                	t1_sge_tx(skb, adapter, 0, adapter->port[i].dev);
+			struct sk_buff *skb = sge->espibug_skb[i];
+
+			if (!netif_running(adapter->port[i].dev) ||
+			    netif_queue_stopped(adapter->port[i].dev) ||
+			    !seop[i] || ((seop[i] & 0xfff) != 0) || !skb)
+				continue;
+
+			if (!skb->cb[0]) {
+				u8 ch_mac_addr[ETH_ALEN] = {
+					0x0, 0x7, 0x43, 0x0, 0x0, 0x0
+				};
+
+				memcpy(skb->data + sizeof(struct cpl_tx_pkt),
+					ch_mac_addr, ETH_ALEN);
+				memcpy(skb->data + skb->len - 10,
+					ch_mac_addr, ETH_ALEN);
+				skb->cb[0] = 0xff;
 			}
+
+			/* bump the reference count to avoid freeing of
+			 * the skb once the DMA has completed.
+			 */
+			skb = skb_get(skb);
+			t1_sge_tx(skb, adapter, 0, adapter->port[i].dev);
 		}
 	}
 	mod_timer(&sge->espibug_timer, jiffies + sge->espibug_timeout);
@@ -2218,7 +2221,7 @@ struct sge * __devinit t1_sge_create(str
 		if (adapter->params.nports > 1)
 			sge->espibug_timeout = HZ/100;
 	}
-	 
+
 
 	p->cmdQ_size[0] = SGE_CMDQ0_E_N;
 	p->cmdQ_size[1] = SGE_CMDQ1_E_N;
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 38dbaf2..c2522cd 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -223,13 +223,13 @@ static int fpga_slow_intr(adapter_t *ada
 		t1_sge_intr_error_handler(adapter->sge);
 
 	if (cause & FPGA_PCIX_INTERRUPT_GMAC)
-                fpga_phy_intr_handler(adapter);
+		fpga_phy_intr_handler(adapter);
 
 	if (cause & FPGA_PCIX_INTERRUPT_TP) {
-                /*
+		/*
 		 * FPGA doesn't support MC4 interrupts and it requires
 		 * this odd layer of indirection for MC5.
-                 */
+		 */
 		u32 tp_cause = readl(adapter->regs + FPGA_TP_ADDR_INTERRUPT_CAUSE);
 
 		/* Clear TP interrupt */
@@ -262,8 +262,7 @@ static int mi1_wait_until_ready(adapter_
 			udelay(10);
 	} while (busy && --attempts);
 	if (busy)
-		CH_ALERT("%s: MDIO operation timed out\n",
-			 adapter->name);
+		CH_ALERT("%s: MDIO operation timed out\n", adapter->name);
 	return busy;
 }
 
@@ -605,23 +604,23 @@ int t1_elmer0_ext_intr_handler(adapter_t
 
 	switch (board_info(adapter)->board) {
 #ifdef CONFIG_CHELSIO_T1_1G
-        case CHBT_BOARD_CHT204:
-        case CHBT_BOARD_CHT204E:
-        case CHBT_BOARD_CHN204:
-        case CHBT_BOARD_CHT204V: {
-                int i, port_bit;
+	case CHBT_BOARD_CHT204:
+	case CHBT_BOARD_CHT204E:
+	case CHBT_BOARD_CHN204:
+	case CHBT_BOARD_CHT204V: {
+		int i, port_bit;
 		for_each_port(adapter, i) {
 			port_bit = i + 1;
 			if (!(cause & (1 << port_bit)))
 				continue;
 
-	                phy = adapter->port[i].phy;
+			phy = adapter->port[i].phy;
 			phy_cause = phy->ops->interrupt_handler(phy);
 			if (phy_cause & cphy_cause_link_change)
 				t1_link_changed(adapter, i);
 		}
-                break;
-        }
+		break;
+	}
 	case CHBT_BOARD_CHT101:
 		if (cause & ELMER0_GP_BIT1) { /* Marvell 88E1111 interrupt */
 			phy = adapter->port[0].phy;
@@ -632,13 +631,13 @@ int t1_elmer0_ext_intr_handler(adapter_t
 		break;
 	case CHBT_BOARD_7500: {
 		int p;
-    		/*
+		/*
 		 * Elmer0's interrupt cause isn't useful here because there is
 		 * only one bit that can be set for all 4 ports.  This means
 		 * we are forced to check every PHY's interrupt status
 		 * register to see who initiated the interrupt.
-     		 */
-    		for_each_port(adapter, p) {
+		 */
+		for_each_port(adapter, p) {
 			phy = adapter->port[p].phy;
 			phy_cause = phy->ops->interrupt_handler(phy);
 			if (phy_cause & cphy_cause_link_change)
@@ -659,7 +658,7 @@ int t1_elmer0_ext_intr_handler(adapter_t
 		break;
 	case CHBT_BOARD_8000:
 	case CHBT_BOARD_CHT110:
-    		CH_DBG(adapter, INTR, "External interrupt cause 0x%x\n",
+		CH_DBG(adapter, INTR, "External interrupt cause 0x%x\n",
 		       cause);
 		if (cause & ELMER0_GP_BIT1) {        /* PMC3393 INTB */
 			struct cmac *mac = adapter->port[0].mac;
@@ -671,9 +670,9 @@ int t1_elmer0_ext_intr_handler(adapter_t
 
 			t1_tpi_read(adapter,
 					A_ELMER0_GPI_STAT, &mod_detect);
-	    		CH_MSG(adapter, INFO, LINK, "XPAK %s\n",
+			CH_MSG(adapter, INFO, LINK, "XPAK %s\n",
 			       mod_detect ? "removed" : "inserted");
-    		}
+		}
 		break;
 #ifdef CONFIG_CHELSIO_T1_COUGAR
 	case CHBT_BOARD_COUGAR:
@@ -757,7 +756,7 @@ void t1_interrupts_disable(adapter_t* ad
 
 	/* Disable PCIX & external chip interrupts. */
 	if (t1_is_asic(adapter))
-	    	writel(0, adapter->regs + A_PL_ENABLE);
+		writel(0, adapter->regs + A_PL_ENABLE);
 
 	/* PCI-X interrupts */
 	pci_write_config_dword(adapter->pdev, A_PCICFG_INTR_ENABLE, 0);
@@ -832,11 +831,11 @@ int t1_slow_intr_handler(adapter_t *adap
 /* Power sequencing is a work-around for Intel's XPAKs. */
 static void power_sequence_xpak(adapter_t* adapter)
 {
-    	u32 mod_detect;
-    	u32 gpo;
+	u32 mod_detect;
+	u32 gpo;
 
-    	/* Check for XPAK */
-    	t1_tpi_read(adapter, A_ELMER0_GPI_STAT, &mod_detect);
+	/* Check for XPAK */
+	t1_tpi_read(adapter, A_ELMER0_GPI_STAT, &mod_detect);
 	if (!(ELMER0_GP_BIT5 & mod_detect)) {
 		/* XPAK is present */
 		t1_tpi_read(adapter, A_ELMER0_GPO, &gpo);
@@ -879,31 +878,31 @@ static int board_init(adapter_t *adapter
 	case CHBT_BOARD_N210:
 	case CHBT_BOARD_CHT210:
 	case CHBT_BOARD_COUGAR:
-    		t1_tpi_par(adapter, 0xf);
-    		t1_tpi_write(adapter, A_ELMER0_GPO, 0x800);
+		t1_tpi_par(adapter, 0xf);
+		t1_tpi_write(adapter, A_ELMER0_GPO, 0x800);
 		break;
 	case CHBT_BOARD_CHT110:
-    		t1_tpi_par(adapter, 0xf);
-    		t1_tpi_write(adapter, A_ELMER0_GPO, 0x1800);
+		t1_tpi_par(adapter, 0xf);
+		t1_tpi_write(adapter, A_ELMER0_GPO, 0x1800);
 
-    		/* TBD XXX Might not need.  This fixes a problem
-     		 *         described in the Intel SR XPAK errata.
-     		 */
-    		power_sequence_xpak(adapter);
+		/* TBD XXX Might not need.  This fixes a problem
+		 *         described in the Intel SR XPAK errata.
+		 */
+		power_sequence_xpak(adapter);
 		break;
 #ifdef CONFIG_CHELSIO_T1_1G
-    case CHBT_BOARD_CHT204E:
-		        /* add config space write here */
+	case CHBT_BOARD_CHT204E:
+		/* add config space write here */
 	case CHBT_BOARD_CHT204:
 	case CHBT_BOARD_CHT204V:
 	case CHBT_BOARD_CHN204:
-                t1_tpi_par(adapter, 0xf);
-                t1_tpi_write(adapter, A_ELMER0_GPO, 0x804);
-                break;
+		t1_tpi_par(adapter, 0xf);
+		t1_tpi_write(adapter, A_ELMER0_GPO, 0x804);
+		break;
 	case CHBT_BOARD_CHT101:
 	case CHBT_BOARD_7500:
-    		t1_tpi_par(adapter, 0xf);
-    		t1_tpi_write(adapter, A_ELMER0_GPO, 0x1804);
+		t1_tpi_par(adapter, 0xf);
+		t1_tpi_write(adapter, A_ELMER0_GPO, 0x1804);
 		break;
 #endif
 	}
@@ -943,7 +942,7 @@ int t1_init_hw_modules(adapter_t *adapte
 		goto out_err;
 
 	err = 0;
- out_err:
+out_err:
 	return err;
 }
 
@@ -985,7 +984,7 @@ void t1_free_sw_modules(adapter_t *adapt
 	if (adapter->espi)
 		t1_espi_destroy(adapter->espi);
 #ifdef CONFIG_CHELSIO_T1_COUGAR
-        if (adapter->cspi)
+	if (adapter->cspi)
 		t1_cspi_destroy(adapter->cspi);
 #endif
 }
@@ -1012,7 +1011,7 @@ static void __devinit init_link_config(s
 		CH_ERR("%s: CSPI initialization failed\n",
 		       adapter->name);
 		goto error;
-        }
+	}
 #endif
 
 /*
diff --git a/drivers/net/chelsio/tp.c b/drivers/net/chelsio/tp.c
index 0ca0b6e..6222d58 100644
--- a/drivers/net/chelsio/tp.c
+++ b/drivers/net/chelsio/tp.c
@@ -17,39 +17,36 @@ struct petp {
 static void tp_init(adapter_t * ap, const struct tp_params *p,
 		    unsigned int tp_clk)
 {
-	if (t1_is_asic(ap)) {
-		u32 val;
-
-		val = F_TP_IN_CSPI_CPL | F_TP_IN_CSPI_CHECK_IP_CSUM |
-		    F_TP_IN_CSPI_CHECK_TCP_CSUM | F_TP_IN_ESPI_ETHERNET;
-		if (!p->pm_size)
-			val |= F_OFFLOAD_DISABLE;
-		else
-			val |= F_TP_IN_ESPI_CHECK_IP_CSUM |
-			    F_TP_IN_ESPI_CHECK_TCP_CSUM;
-		writel(val, ap->regs + A_TP_IN_CONFIG);
-		writel(F_TP_OUT_CSPI_CPL |
-		       F_TP_OUT_ESPI_ETHERNET |
-		       F_TP_OUT_ESPI_GENERATE_IP_CSUM |
-		       F_TP_OUT_ESPI_GENERATE_TCP_CSUM,
-		       ap->regs + A_TP_OUT_CONFIG);
-		writel(V_IP_TTL(64) |
-		       F_PATH_MTU /* IP DF bit */  |
-		       V_5TUPLE_LOOKUP(p->use_5tuple_mode) |
-		       V_SYN_COOKIE_PARAMETER(29),
-		       ap->regs + A_TP_GLOBAL_CONFIG);
-		/*
-		 * Enable pause frame deadlock prevention.
-		 */
-		if (is_T2(ap) && ap->params.nports > 1) {
-			u32 drop_ticks = DROP_MSEC * (tp_clk / 1000);
-
-			writel(F_ENABLE_TX_DROP | F_ENABLE_TX_ERROR |
-			       V_DROP_TICKS_CNT(drop_ticks) |
-			       V_NUM_PKTS_DROPPED(DROP_PKTS_CNT),
-			       ap->regs + A_TP_TX_DROP_CONFIG);
-		}
+	u32 val;
 
+	if (!t1_is_asic(ap))
+		return;
+
+	val = F_TP_IN_CSPI_CPL | F_TP_IN_CSPI_CHECK_IP_CSUM |
+		F_TP_IN_CSPI_CHECK_TCP_CSUM | F_TP_IN_ESPI_ETHERNET;
+	if (!p->pm_size)
+		val |= F_OFFLOAD_DISABLE;
+	else
+		val |= F_TP_IN_ESPI_CHECK_IP_CSUM | F_TP_IN_ESPI_CHECK_TCP_CSUM;
+	writel(val, ap->regs + A_TP_IN_CONFIG);
+	writel(F_TP_OUT_CSPI_CPL |
+	       F_TP_OUT_ESPI_ETHERNET |
+	       F_TP_OUT_ESPI_GENERATE_IP_CSUM |
+	       F_TP_OUT_ESPI_GENERATE_TCP_CSUM, ap->regs + A_TP_OUT_CONFIG);
+	writel(V_IP_TTL(64) |
+	       F_PATH_MTU /* IP DF bit */  |
+	       V_5TUPLE_LOOKUP(p->use_5tuple_mode) |
+	       V_SYN_COOKIE_PARAMETER(29), ap->regs + A_TP_GLOBAL_CONFIG);
+	/*
+	 * Enable pause frame deadlock prevention.
+	 */
+	if (is_T2(ap) && ap->params.nports > 1) {
+		u32 drop_ticks = DROP_MSEC * (tp_clk / 1000);
+
+		writel(F_ENABLE_TX_DROP | F_ENABLE_TX_ERROR |
+		       V_DROP_TICKS_CNT(drop_ticks) |
+		       V_NUM_PKTS_DROPPED(DROP_PKTS_CNT),
+		       ap->regs + A_TP_TX_DROP_CONFIG);
 	}
 }
 
@@ -61,6 +58,7 @@ void t1_tp_destroy(struct petp *tp)
 struct petp *__devinit t1_tp_create(adapter_t * adapter, struct tp_params *p)
 {
 	struct petp *tp = kzalloc(sizeof(*tp), GFP_KERNEL);
+
 	if (!tp)
 		return NULL;
 
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index 8c4a31e..bdd25c0 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -234,14 +234,14 @@ static void run_table(adapter_t *adapter
 
 static int bist_rd(adapter_t *adapter, int moduleid, int address)
 {
-	int data=0;
-	u32 result=0;
-
-	if(	(address != 0x0) &&
-		(address != 0x1) &&
-		(address != 0x2) &&
-		(address != 0xd) &&
-		(address != 0xe))
+	int data = 0;
+	u32 result = 0;
+
+	if ((address != 0x0) &&
+	    (address != 0x1) &&
+	    (address != 0x2) &&
+	    (address != 0xd) &&
+	    (address != 0xe))
 			CH_ERR("No bist address: 0x%x\n", address);
 
 	data = ((0x00 << 24) | ((address & 0xff) << 16) | (0x00 << 8) |
@@ -251,9 +251,9 @@ static int bist_rd(adapter_t *adapter, i
 	udelay(10);
 
 	vsc_read(adapter, REG_RAM_BIST_RESULT, &result);
-	if((result & (1<<9)) != 0x0)
+	if ((result & (1 << 9)) != 0x0)
 		CH_ERR("Still in bist read: 0x%x\n", result);
-	else if((result & (1<<8)) != 0x0)
+	else if ((result & (1 << 8)) != 0x0)
 		CH_ERR("bist read error: 0x%x\n", result);
 
 	return (result & 0xff);
@@ -261,17 +261,17 @@ static int bist_rd(adapter_t *adapter, i
 
 static int bist_wr(adapter_t *adapter, int moduleid, int address, int value)
 {
-	int data=0;
-	u32 result=0;
-
-	if(	(address != 0x0) &&
-		(address != 0x1) &&
-		(address != 0x2) &&
-		(address != 0xd) &&
-		(address != 0xe))
+	int data = 0;
+	u32 result = 0;
+
+	if ((address != 0x0) &&
+	    (address != 0x1) &&
+	    (address != 0x2) &&
+	    (address != 0xd) &&
+	    (address != 0xe))
 			CH_ERR("No bist address: 0x%x\n", address);
 
-	if( value>255 )
+	if (value > 255)
 		CH_ERR("Suspicious write out of range value: 0x%x\n", value);
 
 	data = ((0x01 << 24) | ((address & 0xff) << 16) | (value << 8) |
@@ -281,9 +281,9 @@ static int bist_wr(adapter_t *adapter, i
 	udelay(5);
 
 	vsc_read(adapter, REG_RAM_BIST_CMD, &result);
-	if((result & (1<<27)) != 0x0)
+	if ((result & (1 << 27)) != 0x0)
 		CH_ERR("Still in bist write: 0x%x\n", result);
-	else if((result & (1<<26)) != 0x0)
+	else if ((result & (1 << 26)) != 0x0)
 		CH_ERR("bist write error: 0x%x\n", result);
 
 	return 0;
@@ -321,15 +321,14 @@ static int enable_mem(adapter_t *adapter
 
 static int run_bist_all(adapter_t *adapter)
 {
-	int port=0;
-	u32 val=0;
+	int port = 0;
+	u32 val = 0;
 
 	vsc_write(adapter, REG_MEM_BIST, 0x5);
 	vsc_read(adapter, REG_MEM_BIST, &val);
 
-	for(port=0; port<12; port++){
+	for (port = 0; port < 12; port++)
 		vsc_write(adapter, REG_DEV_SETUP(port), 0x0);
-	}
 
 	udelay(300);
 	vsc_write(adapter, REG_SPI4_MISC, 0x00040409);
@@ -352,9 +351,9 @@ static int run_bist_all(adapter_t *adapt
 	udelay(300);
 	vsc_write(adapter, REG_SPI4_MISC, 0x60040400);
 	udelay(300);
-	for(port=0; port<12; port++){
+	for (port = 0; port < 12; port++)
 		vsc_write(adapter, REG_DEV_SETUP(port), 0x1);
-	}
+
 	udelay(300);
 	vsc_write(adapter, REG_MEM_BIST, 0x0);
 	mdelay(10);
@@ -612,7 +611,7 @@ static void port_stats_update(struct cma
 	rmon_update(mac, REG_RX_SYMBOL_CARRIER(port),
 		    &mac->stats.RxSymbolErrors);
 	rmon_update(mac, REG_RX_SIZE_1519_TO_MAX(port),
-            &mac->stats.RxJumboFramesOK);
+		    &mac->stats.RxJumboFramesOK);
 
 	/* Tx stats (skip collision stats as we are full-duplex only) */
 	rmon_update(mac, REG_TX_OK_BYTES(port), &mac->stats.TxOctetsOK);
@@ -624,7 +623,7 @@ static void port_stats_update(struct cma
 	rmon_update(mac, REG_TX_PAUSE(port), &mac->stats.TxPauseFrames);
 	rmon_update(mac, REG_TX_UNDERRUN(port), &mac->stats.TxUnderrun);
 	rmon_update(mac, REG_TX_SIZE_1519_TO_MAX(port),
-            &mac->stats.TxJumboFramesOK);
+		    &mac->stats.TxJumboFramesOK);
 }
 
 /*
diff --git a/drivers/net/chelsio/vsc8244.c b/drivers/net/chelsio/vsc8244.c
index f947cf6..251d485 100644
--- a/drivers/net/chelsio/vsc8244.c
+++ b/drivers/net/chelsio/vsc8244.c
@@ -54,7 +54,7 @@ enum {
 };
 
 #define CFG_CHG_INTR_MASK (VSC_INTR_LINK_CHG | VSC_INTR_NEG_ERR | \
-	 		   VSC_INTR_NEG_DONE)
+			   VSC_INTR_NEG_DONE)
 #define INTR_MASK (CFG_CHG_INTR_MASK | VSC_INTR_TX_FIFO | VSC_INTR_RX_FIFO | \
 		   VSC_INTR_ENABLE)
 
@@ -94,19 +94,18 @@ static int vsc8244_intr_enable(struct cp
 {
 	simple_mdio_write(cphy, VSC8244_INTR_ENABLE, INTR_MASK);
 
-    /* Enable interrupts through Elmer */
+	/* Enable interrupts through Elmer */
 	if (t1_is_asic(cphy->adapter)) {
 		u32 elmer;
 
 		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
 		elmer |= ELMER0_GP_BIT1;
-		if (is_T2(cphy->adapter)) {
+		if (is_T2(cphy->adapter))
 		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
-                }
 		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
 	}
 
-    return 0;
+	return 0;
 }
 
 static int vsc8244_intr_disable(struct cphy *cphy)
@@ -118,19 +117,18 @@ static int vsc8244_intr_disable(struct c
 
 		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
 		elmer &= ~ELMER0_GP_BIT1;
-		if (is_T2(cphy->adapter)) {
+		if (is_T2(cphy->adapter))
 		    elmer &= ~(ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4);
-                }
 		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
 	}
 
-    return 0;
+	return 0;
 }
 
 static int vsc8244_intr_clear(struct cphy *cphy)
 {
 	u32 val;
-    u32 elmer;
+	u32 elmer;
 
 	/* Clear PHY interrupts by reading the register. */
 	simple_mdio_read(cphy, VSC8244_INTR_ENABLE, &val);
@@ -138,13 +136,12 @@ static int vsc8244_intr_clear(struct cph
 	if (t1_is_asic(cphy->adapter)) {
 		t1_tpi_read(cphy->adapter, A_ELMER0_INT_CAUSE, &elmer);
 		elmer |= ELMER0_GP_BIT1;
-		if (is_T2(cphy->adapter)) {
+		if (is_T2(cphy->adapter))
 		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
-                }
 		t1_tpi_write(cphy->adapter, A_ELMER0_INT_CAUSE, elmer);
 	}
 
-    return 0;
+	return 0;
 }
 
 /*
@@ -179,13 +176,13 @@ static int vsc8244_set_speed_duplex(stru
 
 int t1_mdio_set_bits(struct cphy *phy, int mmd, int reg, unsigned int bits)
 {
-    int ret;
-    unsigned int val;
+	int ret;
+	unsigned int val;
 
-    ret = mdio_read(phy, mmd, reg, &val);
-    if (!ret)
-        ret = mdio_write(phy, mmd, reg, val | bits);
-    return ret;
+	ret = mdio_read(phy, mmd, reg, &val);
+	if (!ret)
+		ret = mdio_write(phy, mmd, reg, val | bits);
+	return ret;
 }
 
 static int vsc8244_autoneg_enable(struct cphy *cphy)
@@ -235,7 +232,7 @@ static int vsc8244_advertise(struct cphy
 }
 
 static int vsc8244_get_link_status(struct cphy *cphy, int *link_ok,
-				     int *speed, int *duplex, int *fc)
+				   int *speed, int *duplex, int *fc)
 {
 	unsigned int bmcr, status, lpa, adv;
 	int err, sp = -1, dplx = -1, pause = 0;
@@ -343,7 +340,8 @@ static struct cphy_ops vsc8244_ops = {
 	.get_link_status      = vsc8244_get_link_status
 };
 
-static struct cphy* vsc8244_phy_create(adapter_t *adapter, int phy_addr, struct mdio_ops *mdio_ops)
+static struct cphy* vsc8244_phy_create(adapter_t *adapter, int phy_addr,
+				       struct mdio_ops *mdio_ops)
 {
 	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
-- 
1.4.4.1

