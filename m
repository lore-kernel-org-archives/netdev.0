From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V2 01/11] net/mlx5: Fix offset naming for reserved fields in hca_cap_bits
Date: Mon,  2 Jan 2017 11:37:38 +0200
Message-ID: <1483349868-11716-2-git-send-email-saeedm@mellanox.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483349868-11716-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Fix offset for reserved fields.

Fixes: 7486216b3a0b ("{net,IB}/mlx5: mlx5_ifc updates")
Fixes: b4ff3a36d3e4 ("net/mlx5: Use offset based reserved field names in the IFC header file")
Fixes: 7d5e14237a55 ("net/mlx5: Update mlx5_ifc hardware features")
Signed-off-by: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
