From: greearb@candelatech.com
Subject: [PATCH] e100:  Show short v/s long rx lengh errors in ethtool stats.
Date: Thu, 16 Feb 2012 10:56:10 -0800
Message-ID: <1329418570-31656-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59140 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594Ab2BPS4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 13:56:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 db20a36... 6bd072d... M	drivers/net/ethernet/intel/e100.c
 drivers/net/ethernet/intel/e100.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index db20a36..6bd072d 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2660,6 +2660,7 @@ static const char e100_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx_deferred", "tx_single_collisions", "tx_multi_collisions",
 	"tx_flow_control_pause", "rx_flow_control_pause",
 	"rx_flow_control_unsupported", "tx_tco_packets", "rx_tco_packets",
+	"rx_short_frame_errors", "rx_over_length_errors",
 };
 #define E100_NET_STATS_LEN	21
 #define E100_STATS_LEN	ARRAY_SIZE(e100_gstrings_stats)
@@ -2693,6 +2694,8 @@ static void e100_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = nic->rx_fc_unsupported;
 	data[i++] = nic->tx_tco_frames;
 	data[i++] = nic->rx_tco_frames;
+	data[i++] = nic->rx_short_frame_errors;
+	data[i++] = nic->rx_over_length_errors;
 }
 
 static void e100_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
-- 
1.7.3.4
