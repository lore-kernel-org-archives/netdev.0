From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 1/6] fib: export symbols
Date: Mon,  6 Jul 2015 09:03:15 -0600
Message-ID: <1436195001-4818-2-git-send-email-dsa@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36779 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbbGFPDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:31 -0400
Received: by igrv9 with SMTP id v9so155739547igr.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:31 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is needed for the following VRF driver.

No active code path changes.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_frontend.c | 1 +
 net/ipv4/fib_trie.c     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6bbc54940eb4..974fa51effca 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -108,6 +108,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	hlist_add_head_rcu(&tb->tb_hlist, &net->ipv4.fib_table_hash[h]);
 	return tb;
 }
+EXPORT_SYMBOL_GPL(fib_new_table);
 
 /* caller must hold either rtnl or rcu read lock */
 struct fib_table *fib_get_table(struct net *net, u32 id)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 15d32612e3c6..ac2d828c6daa 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1887,6 +1887,7 @@ void fib_free_table(struct fib_table *tb)
 {
 	call_rcu(&tb->rcu, __trie_free_rcu);
 }
+EXPORT_SYMBOL_GPL(fib_free_table);
 
 static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 			     struct sk_buff *skb, struct netlink_callback *cb)
-- 
2.3.2 (Apple Git-55)
