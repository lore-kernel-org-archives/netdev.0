From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 03/16] net/mlx5_core: Coding style fix
Date: Thu,  2 Apr 2015 17:07:21 +0300
Message-ID: <1427983654-971-4-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33811 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDBOHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:47 -0400
Received: by widjs5 with SMTP id js5so10162203wid.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:46 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put a line of space before return and next statement.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 2c0f142cd3ba..859c136911e0 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1162,6 +1162,7 @@ static void destroy_qp_common(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp)
 	in = kzalloc(sizeof(*in), GFP_KERNEL);
 	if (!in)
 		return;
+
 	if (qp->state != IB_QPS_RESET) {
 		mlx5_ib_qp_disable_pagefaults(qp);
 		if (mlx5_core_qp_modify(dev->mdev, to_mlx5_state(qp->state),
-- 
2.3.1
