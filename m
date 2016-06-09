From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 01/13] net/mlx5: Fix the size of modify QP mailbox
Date: Fri, 10 Jun 2016 00:07:28 +0300
Message-ID: <1465506460-1854-2-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34416 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752145AbcFIVIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:30 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Add 16 reserved bytes at the end of mlx5_modify_qp_mbox_in to
match the hardware spec definition.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/qp.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 6422102..1532dcf 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -560,6 +560,7 @@ struct mlx5_modify_qp_mbox_in {
 	__be32			optparam;
 	u8			rsvd0[4];
 	struct mlx5_qp_context	ctx;
+	u8			rsvd2[16];
 };
 
 struct mlx5_modify_qp_mbox_out {
-- 
2.8.0
