From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: [PATCH] ipv4: fix debug info in tnode_new
Date: Sun, 29 Jul 2012 19:19:55 +0800
Message-ID: <1343560795.5975.1.camel@monkey32>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:48878 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab2G2LUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 07:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should print size of struct rt_trie_node * allocated instead of size
of struct rt_trie_node.

Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
---
 net/ipv4/fib_trie.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 18cbc15..2a6fdc2 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -473,7 +473,7 @@ static struct tnode *tnode_new(t_key key, int pos, int bits)
 	}
 
 	pr_debug("AT %p s=%zu %zu\n", tn, sizeof(struct tnode),
-		 sizeof(struct rt_trie_node) << bits);
+		 sizeof(struct rt_trie_node *) << bits);
 	return tn;
 }
 
-- 
1.7.2.5
