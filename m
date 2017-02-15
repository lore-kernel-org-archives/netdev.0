From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 07/13] net: ethernet: aquantia: Using NETDEV_TX_OK instead 0.
Date: Wed, 15 Feb 2017 23:01:15 +0300
Message-ID: <1b6f2fe681fd1b540a55c879c258a31bdea6e0e1.1487187192.git.pavel.belous@aquantia.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0063.outbound.protection.outlook.com ([104.47.40.63]:44304
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751751AbdBOUDi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:03:38 -0500
In-Reply-To: <cover.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Use NETDEV_TX_OK as the return value for successful transmission.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 1bf5975..4cf633c 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -567,7 +567,7 @@ __acquires(&ring->lock)
 	unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
 	unsigned int tc = 0U;
 	unsigned int trys = AQ_CFG_LOCK_TRYS;
-	int err = 0;
+	int err = NETDEV_TX_OK;
 	bool is_nic_in_bad_state;
 	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
 
-- 
2.7.4
