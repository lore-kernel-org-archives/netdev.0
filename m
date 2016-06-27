From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/7] net/mlx5: Update command strings
Date: Mon, 27 Jun 2016 12:08:32 +0300
Message-ID: <1467018518-11630-2-git-send-email-saeedm@mellanox.com>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53196 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751885AbcF0JQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:13 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Add command string for MODIFY_FLOW_TABLE which is used by the driver.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index dcd2df6..0b49862 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -545,6 +545,7 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(ALLOC_FLOW_COUNTER);
 	MLX5_COMMAND_STR_CASE(DEALLOC_FLOW_COUNTER);
 	MLX5_COMMAND_STR_CASE(QUERY_FLOW_COUNTER);
+	MLX5_COMMAND_STR_CASE(MODIFY_FLOW_TABLE);
 	default: return "unknown command opcode";
 	}
 }
-- 
2.8.0
