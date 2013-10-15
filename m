From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/4] net/mlx4: Unused local variable in mlx4_opreq_action
Date: Tue, 15 Oct 2013 16:55:23 +0200
Message-ID: <1381848924-18992-4-git-send-email-amirv@mellanox.com>
References: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60352 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933174Ab3JOO4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:56:02 -0400
In-Reply-To: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up warning added by commit fe6f700d "net/mlx4_core: Respond to
operation request by firmware".

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index a377484..c151e7a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1713,7 +1713,6 @@ void mlx4_opreq_action(struct work_struct *work)
 	u32 *outbox;
 	u32 modifier;
 	u16 token;
-	u16 type_m;
 	u16 type;
 	int err;
 	u32 num_qps;
@@ -1746,7 +1745,6 @@ void mlx4_opreq_action(struct work_struct *work)
 		MLX4_GET(modifier, outbox, GET_OP_REQ_MODIFIER_OFFSET);
 		MLX4_GET(token, outbox, GET_OP_REQ_TOKEN_OFFSET);
 		MLX4_GET(type, outbox, GET_OP_REQ_TYPE_OFFSET);
-		type_m = type >> 12;
 		type &= 0xfff;
 
 		switch (type) {
-- 
1.8.3.4
