From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] [IPV4] Thresholds in fib_trie.c are used as consts,
	so make them const.
Date: Thu, 13 Dec 2007 11:06:18 +0300
Message-ID: <20071213080618.GA6530@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:50604 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752741AbXLMIEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 03:04:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPV4] Thresholds in fib_trie.c are used as consts, so make them const.

There are several thresholds for trie fib hash management. They are used
in the code as a constants. Make them constants from the compiler point of
view.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -299,10 +299,10 @@ static inline void check_tnode(const struct tnode *tn)
 	WARN_ON(tn && tn->pos+tn->bits > 32);
 }
 
-static int halve_threshold = 25;
-static int inflate_threshold = 50;
-static int halve_threshold_root = 8;
-static int inflate_threshold_root = 15;
+static const int halve_threshold = 25;
+static const int inflate_threshold = 50;
+static const int halve_threshold_root = 8;
+static const int inflate_threshold_root = 15;
 
 
 static void __alias_free_mem(struct rcu_head *head)
