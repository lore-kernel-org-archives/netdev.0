From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 3/4] net/mlx4_core: Fix misplaced brackets of sizeof
Date: Mon, 28 Aug 2017 16:38:22 +0300
Message-ID: <1503927503-29065-4-git-send-email-tariqt@mellanox.com>
References: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38610 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751208AbdH1NjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 09:39:12 -0400
In-Reply-To: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing the sizeof style usage in the patch cited below,
one brackets misplacement was introduced. Here we fix it.

Fixes: 31975e27a4b5 ("mlx4: sizeof style usage")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index b98698bf75dd..6f57c052053e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -726,7 +726,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 			}
 			memcpy(&priv->mfunc.master.comm_arm_bit_vector,
 			       eqe->event.comm_channel_arm.bit_vec,
-			       sizeof(eqe)->event.comm_channel_arm.bit_vec);
+			       sizeof(eqe->event.comm_channel_arm.bit_vec));
 			queue_work(priv->mfunc.master.comm_wq,
 				   &priv->mfunc.master.comm_work);
 			break;
-- 
1.8.3.1
