From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/5] net/mlx5: Fix typo in mlx5_query_port_pvlc
Date: Thu,  8 Oct 2015 15:26:17 +0300
Message-ID: <1444307179-16105-4-git-send-email-ogerlitz@mellanox.com>
References: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57468 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756723AbbJHM1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 08:27:02 -0400
In-Reply-To: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

We used the wrong register name for querying the PVLC register

Fixes: a124d13ef59e ('net/mlx5_core: Add more query port helpers')
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 821caaa..3b9480f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -311,7 +311,7 @@ static int mlx5_query_port_pvlc(struct mlx5_core_dev *dev, u32 *pvlc,
 	int err;
 
 	memset(in, 0, sizeof(in));
-	MLX5_SET(ptys_reg, in, local_port, local_port);
+	MLX5_SET(pvlc_reg, in, local_port, local_port);
 
 	err = mlx5_core_access_reg(dev, in, sizeof(in), pvlc,
 				   pvlc_size, MLX5_REG_PVLC, 0, 0);
-- 
2.3.7
