From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v3 07/12] net: ethernet: aquantia: Using NETDEV_TX_OK instead 0.
Date: Mon, 20 Feb 2017 14:41:49 +0300
Message-ID: <4fed012e9b550b01378269f28768030150d077df.1487590641.git.pavel.belous@aquantia.com>
References: <cover.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0086.outbound.protection.outlook.com ([104.47.42.86]:47808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752195AbdBTLnE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 06:43:04 -0500
In-Reply-To: <cover.1487590641.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Use NETDEV_TX_OK as the return value for successful transmission.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 646314c..019bcc7 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -568,7 +568,7 @@ __acquires(&ring->lock)
 	unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
 	unsigned int tc = 0U;
 	unsigned int trys = AQ_CFG_LOCK_TRYS;
-	int err = 0;
+	int err = NETDEV_TX_OK;
 	bool is_nic_in_bad_state;
 	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
 
-- 
2.7.4
