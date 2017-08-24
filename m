From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 1/8] net/mlx5: Add a blank line after declarations V2
Date: Thu, 24 Aug 2017 16:21:45 +0300
Message-ID: <20170824132152.29538-2-saeedm@mellanox.com>
References: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34085 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753040AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
In-Reply-To: <20170824132152.29538-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The blank line should be after u32 val = ...
and not after __be32 __iomem *addr = ...

Fixes: ad5b39a95c83 ("net/mlx5: Add a blank line after declarations")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reported-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index a08027b8f3ce..02da96f98352 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -188,8 +188,8 @@ static enum mlx5_dev_event port_subtype_event(u8 subtype)
 static void eq_update_ci(struct mlx5_eq *eq, int arm)
 {
 	__be32 __iomem *addr = eq->doorbell + (arm ? 0 : 2);
-
 	u32 val = (eq->cons_index & 0xffffff) | (eq->eqn << 24);
+
 	__raw_writel((__force u32)cpu_to_be32(val), addr);
 	/* We still want ordering, just not swabbing, so add a barrier */
 	mb();
-- 
2.13.0
