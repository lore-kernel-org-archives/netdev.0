From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 03/12] net/mlx5e: Rename VPort counters
Date: Fri, 22 Apr 2016 22:00:38 +0300
Message-ID: <1461351647-27412-4-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36948 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752485AbcDVTC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:26 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

VPort and software counters names are confusing and may be unclear, all
VPort counters now have a prefix of rx/tx_vport_*.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   35 +++++++++++---------
 1 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 116320d..4f3a08d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -115,32 +115,35 @@ struct mlx5e_vport_stats {
 };
 
 static const struct counter_desc vport_stats_desc[] = {
-	{ "rx_error_packets", VPORT_COUNTER_OFF(received_errors.packets) },
-	{ "rx_error_bytes", VPORT_COUNTER_OFF(received_errors.octets) },
-	{ "tx_error_packets", VPORT_COUNTER_OFF(transmit_errors.packets) },
-	{ "tx_error_bytes", VPORT_COUNTER_OFF(transmit_errors.octets) },
-	{ "rx_unicast_packets",
+	{ "rx_vport_error_packets",
+		VPORT_COUNTER_OFF(received_errors.packets) },
+	{ "rx_vport_error_bytes", VPORT_COUNTER_OFF(received_errors.octets) },
+	{ "tx_vport_error_packets",
+		VPORT_COUNTER_OFF(transmit_errors.packets) },
+	{ "tx_vport_error_bytes", VPORT_COUNTER_OFF(transmit_errors.octets) },
+	{ "rx_vport_unicast_packets",
 		VPORT_COUNTER_OFF(received_eth_unicast.packets) },
-	{ "rx_unicast_bytes", VPORT_COUNTER_OFF(received_eth_unicast.octets) },
-	{ "tx_unicast_packets",
+	{ "rx_vport_unicast_bytes",
+		VPORT_COUNTER_OFF(received_eth_unicast.octets) },
+	{ "tx_vport_unicast_packets",
 		VPORT_COUNTER_OFF(transmitted_eth_unicast.packets) },
-	{ "tx_unicast_bytes",
+	{ "tx_vport_unicast_bytes",
 		VPORT_COUNTER_OFF(transmitted_eth_unicast.octets) },
-	{ "rx_multicast_packets",
+	{ "rx_vport_multicast_packets",
 		VPORT_COUNTER_OFF(received_eth_multicast.packets) },
-	{ "rx_multicast_bytes",
+	{ "rx_vport_multicast_bytes",
 		VPORT_COUNTER_OFF(received_eth_multicast.octets) },
-	{ "tx_multicast_packets",
+	{ "tx_vport_multicast_packets",
 		VPORT_COUNTER_OFF(transmitted_eth_multicast.packets) },
-	{ "tx_multicast_bytes",
+	{ "tx_vport_multicast_bytes",
 		VPORT_COUNTER_OFF(transmitted_eth_multicast.octets) },
-	{ "rx_broadcast_packets",
+	{ "rx_vport_broadcast_packets",
 		VPORT_COUNTER_OFF(received_eth_broadcast.packets) },
-	{ "rx_broadcast_bytes",
+	{ "rx_vport_broadcast_bytes",
 		VPORT_COUNTER_OFF(received_eth_broadcast.octets) },
-	{ "tx_broadcast_packets",
+	{ "tx_vport_broadcast_packets",
 		VPORT_COUNTER_OFF(transmitted_eth_broadcast.packets) },
-	{ "tx_broadcast_bytes",
+	{ "tx_vport_broadcast_bytes",
 		VPORT_COUNTER_OFF(transmitted_eth_broadcast.octets) },
 };
 
-- 
1.7.1
