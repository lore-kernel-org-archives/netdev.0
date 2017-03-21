From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/8] net/mlx5: Add missing entries for set/query rate limit commands
Date: Tue, 21 Mar 2017 15:59:12 +0200
Message-ID: <20170321135919.25018-2-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38148 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757532AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The switch cases for the rate limit set and query commands were
missing, which could get us wrong under fw error or driver reset
flow, fix that.

Fixes: 1466cc5b23d1 ('net/mlx5: Rate limit tables support')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index caa837e5e2b9..a380353a78c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -361,6 +361,8 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_QUERY_VPORT_COUNTER:
 	case MLX5_CMD_OP_ALLOC_Q_COUNTER:
 	case MLX5_CMD_OP_QUERY_Q_COUNTER:
+	case MLX5_CMD_OP_SET_RATE_LIMIT:
+	case MLX5_CMD_OP_QUERY_RATE_LIMIT:
 	case MLX5_CMD_OP_ALLOC_PD:
 	case MLX5_CMD_OP_ALLOC_UAR:
 	case MLX5_CMD_OP_CONFIG_INT_MODERATION:
@@ -497,6 +499,8 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(ALLOC_Q_COUNTER);
 	MLX5_COMMAND_STR_CASE(DEALLOC_Q_COUNTER);
 	MLX5_COMMAND_STR_CASE(QUERY_Q_COUNTER);
+	MLX5_COMMAND_STR_CASE(SET_RATE_LIMIT);
+	MLX5_COMMAND_STR_CASE(QUERY_RATE_LIMIT);
 	MLX5_COMMAND_STR_CASE(ALLOC_PD);
 	MLX5_COMMAND_STR_CASE(DEALLOC_PD);
 	MLX5_COMMAND_STR_CASE(ALLOC_UAR);
-- 
2.11.0
