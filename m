From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 06/16] net/mlx5_core: Use the right inbox struct in destroy mkey command
Date: Thu,  2 Apr 2015 17:07:24 +0300
Message-ID: <1427983654-971-7-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35472 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbDBOH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:58 -0400
Received: by wgdm6 with SMTP id m6so86622623wgd.2
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:57 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

struct mlx5_query_mkey_mbox_in rather than mlx5_destroy_mkey_mbox_in

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/mr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mr.c b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
index 184c3615f479..1a9b75139c2d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
@@ -141,7 +141,7 @@ EXPORT_SYMBOL(mlx5_core_destroy_mkey);
 int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
 			 struct mlx5_query_mkey_mbox_out *out, int outlen)
 {
-	struct mlx5_destroy_mkey_mbox_in in;
+	struct mlx5_query_mkey_mbox_in in;
 	int err;
 
 	memset(&in, 0, sizeof(in));
-- 
2.3.1
