From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 7/8] net/mlx5_core: Remove static from local variable
Date: Fri, 22 Apr 2016 00:33:06 +0300
Message-ID: <1461274387-10653-8-git-send-email-saeedm@mellanox.com>
References: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60201 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752349AbcDUVeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 17:34:07 -0400
In-Reply-To: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

The static is not required and breaks re-entrancy if it will be required.

Fixes: 2530236303d9 ("net/mlx5_core: Flow steering tree initialization")
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 3c7e3e5..89cce97 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1276,7 +1276,7 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 {
 	struct mlx5_flow_root_namespace *root_ns = dev->priv.root_ns;
 	int prio;
-	static struct fs_prio *fs_prio;
+	struct fs_prio *fs_prio;
 	struct mlx5_flow_namespace *ns;
 
 	if (!root_ns)
-- 
1.7.1
