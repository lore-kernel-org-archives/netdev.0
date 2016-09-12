From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/5] net/mlx4_en: Fix wrong indentation
Date: Mon, 12 Sep 2016 16:20:13 +0300
Message-ID: <1473686416-11779-3-git-send-email-tariqt@mellanox.com>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53482 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758760AbcILNUp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 09:20:45 -0400
In-Reply-To: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Use tabs instead of spaces before if statement, no functional change.

Fixes: e7c1c2c46201 ("mlx4_en: Added self diagnostics test implementation")
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index bb7ccb109aa4..51fa0aa8a49c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1022,7 +1022,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
-                if (unlikely(priv->validate_loopback)) {
+		if (unlikely(priv->validate_loopback)) {
 			validate_loopback(priv, skb);
 			goto next;
 		}
-- 
1.8.3.1
