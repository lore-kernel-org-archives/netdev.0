From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] ipv4: Include linux/prefetch.h in fib_trie.c
Date: Sun, 22 May 2011 20:57:56 -0400 (EDT)
Message-ID: <20110522.205756.895254864062539187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab1EWA56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:57:58 -0400
Received: from localhost (cpe-66-108-115-211.nyc.res.rr.com [66.108.115.211])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4N0vuOK005562
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 17:57:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_trie.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index c779ce9..dd5a320 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -67,6 +67,7 @@
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
 #include <linux/rcupdate.h>
+#include <linux/prefetch.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <linux/init.h>
-- 
1.7.4.4

