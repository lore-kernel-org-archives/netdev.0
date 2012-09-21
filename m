From: David Miller <davem@davemloft.net>
Subject: [PATCH] sunbmac: Remove unused local variable.
Date: Fri, 21 Sep 2012 15:23:46 -0400 (EDT)
Message-ID: <20120921.152346.215918842698130443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757703Ab2IUTXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:23:48 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5E8925819DF
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 12:23:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit eb716c54b1c71ad28ab20461bff831bd481066c4 ("sunbmac: remove
unnecessary setting of skb->dev") caused the local varible 'dev'
in bigmac_init_rings to become unused.  And now the compiler
warns about it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Noticed while doing some sparc test builds, committed to net-next

 drivers/net/ethernet/sun/sunbmac.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 967fe8c..c9c977b 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -212,7 +212,6 @@ static void bigmac_clean_rings(struct bigmac *bp)
 static void bigmac_init_rings(struct bigmac *bp, int from_irq)
 {
 	struct bmac_init_block *bb = bp->bmac_block;
-	struct net_device *dev = bp->dev;
 	int i;
 	gfp_t gfp_flags = GFP_KERNEL;
 
-- 
1.7.11.4
