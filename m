From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/24] 802: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:20 -0700
Message-ID: <8133703b16f472d3814cd4d27983d1ed2d7bc4eb.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44586 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754863Ab1H2VSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 17:18:32 -0400
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/802/tr.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/802/tr.c b/net/802/tr.c
index 5e20cf8..94cb725 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -382,7 +382,6 @@ static void tr_add_rif_info(struct trh_hdr *trh, struct net_device *dev)
 
 		if(!entry)
 		{
-			printk(KERN_DEBUG "tr.c: Couldn't malloc rif cache entry !\n");
 			spin_unlock_irqrestore(&rif_lock, flags);
 			return;
 		}
-- 
1.7.6.405.gc1be0
