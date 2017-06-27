From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH][V2] net/mlx4: fix spelling mistake: "enforcment" -> "enforcement"
Date: Tue, 27 Jun 2017 11:36:49 +0100
Message-ID: <20170627103649.16619-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Trivial fix to spelling mistake in mlx4_dbg debug message

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index c1af47e45d3f..9e4c142c7ecd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -3280,7 +3280,7 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
 
 	if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
 		mlx4_dbg(dev,
-			 "updating vf %d port %d no link state HW enforcment\n",
+			 "updating vf %d port %d no link state HW enforcement\n",
 			 vf, port);
 	return 0;
 }
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
