From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix kernel-doc for sk_filter_rcu_release
Date: Thu, 18 Nov 2010 15:02:37 -0800
Message-ID: <20101118150237.1f0ba4b5.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:33674 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760814Ab0KRXD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 18:03:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc warning for sk_filter_rcu_release():

Warning(net/core/filter.c:586): missing initial short description on line:
 * 	sk_filter_rcu_release: Release a socket filter by rcu_head

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc:	"David S. Miller" <davem@davemloft.net>
Cc:	netdev@vger.kernel.org
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-2637-r2g4-kerndoc.orig/net/core/filter.c
+++ lnx-2637-r2g4-kerndoc/net/core/filter.c
@@ -589,7 +589,7 @@ int sk_chk_filter(struct sock_filter *fi
 EXPORT_SYMBOL(sk_chk_filter);
 
 /**
- * 	sk_filter_rcu_release: Release a socket filter by rcu_head
+ * 	sk_filter_rcu_release - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
  */
 static void sk_filter_rcu_release(struct rcu_head *rcu)
