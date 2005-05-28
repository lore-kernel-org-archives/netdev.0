From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] [DECNET] Remove unnecessary initilization of unused variable entries
Date: Sat, 28 May 2005 18:26:24 +0200
Message-ID: <20050528162624.GU15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch was supposed to be part of the neighbour tables related
patchset but apparently got lost.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit eb870ca30d39dd41d9e70103aeef4d9c6e896697
tree 9a945f37582c6f1a503366fa0831916d99cba013
parent 31006b6a5e72afbc76f95fe778e6370dd820dda0
author Thomas Graf <tgraf@suug.ch> Sat, 28 May 2005 18:21:48 +0200
committer Thomas Graf <tgraf@suug.ch> Sat, 28 May 2005 18:21:48 +0200

 net/decnet/dn_neigh.c |    1 -
 1 files changed, 1 deletion(-)

Index: net/decnet/dn_neigh.c
===================================================================
--- 4df388ef25005542b65fc297e0d1fc45acbd1d5a/net/decnet/dn_neigh.c  (mode:100644)
+++ 9a945f37582c6f1a503366fa0831916d99cba013/net/decnet/dn_neigh.c  (mode:100644)
@@ -101,7 +101,6 @@
 	.id =				"dn_neigh_cache",
 	.parms ={
 		.tbl =			&dn_neigh_table,
-		.entries =		0,
 		.base_reachable_time =	30 * HZ,
 		.retrans_time =	1 * HZ,
 		.gc_staletime =	60 * HZ,
