From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 03/15] net/mlx5: Ensure SRQ physical address structure endianness
Date: Sun, 30 Oct 2016 23:21:56 +0200
Message-ID: <1477862528-4328-4-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60303 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756780AbcJ3VXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:23:45 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

SRQ physical address structure field should be in big-endian format.

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/srq.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx5/srq.h b/include/linux/mlx5/srq.h
index 33c97dc..1cde0fd 100644
--- a/include/linux/mlx5/srq.h
+++ b/include/linux/mlx5/srq.h
@@ -55,7 +55,7 @@ struct mlx5_srq_attr {
 	u32 lwm;
 	u32 user_index;
 	u64 db_record;
-	u64 *pas;
+	__be64 *pas;
 };
 
 struct mlx5_core_dev;
-- 
2.7.4
