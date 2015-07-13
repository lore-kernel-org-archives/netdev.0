From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] net: qlcnic: Deletion of unnecessary memset
Date: Mon, 13 Jul 2015 21:51:38 +0200
Message-ID: <fad6a2ad1e78d8e2624903524548f8d806bf1ef0.1436816968.git.christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:52230 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbbGMTwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:52:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to memset memory allocated with vzalloc.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 2f6cc42..7dbab3c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2403,7 +2403,6 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
 			qlcnic_free_tx_rings(adapter);
 			return -ENOMEM;
 		}
-		memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 		tx_ring->cmd_buf_arr = cmd_buf_arr;
 		spin_lock_init(&tx_ring->tx_clean_lock);
 	}
-- 
2.1.4
