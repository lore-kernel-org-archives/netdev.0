From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 7/9] ixgbevf: make ethtool ops and strings const
Date: Thu, 19 Jan 2012 00:13:32 -0800
Message-ID: <1326960814-16976-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23062 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754870Ab2ASINy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:54 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index dc8e651..c857003 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -56,7 +56,8 @@ struct ixgbe_stats {
 			    offsetof(struct ixgbevf_adapter, m),         \
 			    offsetof(struct ixgbevf_adapter, b),         \
 			    offsetof(struct ixgbevf_adapter, r)
-static struct ixgbe_stats ixgbe_gstrings_stats[] = {
+
+static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_packets", IXGBEVF_STAT(stats.vfgprc, stats.base_vfgprc,
 				    stats.saved_reset_vfgprc)},
 	{"tx_packets", IXGBEVF_STAT(stats.vfgptc, stats.base_vfgptc,
@@ -671,7 +672,7 @@ static int ixgbevf_nway_reset(struct net_device *netdev)
 	return 0;
 }
 
-static struct ethtool_ops ixgbevf_ethtool_ops = {
+static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_settings           = ixgbevf_get_settings,
 	.get_drvinfo            = ixgbevf_get_drvinfo,
 	.get_regs_len           = ixgbevf_get_regs_len,
-- 
1.7.7.5
