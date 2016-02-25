From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/10] net/mlx5: Make command timeout way shorter
Date: Thu, 25 Feb 2016 18:33:18 +0200
Message-ID: <1456418000-18898-9-git-send-email-saeedm@mellanox.com>
References: <1456418000-18898-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57262 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933216AbcBYQeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 11:34:23 -0500
In-Reply-To: <1456418000-18898-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The command timeout is terribly long, whole two hours. Make it 60s so if
things do go wrong, the user gets feedback in relatively short time, so
they can take corrective actions and/or investigate using tools and such.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/driver.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index a815da9..3388a43 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -54,7 +54,7 @@ enum {
 	/* one minute for the sake of bringup. Generally, commands must always
 	 * complete and we may need to increase this timeout value
 	 */
-	MLX5_CMD_TIMEOUT_MSEC	= 7200 * 1000,
+	MLX5_CMD_TIMEOUT_MSEC	= 60 * 1000,
 	MLX5_CMD_WQ_MAX_NAME	= 32,
 };
 
-- 
1.7.1
