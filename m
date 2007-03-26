From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] fib_hash removal
Date: Mon, 26 Mar 2007 11:29:04 +0200
Message-ID: <17927.37472.985236.813925@robur.slu.se>
References: <17914.36807.643615.571195@robur.slu.se>
	<20070316154839.GA3626@linux.vnet.ibm.com>
	<17919.51605.319758.456896@robur.slu.se>
	<20070320160023.GB3577@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <Robert.Olsson@data.slu.se>
To: paulmck@linux.vnet.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:49461 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559AbXCZJja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 05:39:30 -0400
In-Reply-To: <20070320160023.GB3577@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Paul E. McKenney writes:

 > Those of use who dive into networking only occasionally would much
 > appreciate this.  ;-)

 No problem here... 

 Cheers
					--ro

Acked-by: Robert Olsson <robert.olsson@its.uu.se>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com> (but trivial)


diff -urpNa -X dontdiff linux-2.6.20/net/ipv4/fib_trie.c linux-2.6.20-fn_trie_RTNL/net/ipv4/fib_trie.c
--- linux-2.6.20/net/ipv4/fib_trie.c	2007-02-04 10:44:54.000000000 -0800
+++ linux-2.6.20-fn_trie_RTNL/net/ipv4/fib_trie.c	2007-03-20 08:13:59.000000000 -0700
@@ -1124,6 +1124,9 @@ err:
 	return fa_head;
 }
 
+/*
+ * Caller must hold RTNL.
+ */
 static int fn_trie_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
@@ -1543,6 +1546,9 @@ static int trie_leaf_remove(struct trie 
 	return 1;
 }
 
+/*
+ * Caller must hold RTNL.
+ */
 static int fn_trie_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
@@ -1721,6 +1727,9 @@ up:
 	return NULL; /* Ready. Root of trie */
 }
 
+/*
+ * Caller must hold RTNL.
+ */
 static int fn_trie_flush(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *) tb->tb_data;

