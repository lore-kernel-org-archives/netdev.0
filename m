From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/15] net/mlx5: Avoid space after casting
Date: Fri, 16 Jun 2017 00:42:43 +0300
Message-ID: <20170615214252.30140-7-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32929 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752155AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fix checkpatch complaints on that:

 CHECK: No space is necessary after a cast

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 43b279b01e07..af51a5d2b912 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -191,7 +191,7 @@ static void eq_update_ci(struct mlx5_eq *eq, int arm)
 {
 	__be32 __iomem *addr = eq->doorbell + (arm ? 0 : 2);
 	u32 val = (eq->cons_index & 0xffffff) | (eq->eqn << 24);
-	__raw_writel((__force u32) cpu_to_be32(val), addr);
+	__raw_writel((__force u32)cpu_to_be32(val), addr);
 	/* We still want ordering, just not swabbing, so add a barrier */
 	mb();
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 877395f34e89..b8030b5707a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -1093,7 +1093,7 @@ int mlx5_devlink_eswitch_encap_mode_set(struct devlink *devlink, u8 encap)
 	if (err) {
 		esw_warn(esw->dev, "Failed re-creating fast FDB table, err %d\n", err);
 		esw->offloads.encap = !encap;
-		(void) esw_create_offloads_fast_fdb_table(esw);
+		(void)esw_create_offloads_fast_fdb_table(esw);
 	}
 	return err;
 }
-- 
2.11.0
