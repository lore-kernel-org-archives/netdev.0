From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5e: Expose RDMA VPort counters to ethtool
Date: Mon,  4 Jul 2016 17:23:11 +0300
Message-ID: <1467642192-28259-8-git-send-email-saeedm@mellanox.com>
References: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54703 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751424AbcGDOX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 10:23:56 -0400
In-Reply-To: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add the needed descriptors to expose RoCE RDMA counters.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index fcd490c..ae29998 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -151,6 +151,22 @@ static const struct counter_desc vport_stats_desc[] = {
 		VPORT_COUNTER_OFF(transmitted_eth_broadcast.packets) },
 	{ "tx_vport_broadcast_bytes",
 		VPORT_COUNTER_OFF(transmitted_eth_broadcast.octets) },
+	{ "rx_vport_rdma_unicast_packets",
+		VPORT_COUNTER_OFF(received_ib_unicast.packets) },
+	{ "rx_vport_rdma_unicast_bytes",
+		VPORT_COUNTER_OFF(received_ib_unicast.octets) },
+	{ "tx_vport_rdma_unicast_packets",
+		VPORT_COUNTER_OFF(transmitted_ib_unicast.packets) },
+	{ "tx_vport_rdma_unicast_bytes",
+		VPORT_COUNTER_OFF(transmitted_ib_unicast.octets) },
+	{ "rx_vport_rdma_multicast_packets",
+		VPORT_COUNTER_OFF(received_ib_multicast.packets) },
+	{ "rx_vport_rdma_multicast_bytes",
+		VPORT_COUNTER_OFF(received_ib_multicast.octets) },
+	{ "tx_vport_rdma_multicast_packets",
+		VPORT_COUNTER_OFF(transmitted_ib_multicast.packets) },
+	{ "tx_vport_rdma_multicast_bytes",
+		VPORT_COUNTER_OFF(transmitted_ib_multicast.octets) },
 };
 
 #define PPORT_802_3_OFF(c) \
-- 
2.8.0
