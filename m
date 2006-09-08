From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/1] cleanup unnecessary forcedeth printk
Date: Fri, 8 Sep 2006 08:41:48 -0400
Message-ID: <20060908124146.GA8138@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60080 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751003AbWIHMmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 08:42:50 -0400
To: shemminger@osdl.org, aabdulla@nvidia.com, jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This removes unnecessary messages that show up every time I put my
ethernet card in promiscuous mode.  I'm already getting notification
from the networking layer, I don't need notification from the driver as
well.

There are probably other drivers that do this as well -- I'll look
around and see what I can find.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 forcedeth.c |    1 -
 1 files changed, 1 deletion(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2032,7 +2032,6 @@ static void nv_set_multicast(struct net_
 	memset(mask, 0, sizeof(mask));
 
 	if (dev->flags & IFF_PROMISC) {
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n", dev->name);
 		pff |= NVREG_PFF_PROMISC;
 	} else {
 		pff |= NVREG_PFF_MYADDR;
