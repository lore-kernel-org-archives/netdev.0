From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5_core: Fix wrong name in struct
Date: Fri, 25 Sep 2015 10:49:15 +0300
Message-ID: <1443167356-32095-8-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39328 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753443AbbIYHuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:50:03 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

The name refers to syndrome so uset ext_synd instread of ext_sync.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 2 +-
 include/linux/mlx5/device.h                      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 292d76f..6e69de0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -130,7 +130,7 @@ static void print_health_info(struct mlx5_core_dev *dev)
 	pr_info("hw_id 0x%08x\n", read_be32(&h->hw_id));
 	pr_info("irisc_index %d\n", readb(&h->irisc_index));
 	pr_info("synd 0x%x: %s\n", readb(&h->synd), hsynd_str(readb(&h->synd)));
-	pr_info("ext_sync 0x%04x\n", read_be16(&h->ext_sync));
+	pr_info("ext_sync 0x%04x\n", read_be16(&h->ext_synd));
 }
 
 static void poll_health(unsigned long data)
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 8eb3b19..41e9f3b 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -440,7 +440,7 @@ struct health_buffer {
 	__be32		rsvd2;
 	u8		irisc_index;
 	u8		synd;
-	__be16		ext_sync;
+	__be16		ext_synd;
 };
 
 struct mlx5_init_seg {
-- 
2.3.7
