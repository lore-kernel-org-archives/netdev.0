From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/15] net/mlx5: Fix some spelling mistakes
Date: Fri, 16 Jun 2017 00:42:39 +0300
Message-ID: <20170615214252.30140-3-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32909 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752070AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fixed few places where endianness was misspelled and
one spot whwere output was:

CHECK: 'endianess' may be misspelled - perhaps 'endianness'?
CHECK: 'ouput' may be misspelled - perhaps 'output'?

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 10 +++++-----
 include/linux/mlx5/mlx5_ifc.h                  |  4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 852a6a75db98..2ab505d1e8e3 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -439,7 +439,7 @@ static void get_atomic_caps(struct mlx5_ib_dev *dev,
 	u8 atomic_operations = MLX5_CAP_ATOMIC(dev->mdev, atomic_operations);
 	u8 atomic_size_qp = MLX5_CAP_ATOMIC(dev->mdev, atomic_size_qp);
 	u8 atomic_req_8B_endianness_mode =
-		MLX5_CAP_ATOMIC(dev->mdev, atomic_req_8B_endianess_mode);
+		MLX5_CAP_ATOMIC(dev->mdev, atomic_req_8B_endianness_mode);
 
 	/* Check if HW supports 8 bytes standard atomic operations and capable
 	 * of host endianness respond
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 10d282841f5b..46efaab9da46 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -874,7 +874,7 @@ static const char *deliv_status_to_str(u8 status)
 	case MLX5_CMD_DELIVERY_STAT_IN_LENGTH_ERR:
 		return "command input length error";
 	case MLX5_CMD_DELIVERY_STAT_OUT_LENGTH_ERR:
-		return "command ouput length error";
+		return "command output length error";
 	case MLX5_CMD_DELIVERY_STAT_RES_FLD_NOT_CLR_ERR:
 		return "reserved fields not cleared";
 	case MLX5_CMD_DELIVERY_STAT_CMD_DESCR_ERR:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index dc890944c4ea..3319968ed789 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -356,7 +356,7 @@ static void mlx5_disable_msix(struct mlx5_core_dev *dev)
 	kfree(priv->msix_arr);
 }
 
-struct mlx5_reg_host_endianess {
+struct mlx5_reg_host_endianness {
 	u8	he;
 	u8      rsvd[15];
 };
@@ -475,7 +475,7 @@ static int handle_hca_cap_atomic(struct mlx5_core_dev *dev)
 
 	req_endianness =
 		MLX5_CAP_ATOMIC(dev,
-				supported_atomic_req_8B_endianess_mode_1);
+				supported_atomic_req_8B_endianness_mode_1);
 
 	if (req_endianness != MLX5_ATOMIC_REQ_MODE_HOST_ENDIANNESS)
 		return 0;
@@ -487,7 +487,7 @@ static int handle_hca_cap_atomic(struct mlx5_core_dev *dev)
 	set_hca_cap = MLX5_ADDR_OF(set_hca_cap_in, set_ctx, capability);
 
 	/* Set requestor to host endianness */
-	MLX5_SET(atomic_caps, set_hca_cap, atomic_req_8B_endianess_mode,
+	MLX5_SET(atomic_caps, set_hca_cap, atomic_req_8B_endianness_mode,
 		 MLX5_ATOMIC_REQ_MODE_HOST_ENDIANNESS);
 
 	err = set_caps(dev, set_ctx, set_sz, MLX5_SET_HCA_CAP_OP_MOD_ATOMIC);
@@ -562,8 +562,8 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 
 static int set_hca_ctrl(struct mlx5_core_dev *dev)
 {
-	struct mlx5_reg_host_endianess he_in;
-	struct mlx5_reg_host_endianess he_out;
+	struct mlx5_reg_host_endianness he_in;
+	struct mlx5_reg_host_endianness he_out;
 	int err;
 
 	if (!mlx5_core_is_pf(dev))
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 32b044e953d2..1fd144662491 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -661,9 +661,9 @@ enum {
 struct mlx5_ifc_atomic_caps_bits {
 	u8         reserved_at_0[0x40];
 
-	u8         atomic_req_8B_endianess_mode[0x2];
+	u8         atomic_req_8B_endianness_mode[0x2];
 	u8         reserved_at_42[0x4];
-	u8         supported_atomic_req_8B_endianess_mode_1[0x1];
+	u8         supported_atomic_req_8B_endianness_mode_1[0x1];
 
 	u8         reserved_at_47[0x19];
 
-- 
2.11.0
