From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 3/8] net/mlx4_core: Change SYNC_TPT to be native (not wrapped)
Date: Tue, 15 May 2012 23:34:59 +0300
Message-ID: <1337114104-26094-4-git-send-email-ogerlitz@mellanox.com>
References: <1337114104-26094-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:45028 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933334Ab2EOUfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 16:35:15 -0400
In-Reply-To: <1337114104-26094-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The "wrapped" was incorrect, since no wrapper function was defined.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index cefa76f..af55b7c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -892,6 +892,6 @@ EXPORT_SYMBOL_GPL(mlx4_fmr_free);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev)
 {
 	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_SYNC_TPT, 1000,
-			MLX4_CMD_WRAPPED);
+			MLX4_CMD_NATIVE);
 }
 EXPORT_SYMBOL_GPL(mlx4_SYNC_TPT);
-- 
1.7.1
