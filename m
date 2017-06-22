From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 2/3] net: mvpp2: remove unused mvpp2_bm_cookie_pool_set() function
Date: Thu, 22 Jun 2017 14:23:19 +0200
Message-ID: <20170622122320.32676-3-thomas.petazzoni@free-electrons.com>
References: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38159 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdFVMXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 08:23:39 -0400
In-Reply-To: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is not used in the driver, remove it.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4b3bf37..aad763c 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3917,17 +3917,6 @@ static void *mvpp2_buf_alloc(struct mvpp2_port *port,
 	return data;
 }
 
-/* Set pool number in a BM cookie */
-static inline u32 mvpp2_bm_cookie_pool_set(u32 cookie, int pool)
-{
-	u32 bm;
-
-	bm = cookie & ~(0xFF << MVPP2_BM_COOKIE_POOL_OFFS);
-	bm |= ((pool & 0xFF) << MVPP2_BM_COOKIE_POOL_OFFS);
-
-	return bm;
-}
-
 /* Release buffer to BM */
 static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 				     dma_addr_t buf_dma_addr,
-- 
2.9.4
