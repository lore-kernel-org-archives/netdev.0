From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-bk6 net/core/dev.c
Date: Wed, 24 Sep 2003 08:11:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064416289.1804.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Symmetric to dev_add_pack.

diff -urN linux-2.6.0-test5/net/core/dev.c shared_skb/net/core/dev.c
--- linux-2.6.0-test5/net/core/dev.c	2003-09-22 08:04:06.000000000 -0700
+++ shared_skb/net/core/dev.c	2003-09-22 14:02:08.000000000 -0700
@@ -281,7 +281,7 @@
 	list_for_each_entry(pt1, head, list) {
 		if (pt == pt1) {
 #ifdef CONFIG_NET_FASTROUTE
-			if (pt->data)
+			if (pt->data && (long)pt->data != 1)
 				netdev_fastroute_obstacles--;
 #endif
 			list_del_rcu(&pt->list);
