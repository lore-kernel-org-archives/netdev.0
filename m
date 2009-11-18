From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 11/16] drivers/net/via-velocity.c: remove exceptional & on
 function name
Date: Wed, 18 Nov 2009 19:24:13 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181923540.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	arnd@arndb.de, joe@perches.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:56402 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932248AbZKRSYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:24:09 -0500
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
 drivers/net/via-velocity.c          |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 158f411..1e6b395 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2176,7 +2176,7 @@ static int velocity_open(struct net_device *dev)
 
 	velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
-	ret = request_irq(vptr->pdev->irq, &velocity_intr, IRQF_SHARED,
+	ret = request_irq(vptr->pdev->irq, velocity_intr, IRQF_SHARED,
 			  dev->name, dev);
 	if (ret < 0) {
 		/* Power down the chip */
