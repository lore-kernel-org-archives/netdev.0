From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 09/10] drivers/net/hp-plus.c: fix build error
Date: Mon, 22 Sep 2008 14:10:24 -0700
Message-ID: <200809222110.m8MLAOQQ029900@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42482 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753104AbYIVVOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:14:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix hp-plus build error (yet again; will it ever end?):

hp-plus.c:(.init.text+0xa2cd): undefined reference to `NS8390p_init'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hp-plus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/hp-plus.c~drivers-net-hp-plusc-fix-build-error drivers/net/hp-plus.c
--- a/drivers/net/hp-plus.c~drivers-net-hp-plusc-fix-build-error
+++ a/drivers/net/hp-plus.c
@@ -262,7 +262,7 @@ static int __init hpp_probe1(struct net_
 	}
 
 	outw(Perf_Page, ioaddr + HP_PAGING);
-	NS8390p_init(dev, 0);
+	NS8390_init(dev, 0);
 	/* Leave the 8390 and HP chip reset. */
 	outw(inw(ioaddr + HPP_OPTION) & ~EnableIRQ, ioaddr + HPP_OPTION);
 
_
