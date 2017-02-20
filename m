From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 01/12] net: ethernet: aquantia: Removed extra assignment for skb->dev.
Date: Mon, 20 Feb 2017 22:36:39 +0300
Message-ID: <180874ad8845c295c6744bd7f77864fa6bec26b8.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0049.outbound.protection.outlook.com ([104.47.38.49]:6446
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751362AbdBTThe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:37:34 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This assignment is not needed.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index fed6ac5..22bb75e 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -209,7 +209,6 @@ int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
 				goto err_exit;
 			}
 
-			skb->dev = ndev;
 			skb_put(skb, buff->len);
 		} else {
 			skb = netdev_alloc_skb(ndev, ETH_HLEN);
-- 
2.7.4
