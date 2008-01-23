From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 1/5] fib_trie: more whitespace cleanup
Date: Wed, 23 Jan 2008 14:48:45 -0800
Message-ID: <20080123224858.767903581@linux-foundation.org>
References: <20080123224844.610730277@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57027 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbYAWXAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 18:00:47 -0500
Content-Disposition: inline; filename=trie-whitespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove extra blank lines.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-22 17:46:28.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 17:50:44.000000000 -0800
@@ -447,7 +447,6 @@ static void tnode_put_child_reorg(struct
 
 	BUG_ON(i >= 1<<tn->bits);
 
-
 	/* update emptyChildren */
 	if (n == NULL && chi != NULL)
 		tn->empty_children++;
@@ -1303,7 +1302,6 @@ err:
 	return err;
 }
 
-
 /* should be called with rcu_read_lock */
 static int check_leaf(struct trie *t, struct leaf *l,
 		      t_key key,  const struct flowi *flp,
@@ -1718,7 +1716,6 @@ static struct leaf *leaf_walk_rcu(struct
 	return NULL; /* Root of trie */
 }
 
-
 static struct leaf *trie_firstleaf(struct trie *t)
 {
 	struct tnode *n = (struct tnode *) rcu_dereference(t->trie);
@@ -1846,7 +1843,6 @@ static int fn_trie_dump_fa(t_key key, in
 {
 	int i, s_i;
 	struct fib_alias *fa;
-
 	__be32 xkey = htonl(key);
 
 	s_i = cb->args[4];
@@ -1879,7 +1875,6 @@ static int fn_trie_dump_fa(t_key key, in
 	return skb->len;
 }
 
-
 static int fn_trie_dump_leaf(struct leaf *l, struct fib_table *tb,
 			struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -2385,7 +2380,6 @@ static int fib_trie_seq_show(struct seq_
 		struct leaf *l = (struct leaf *) n;
 		struct leaf_info *li;
 		struct hlist_node *node;
-
 		__be32 val = htonl(l->key);
 
 		seq_indent(seq, iter->depth);

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

