From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/15] net/mlx5e: Avoid using multiple blank lines
Date: Thu, 17 Aug 2017 16:30:00 +0300
Message-ID: <20170817133003.16900-13-saeedm@mellanox.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47164 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752652AbdHQNaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:18 -0400
In-Reply-To: <20170817133003.16900-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

To fix these checkpatch complaints:

CHECK: Please don't use multiple blank lines

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 31cbe5e86a01..0ef68a7c051e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -802,7 +802,6 @@ static void cmd_work_handler(struct work_struct *work)
 	bool poll_cmd = ent->polling;
 	int alloc_ret;
 
-
 	sem = ent->page_queue ? &cmd->pages_sem : &cmd->sem;
 	down(sem);
 	if (!ent->page_queue) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 7e6e24398926..514c22d21729 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -836,7 +836,6 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 	return -EOPNOTSUPP;
 }
 
-
 static int mlx5_pci_init(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 {
 	struct pci_dev *pdev = dev->pdev;
-- 
2.13.0
