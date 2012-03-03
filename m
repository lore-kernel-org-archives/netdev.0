From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] e100: Show short v/s long rx length errors in ethtool stats.
Date: Fri,  2 Mar 2012 18:26:25 -0800
Message-ID: <1330741587-24073-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10531 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811Ab2CCC0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:26:31 -0500
In-Reply-To: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index d2b7872..e498eff 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2661,6 +2661,7 @@ static const char e100_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx_deferred", "tx_single_collisions", "tx_multi_collisions",
 	"tx_flow_control_pause", "rx_flow_control_pause",
 	"rx_flow_control_unsupported", "tx_tco_packets", "rx_tco_packets",
+	"rx_short_frame_errors", "rx_over_length_errors",
 };
 #define E100_NET_STATS_LEN	21
 #define E100_STATS_LEN	ARRAY_SIZE(e100_gstrings_stats)
@@ -2694,6 +2695,8 @@ static void e100_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = nic->rx_fc_unsupported;
 	data[i++] = nic->tx_tco_frames;
 	data[i++] = nic->rx_tco_frames;
+	data[i++] = nic->rx_short_frame_errors;
+	data[i++] = nic->rx_over_length_errors;
 }
 
 static void e100_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
-- 
1.7.7.6
