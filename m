From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 4/5] net: mvpp2: remove unused mvpp2_bm_cookie_pool_set() function
Date: Thu,  8 Jun 2017 17:27:26 +0200
Message-ID: <1496935647-29670-5-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34630 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751915AbdFHP2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:28:11 -0400
In-Reply-To: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is not used in the driver, remove it.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 037f6bd..4ca1639 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3907,17 +3907,6 @@ static void *mvpp2_buf_alloc(struct mvpp2_port *port,
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
2.7.4
