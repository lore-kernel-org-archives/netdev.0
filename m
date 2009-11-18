From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 10/16] drivers/net/via-rhine.c: remove exceptional & on
 function name
Date: Wed, 18 Nov 2009 19:23:53 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181923340.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	arnd@arndb.de, joe@perches.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:45547 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932225AbZKRSXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:23:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/via-rhine.c             |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 4535e89..ec94ddf 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1150,7 +1150,7 @@ static int rhine_open(struct net_device *dev)
 	void __iomem *ioaddr = rp->base;
 	int rc;
 
-	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
+	rc = request_irq(rp->pdev->irq, rhine_interrupt, IRQF_SHARED, dev->name,
 			dev);
 	if (rc)
 		return rc;
