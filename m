From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] net: Fix spelling typo in net
Date: Fri, 13 Apr 2012 23:33:20 +0900
Message-ID: <1334327600-18904-1-git-send-email-standby24x7@gmail.com>
Cc: linux-kernel@vger.kernel.org, Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, trivial@kernel.org, davem@davemloft.net,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo within drivers/net.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c    |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c            |    2 +-
 drivers/net/ethernet/ti/tlan.c                  |    2 +-
 drivers/net/irda/sh_irda.c                      |    2 +-
 drivers/net/irda/sh_sir.c                       |    2 +-
 drivers/net/wan/lmc/lmc_main.c                  |    2 +-
 drivers/net/wimax/i2400m/usb.c                  |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c          |    4 ++--
 drivers/net/wireless/ipw2x00/ipw2200.c          |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c     |    2 +-
 11 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 70346fd..e15a1fb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -83,7 +83,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + NUM_PERF_STATS)
 
 static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
-	"Interupt Test",
+	"Interrupt Test",
 	"Link Test",
 	"Speed Test",
 	"Register Test",
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 49343ec..09d8d33 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -3845,7 +3845,7 @@ static int ql_wol(struct ql_adapter *qdev)
 	if (qdev->wol & (WAKE_ARP | WAKE_MAGICSECURE | WAKE_PHY | WAKE_UCAST |
 			WAKE_MCAST | WAKE_BCAST)) {
 		netif_err(qdev, ifdown, qdev->ndev,
-			  "Unsupported WOL paramter. qdev->wol = 0x%x.\n",
+			  "Unsupported WOL parameter. qdev->wol = 0x%x.\n",
 			  qdev->wol);
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index ad973ff..4179966 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1317,7 +1317,7 @@ static void print_rxdd(struct rxd_desc *rxdd, u32 rxd_val1, u16 len,
 
 static void print_rxfd(struct rxf_desc *rxfd)
 {
-	DBG("=== RxF desc CHIP ORDER/ENDIANESS =============\n"
+	DBG("=== RxF desc CHIP ORDER/ENDIANNESS =============\n"
 	    "info 0x%x va_lo %u pa_lo 0x%x pa_hi 0x%x len 0x%x\n",
 	    rxfd->info, rxfd->va_lo, rxfd->pa_lo, rxfd->pa_hi, rxfd->len);
 }
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 817ad3b..bb8b802 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2545,7 +2545,7 @@ static void tlan_phy_reset(struct net_device *dev)
 
 	phy = priv->phy[priv->phy_num];
 
-	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Reseting PHY.\n", dev->name);
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Resetting PHY.\n", dev->name);
 	tlan_mii_sync(dev->base_addr);
 	value = MII_GC_LOOPBK | MII_GC_RESET;
 	tlan_mii_write_reg(dev, phy, MII_GEN_CTL, value);
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 725d6b3..eb315b8 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -737,7 +737,7 @@ static int sh_irda_stop(struct net_device *ndev)
 	netif_stop_queue(ndev);
 	pm_runtime_put_sync(&self->pdev->dev);
 
-	dev_info(&ndev->dev, "stoped\n");
+	dev_info(&ndev->dev, "stopped\n");
 
 	return 0;
 }
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index e6661b5..256eddf 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -685,7 +685,7 @@ static int sh_sir_stop(struct net_device *ndev)
 
 	netif_stop_queue(ndev);
 
-	dev_info(&ndev->dev, "stoped\n");
+	dev_info(&ndev->dev, "stopped\n");
 
 	return 0;
 }
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 76a8a4a..e38626d 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1120,7 +1120,7 @@ static void lmc_running_reset (struct net_device *dev) /*fold00*/
 {
     lmc_softc_t *sc = dev_to_sc(dev);
 
-    lmc_trace(dev, "lmc_runnig_reset in");
+    lmc_trace(dev, "lmc_running_reset in");
 
     /* stop interrupts */
     /* Clear the interrupt mask */
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 29b1e03..713d033 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -695,7 +695,7 @@ int i2400mu_resume(struct usb_interface *iface)
 	d_fnstart(3, dev, "(iface %p)\n", iface);
 	rmb();		/* see i2400m->updown's documentation  */
 	if (i2400m->updown == 0) {
-		d_printf(1, dev, "fw was down, no resume neeed\n");
+		d_printf(1, dev, "fw was down, no resume needed\n");
 		goto out;
 	}
 	d_printf(1, dev, "fw was up, resuming\n");
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index f0551f8..ab075ef 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -3773,7 +3773,7 @@ IPW2100_ORD(STAT_TX_HOST_REQUESTS, "requested Host Tx's (MSDU)"),
 	    IPW2100_ORD(COUNTRY_CODE,
 				"IEEE country code as recv'd from beacon"),
 	    IPW2100_ORD(COUNTRY_CHANNELS,
-				"channels suported by country"),
+				"channels supported by country"),
 	    IPW2100_ORD(RESET_CNT, "adapter resets (warm)"),
 	    IPW2100_ORD(BEACON_INTERVAL, "Beacon interval"),
 	    IPW2100_ORD(ANTENNA_DIVERSITY,
@@ -4062,7 +4062,7 @@ static int ipw2100_switch_mode(struct ipw2100_priv *priv, u32 mode)
 	ipw2100_firmware.version = 0;
 #endif
 
-	printk(KERN_INFO "%s: Reseting on mode change.\n", priv->net_dev->name);
+	printk(KERN_INFO "%s: Resetting on mode change.\n", priv->net_dev->name);
 	priv->reset_backoff = 0;
 	schedule_reset(priv);
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 2b02257..bfbe662 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -7024,7 +7024,7 @@ static int ipw_qos_activate(struct ipw_priv *priv,
 			    cpu_to_le16(burst_duration);
 	} else if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
 		if (type == IEEE_B) {
-			IPW_DEBUG_QOS("QoS activate IBSS nework mode %d\n",
+			IPW_DEBUG_QOS("QoS activate IBSS network mode %d\n",
 				      type);
 			if (priv->qos_data.qos_enable == 0)
 				active_one = &def_parameters_CCK;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 509f5af..7ac9b8c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1745,7 +1745,7 @@ static void _rtl92de_efuse_update_chip_version(struct ieee80211_hw *hw)
 		break;
 	default:
 		chipver |= CHIP_92D_D_CUT;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Unkown CUT!\n");
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Unknown CUT!\n");
 		break;
 	}
 	rtlpriv->rtlhal.version = chipver;
-- 
1.7.10.128.g7945c
