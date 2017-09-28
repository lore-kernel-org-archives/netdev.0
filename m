From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 11/11] net/mlx5: Fix wrong indentation in enable SRIOV code
Date: Thu, 28 Sep 2017 07:41:32 +0300
Message-ID: <20170928044132.30940-12-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54422 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751770AbdI1EmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:06 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Smatch is screaming:

drivers/net/ethernet/mellanox/mlx5/core/sriov.c:112
	mlx5_device_enable_sriov() warn: inconsistent indenting

fix that.

Fixes: 7ecf6d8ff154 ('IB/mlx5: Restore IB guid/policy for virtual functions')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index 6c48e9959b65..2a8b529ce6dd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -109,7 +109,7 @@ static int mlx5_device_enable_sriov(struct mlx5_core_dev *dev, int num_vfs)
 				mlx5_core_warn(dev,
 					       "failed to restore VF %d settings, err %d\n",
 					       vf, err);
-			continue;
+				continue;
 			}
 		}
 		mlx5_core_dbg(dev, "successfully enabled VF* %d\n", vf);
-- 
2.13.0
