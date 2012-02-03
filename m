From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] mlx4: Fix typo in cmd.c
Date: Fri,  3 Feb 2012 22:27:38 +0900
Message-ID: <1328275658-1982-1-git-send-email-standby24x7@gmail.com>
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	standby24x7@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling "reseting" to "resetting" in
drivers/net/ethernet/mellanox/mlx4/cmd.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 405e6ac..1831dde 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1314,7 +1314,7 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 		down(&priv->cmd.slave_sem);
 		if (mlx4_master_process_vhcr(dev, slave, NULL)) {
 			mlx4_err(dev, "Failed processing vhcr for slave:%d,"
-				 " reseting slave.\n", slave);
+				 " resetting slave.\n", slave);
 			up(&priv->cmd.slave_sem);
 			goto reset_slave;
 		}
-- 
1.7.6.5
