From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 2/5] fib_trie: remove unneeded NULL check
Date: Wed, 23 Jan 2008 14:48:46 -0800
Message-ID: <20080123224858.844259513@linux-foundation.org>
References: <20080123224844.610730277@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57031 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbYAWXAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 18:00:47 -0500
Content-Disposition: inline; filename=trie-already-hlist.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since fib_route_seq_show now uses hlist_for_each_entry(), the
leaf info can not be NULL.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-22 17:50:44.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 17:50:58.000000000 -0800
@@ -2474,9 +2474,6 @@ static int fib_route_seq_show(struct seq
 		struct fib_alias *fa;
 		__be32 mask, prefix;
 
-		if (!li)
-			continue;
-
 		mask = inet_make_mask(li->plen);
 		prefix = htonl(l->key);
 

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

