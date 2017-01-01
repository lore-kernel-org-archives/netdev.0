From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 01/11] net/mlx5: Fix offset naming for reserved fields in hca_cap_bits
Date: Sun,  1 Jan 2017 23:10:17 +0200
Message-ID: <1483305027-2573-2-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Max Gurtovoy <maxg@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42837 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932354AbdAAVKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 16:10:50 -0500
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Gurtovoy <maxg@mellanox.com>

Fix offset for reserved fields.

Fixes: 7486216b3a0b ("{net,IB}/mlx5: mlx5_ifc updates")
Fixes: b4ff3a36d3e4 ("net/mlx5: Use offset based reserved field names in the IFC header file")
Fixes: 7d5e14237a55 ("net/mlx5: Update mlx5_ifc hardware features")
Signed-off-by: Max Gurtovoy <maxg@mellanox.com>
Reviewed-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 57bec54..4792c85 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -826,9 +826,9 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_at_1a9[0x2];
 	u8         local_ca_ack_delay[0x5];
 	u8         port_module_event[0x1];
-	u8         reserved_at_1b0[0x1];
+	u8         reserved_at_1b1[0x1];
 	u8         ports_check[0x1];
-	u8         reserved_at_1b2[0x1];
+	u8         reserved_at_1b3[0x1];
 	u8         disable_link_up[0x1];
 	u8         beacon_led[0x1];
 	u8         port_type[0x2];
@@ -858,7 +858,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 
 	u8         compact_address_vector[0x1];
 	u8         striding_rq[0x1];
-	u8         reserved_at_201[0x2];
+	u8         reserved_at_202[0x2];
 	u8         ipoib_basic_offloads[0x1];
 	u8         reserved_at_205[0xa];
 	u8         drain_sigerr[0x1];
@@ -1009,10 +1009,10 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         rndv_offload_rc[0x1];
 	u8         rndv_offload_dc[0x1];
 	u8         log_tag_matching_list_sz[0x5];
-	u8         reserved_at_5e8[0x3];
+	u8         reserved_at_5f8[0x3];
 	u8         log_max_xrq[0x5];
 
-	u8         reserved_at_5f0[0x200];
+	u8         reserved_at_600[0x200];
 };
 
 enum mlx5_flow_destination_type {
-- 
2.7.4
