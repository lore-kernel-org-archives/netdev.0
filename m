From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/13] igb: Cleanups to fix line length warnings
Date: Thu, 24 Apr 2014 18:02:57 -0700
Message-ID: <1398387783-30414-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbaDYBDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 21:03:20 -0400
In-Reply-To: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes WARNING:LONG_LINE found with checkpatch check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2: fix code indentation based on feedback from David Miller
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 13 ++++++++-----
 drivers/net/ethernet/intel/igb/igb_main.c    |  8 +++++---
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 561df67..b83694b 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1129,8 +1129,10 @@ static struct igb_reg_test reg_test_82576[] = {
 	{ E1000_RDBAH(4),  0x40, 12, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ E1000_RDLEN(4),  0x40, 12, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
 	/* Enable all RX queues before testing. */
-	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
-	{ E1000_RXDCTL(4), 0x40, 12,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0,
+	  E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RXDCTL(4), 0x40, 12, WRITE_NO_TEST, 0,
+	  E1000_RXDCTL_QUEUE_ENABLE },
 	/* RDH is read-only for 82576, only test RDT. */
 	{ E1000_RDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_RDT(4),	   0x40, 12,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
@@ -1167,7 +1169,8 @@ static struct igb_reg_test reg_test_82575[] = {
 	{ E1000_RDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ E1000_RDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	/* Enable all four RX queues before testing. */
-	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0,
+	  E1000_RXDCTL_QUEUE_ENABLE },
 	/* RDH is read-only for 82575, only test RDT. */
 	{ E1000_RDT(0),    0x100, 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0, 0 },
@@ -1220,8 +1223,8 @@ static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 	val = rd32(reg);
 	if ((write & mask) != (val & mask)) {
 		dev_err(&adapter->pdev->dev,
-			"set/check reg %04X test failed: got 0x%08X expected 0x%08X\n", reg,
-			(val & mask), (write & mask));
+			"set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
+			reg, (val & mask), (write & mask));
 		*data = reg;
 		return 1;
 	}
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a339a63..93cac38 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -138,7 +138,7 @@ static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
 static netdev_tx_t igb_xmit_frame(struct sk_buff *skb, struct net_device *);
 static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *dev,
-						 struct rtnl_link_stats64 *stats);
+					  struct rtnl_link_stats64 *stats);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
 static void igb_set_uta(struct igb_adapter *adapter);
@@ -156,7 +156,8 @@ static bool igb_clean_rx_irq(struct igb_q_vector *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
-static void igb_vlan_mode(struct net_device *netdev, netdev_features_t features);
+static void igb_vlan_mode(struct net_device *netdev,
+			  netdev_features_t features);
 static int igb_vlan_rx_add_vid(struct net_device *, __be16, u16);
 static int igb_vlan_rx_kill_vid(struct net_device *, __be16, u16);
 static void igb_restore_vlan(struct igb_adapter *);
@@ -3388,7 +3389,8 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 
 	if (adapter->rss_indir_tbl_init != num_rx_queues) {
 		for (j = 0; j < IGB_RETA_SIZE; j++)
-			adapter->rss_indir_tbl[j] = (j * num_rx_queues) / IGB_RETA_SIZE;
+			adapter->rss_indir_tbl[j] =
+			(j * num_rx_queues) / IGB_RETA_SIZE;
 		adapter->rss_indir_tbl_init = num_rx_queues;
 	}
 	igb_write_rss_indir_tbl(adapter);
-- 
1.9.0
