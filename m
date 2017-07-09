From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/7] net/mlx5: FPGA, make mlx5_fpga_device_brb static
Date: Sun,  9 Jul 2017 15:49:13 +0300
Message-ID: <20170709124917.12852-4-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36236 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752149AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Fix warning when building with -Wall:
drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c:105:5: warning: symbol 'mlx5_fpga_device_brb' was not declared. Should it be static?

Fixes: c43051d72a8d ("net/mlx5: FPGA, Add SBU bypass and reset flows")
Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
index 31e5a2627eb8..9034e9960a76 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
@@ -102,7 +102,7 @@ static int mlx5_fpga_device_load_check(struct mlx5_fpga_device *fdev)
 	return 0;
 }
 
-int mlx5_fpga_device_brb(struct mlx5_fpga_device *fdev)
+static int mlx5_fpga_device_brb(struct mlx5_fpga_device *fdev)
 {
 	int err;
 	struct mlx5_core_dev *mdev = fdev->mdev;
-- 
2.11.0
