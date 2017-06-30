From: Colin King <colin.king@canonical.com>
Subject: [PATCH][-next] net/mlx5: fix spelling mistake: "Allodating" -> "Allocating"
Date: Fri, 30 Jun 2017 11:59:22 +0100
Message-ID: <20170630105922.10397-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Colin Ian King <colin.king@canonical.com>,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in mlx5_core_dbg debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c b/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
index 4d0db481f6c4..de2aed44ab85 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
@@ -101,7 +101,7 @@ int mlx5_core_reserved_gid_alloc(struct mlx5_core_dev *dev, int *gid_index)
 	if (index < 0)
 		return index;
 
-	mlx5_core_dbg(dev, "Allodating reserved GID %u\n", index);
+	mlx5_core_dbg(dev, "Allocating reserved GID %u\n", index);
 	*gid_index = index;
 	return 0;
 }
-- 
2.11.0
