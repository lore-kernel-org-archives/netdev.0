From: Kumar Amit Mehta <gmate.amit@gmail.com>
Subject: [PATCH] drivers: ethernet: qlogic: netxen_nic_ethtool.c: Fixed a coding style issue
Date: Sun,  4 Nov 2012 21:46:08 -0800
Message-ID: <1352094368-5037-1-git-send-email-gmate.amit@gmail.com>
Cc: rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: sony.chacko@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed some coding style issues.

Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>
---
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   86 ++++++++++----------
 1 file changed, 43 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 6bf73e1..4ca2c19 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -218,7 +218,7 @@ skip:
 			check_sfp_module = netif_running(dev) &&
 				adapter->has_link_events;
 		} else {
-			ecmd->supported |= (SUPPORTED_TP |SUPPORTED_Autoneg);
+			ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
 			ecmd->advertising |=
 				(ADVERTISED_TP | ADVERTISED_Autoneg);
 			ecmd->port = PORT_TP;
@@ -381,7 +381,7 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 
 static int
 netxen_nic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
-		      u8 * bytes)
+		      u8 *bytes)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	int offset;
@@ -498,19 +498,19 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 		pause->rx_pause = netxen_gb_get_rx_flowctl(val);
 		val = NXRD32(adapter, NETXEN_NIU_GB_PAUSE_CTL);
 		switch (port) {
-			case 0:
-				pause->tx_pause = !(netxen_gb_get_gb0_mask(val));
-				break;
-			case 1:
-				pause->tx_pause = !(netxen_gb_get_gb1_mask(val));
-				break;
-			case 2:
-				pause->tx_pause = !(netxen_gb_get_gb2_mask(val));
-				break;
-			case 3:
-			default:
-				pause->tx_pause = !(netxen_gb_get_gb3_mask(val));
-				break;
+		case 0:
+			pause->tx_pause = !(netxen_gb_get_gb0_mask(val));
+			break;
+		case 1:
+			pause->tx_pause = !(netxen_gb_get_gb1_mask(val));
+			break;
+		case 2:
+			pause->tx_pause = !(netxen_gb_get_gb2_mask(val));
+			break;
+		case 3:
+		default:
+			pause->tx_pause = !(netxen_gb_get_gb3_mask(val));
+			break;
 		}
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		if ((port < 0) || (port >= NETXEN_NIU_MAX_XG_PORTS))
@@ -556,31 +556,31 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 		/* set autoneg */
 		val = NXRD32(adapter, NETXEN_NIU_GB_PAUSE_CTL);
 		switch (port) {
-			case 0:
-				if (pause->tx_pause)
-					netxen_gb_unset_gb0_mask(val);
-				else
-					netxen_gb_set_gb0_mask(val);
-				break;
-			case 1:
-				if (pause->tx_pause)
-					netxen_gb_unset_gb1_mask(val);
-				else
-					netxen_gb_set_gb1_mask(val);
-				break;
-			case 2:
-				if (pause->tx_pause)
-					netxen_gb_unset_gb2_mask(val);
-				else
-					netxen_gb_set_gb2_mask(val);
-				break;
-			case 3:
-			default:
-				if (pause->tx_pause)
-					netxen_gb_unset_gb3_mask(val);
-				else
-					netxen_gb_set_gb3_mask(val);
-				break;
+		case 0:
+			if (pause->tx_pause)
+				netxen_gb_unset_gb0_mask(val);
+			else
+				netxen_gb_set_gb0_mask(val);
+			break;
+		case 1:
+			if (pause->tx_pause)
+				netxen_gb_unset_gb1_mask(val);
+			else
+				netxen_gb_set_gb1_mask(val);
+			break;
+		case 2:
+			if (pause->tx_pause)
+				netxen_gb_unset_gb2_mask(val);
+			else
+				netxen_gb_set_gb2_mask(val);
+			break;
+		case 3:
+		default:
+			if (pause->tx_pause)
+				netxen_gb_unset_gb3_mask(val);
+			else
+				netxen_gb_set_gb3_mask(val);
+			break;
 		}
 		NXWR32(adapter, NETXEN_NIU_GB_PAUSE_CTL, val);
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
@@ -643,7 +643,7 @@ static int netxen_get_sset_count(struct net_device *dev, int sset)
 
 static void
 netxen_nic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
-		     u64 * data)
+		     u64 *data)
 {
 	memset(data, 0, sizeof(uint64_t) * NETXEN_NIC_TEST_LEN);
 	if ((data[0] = netxen_nic_reg_test(dev)))
@@ -654,7 +654,7 @@ netxen_nic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 }
 
 static void
-netxen_nic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
+netxen_nic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	int index;
 
@@ -675,7 +675,7 @@ netxen_nic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
 
 static void
 netxen_nic_get_ethtool_stats(struct net_device *dev,
-			     struct ethtool_stats *stats, u64 * data)
+			     struct ethtool_stats *stats, u64 *data)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	int index;
-- 
1.7.9.5
