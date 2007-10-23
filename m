From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 7/12] eexpress: fix !SMP unused-var warning
Date: Tue, 23 Oct 2007 18:36:42 -0400 (EDT)
Message-ID: <20071023223642.0BACC1F81B2@havoc.gtf.org>
References: <tueoct232007613pm.likjasfdlkjdas987@havoc.gtf.org>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:44184 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754177AbXJWWgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 18:36:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 9c85e50..70509ed 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -651,9 +651,9 @@ static void eexp_timeout(struct net_device *dev)
  */
 static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	short length = buf->len;
 #ifdef CONFIG_SMP
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 #endif
 
