From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 15/18] net/mlx5: Introduce sniffer steering hardware capabilities
Date: Fri, 17 Jun 2016 17:43:56 +0300
Message-ID: <1466174639-14576-16-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57706 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752776AbcFQOtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:49:18 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Define needed hardware capabilities needed for sniffer
RX and TX flow tables.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/device.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index a90f85b..c286cf1 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1378,6 +1378,18 @@ enum mlx5_cap_type {
 #define MLX5_CAP_FLOWTABLE_NIC_RX_MAX(mdev, cap) \
 	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_receive.cap)
 
+#define MLX5_CAP_FLOWTABLE_SNIFFER_RX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive_sniffer.cap)
+
+#define MLX5_CAP_FLOWTABLE_SNIFFER_RX_MAX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_receive_sniffer.cap)
+
+#define MLX5_CAP_FLOWTABLE_SNIFFER_TX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_transmit_sniffer.cap)
+
+#define MLX5_CAP_FLOWTABLE_SNIFFER_TX_MAX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_transmit_sniffer.cap)
+
 #define MLX5_CAP_ESW_FLOWTABLE(mdev, cap) \
 	MLX5_GET(flow_table_eswitch_cap, \
 		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
-- 
2.8.0
