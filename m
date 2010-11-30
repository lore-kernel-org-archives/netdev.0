From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/11] tipc: Remove obsolete inclusions of header files
Date: Tue, 30 Nov 2010 17:00:54 -0500
Message-ID: <1291154463-26346-3-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58699 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0K3WBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:10 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of #include statements that are no longer required as a
result of the merging of obsolete native API header file content
into other TIPC include files.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.c        |    2 --
 net/tipc/bcast.c       |    9 ---------
 net/tipc/bearer.c      |    3 ---
 net/tipc/bearer.h      |    1 -
 net/tipc/cluster.c     |    6 ------
 net/tipc/config.c      |    5 -----
 net/tipc/config.h      |    1 -
 net/tipc/core.c        |    1 -
 net/tipc/discover.c    |    2 --
 net/tipc/discover.h    |    2 --
 net/tipc/link.c        |    8 --------
 net/tipc/link.h        |    1 -
 net/tipc/msg.c         |    2 --
 net/tipc/name_distr.c  |    2 --
 net/tipc/name_table.c  |    5 -----
 net/tipc/net.c         |    5 -----
 net/tipc/node.c        |    6 ------
 net/tipc/node_subscr.c |    2 --
 net/tipc/port.c        |    6 ------
 net/tipc/port.h        |    2 --
 net/tipc/subscr.c      |    3 ---
 net/tipc/zone.c        |    3 ---
 22 files changed, 0 insertions(+), 77 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 8a2e89b..886715a 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -35,11 +35,9 @@
  */
 
 #include "core.h"
-#include "dbg.h"
 #include "addr.h"
 #include "zone.h"
 #include "cluster.h"
-#include "net.h"
 
 /**
  * tipc_addr_domain_valid - validates a network domain address
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7d449f0..6d828d9 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -36,18 +36,9 @@
  */
 
 #include "core.h"
-#include "msg.h"
-#include "dbg.h"
 #include "link.h"
-#include "net.h"
-#include "node.h"
 #include "port.h"
-#include "addr.h"
-#include "node_subscr.h"
 #include "name_distr.h"
-#include "bearer.h"
-#include "name_table.h"
-#include "port.h"
 #include "bcast.h"
 
 #define MAX_PKT_DEFAULT_MCAST 1500	/* bcast link max packet size (fixed) */
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9927d1d..347f255 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -36,12 +36,9 @@
 
 #include "core.h"
 #include "config.h"
-#include "dbg.h"
 #include "bearer.h"
-#include "link.h"
 #include "port.h"
 #include "discover.h"
-#include "bcast.h"
 
 #define MAX_ADDR_STR 32
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 49af7fa..8dc0e92 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -37,7 +37,6 @@
 #ifndef _TIPC_BEARER_H
 #define _TIPC_BEARER_H
 
-#include "core.h"
 #include "bcast.h"
 
 #define MAX_BEARERS 8
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 7fea14b..ee25179 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -36,13 +36,7 @@
 
 #include "core.h"
 #include "cluster.h"
-#include "addr.h"
-#include "node_subscr.h"
 #include "link.h"
-#include "node.h"
-#include "net.h"
-#include "msg.h"
-#include "bearer.h"
 
 static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
 				u32 lower, u32 upper);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 82267f3..5bb3696 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -35,14 +35,9 @@
  */
 
 #include "core.h"
-#include "dbg.h"
-#include "bearer.h"
 #include "port.h"
 #include "link.h"
-#include "zone.h"
-#include "addr.h"
 #include "name_table.h"
-#include "node.h"
 #include "user_reg.h"
 #include "config.h"
 
diff --git a/net/tipc/config.h b/net/tipc/config.h
index 481e12e..443159a 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -39,7 +39,6 @@
 
 /* ---------------------------------------------------------------------- */
 
-#include "core.h"
 #include "link.h"
 
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 785362f..f5d62c1 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -40,7 +40,6 @@
 #include <linux/random.h>
 
 #include "core.h"
-#include "dbg.h"
 #include "ref.h"
 #include "net.h"
 #include "user_reg.h"
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 4a7cd37..f2ce36b 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -35,9 +35,7 @@
  */
 
 #include "core.h"
-#include "dbg.h"
 #include "link.h"
-#include "zone.h"
 #include "discover.h"
 #include "port.h"
 #include "name_table.h"
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index f8e7506..d2c3cff 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -37,8 +37,6 @@
 #ifndef _TIPC_DISCOVER_H
 #define _TIPC_DISCOVER_H
 
-#include "core.h"
-
 struct link_req;
 
 struct link_req *tipc_disc_init_link_req(struct bearer *b_ptr,
diff --git a/net/tipc/link.c b/net/tipc/link.c
index b31992c..aee6579 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -35,19 +35,11 @@
  */
 
 #include "core.h"
-#include "dbg.h"
 #include "link.h"
-#include "net.h"
-#include "node.h"
 #include "port.h"
-#include "addr.h"
-#include "node_subscr.h"
 #include "name_distr.h"
-#include "bearer.h"
-#include "name_table.h"
 #include "discover.h"
 #include "config.h"
-#include "bcast.h"
 
 
 /*
diff --git a/net/tipc/link.h b/net/tipc/link.h
index f98bc61..c562888 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -39,7 +39,6 @@
 
 #include "dbg.h"
 #include "msg.h"
-#include "bearer.h"
 #include "node.h"
 
 #define PUSH_FAILED   1
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ecb532f..ee6b4c6 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -36,9 +36,7 @@
 
 #include "core.h"
 #include "addr.h"
-#include "dbg.h"
 #include "msg.h"
-#include "bearer.h"
 
 u32 tipc_msg_tot_importance(struct tipc_msg *m)
 {
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 7b90717..10ff48b 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -36,9 +36,7 @@
 
 #include "core.h"
 #include "cluster.h"
-#include "dbg.h"
 #include "link.h"
-#include "msg.h"
 #include "name_distr.h"
 
 #define ITEM_SIZE sizeof(struct distr_item)
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 3a8de43..d5adb04 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -36,15 +36,10 @@
 
 #include "core.h"
 #include "config.h"
-#include "dbg.h"
 #include "name_table.h"
 #include "name_distr.h"
-#include "addr.h"
-#include "node_subscr.h"
 #include "subscr.h"
 #include "port.h"
-#include "cluster.h"
-#include "bcast.h"
 
 static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 1a621cf..c2b4b86 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -35,18 +35,13 @@
  */
 
 #include "core.h"
-#include "bearer.h"
 #include "net.h"
 #include "zone.h"
-#include "addr.h"
 #include "name_table.h"
 #include "name_distr.h"
 #include "subscr.h"
 #include "link.h"
-#include "msg.h"
 #include "port.h"
-#include "bcast.h"
-#include "discover.h"
 #include "config.h"
 
 /*
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b4d87eb..bd959a8 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -37,13 +37,7 @@
 #include "core.h"
 #include "config.h"
 #include "node.h"
-#include "cluster.h"
-#include "net.h"
-#include "addr.h"
-#include "node_subscr.h"
-#include "link.h"
 #include "port.h"
-#include "bearer.h"
 #include "name_distr.h"
 
 void node_print(struct print_buf *buf, struct tipc_node *n_ptr, char *str);
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 19194d4..018a553 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -35,10 +35,8 @@
  */
 
 #include "core.h"
-#include "dbg.h"
 #include "node_subscr.h"
 #include "node.h"
-#include "addr.h"
 
 /**
  * tipc_nodesub_subscribe - create "node down" subscription for specified node
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 82092ea..e822117 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -36,15 +36,9 @@
 
 #include "core.h"
 #include "config.h"
-#include "dbg.h"
 #include "port.h"
-#include "addr.h"
-#include "link.h"
-#include "node.h"
 #include "name_table.h"
 #include "user_reg.h"
-#include "msg.h"
-#include "bcast.h"
 
 /* Connection management: */
 #define PROBING_INTERVAL 3600000	/* [ms] => 1 h */
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 8b9d87a..e038ce1 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -37,11 +37,9 @@
 #ifndef _TIPC_PORT_H
 #define _TIPC_PORT_H
 
-#include "core.h"
 #include "ref.h"
 #include "net.h"
 #include "msg.h"
-#include "dbg.h"
 #include "node_subscr.h"
 
 #define TIPC_FLOW_CONTROL_WIN 512
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index a857e6e..e7fb38b 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -35,11 +35,8 @@
  */
 
 #include "core.h"
-#include "dbg.h"
 #include "name_table.h"
 #include "user_reg.h"
-#include "port.h"
-#include "ref.h"
 #include "subscr.h"
 
 /**
diff --git a/net/tipc/zone.c b/net/tipc/zone.c
index 83f8b5e..1b61ca8 100644
--- a/net/tipc/zone.c
+++ b/net/tipc/zone.c
@@ -36,9 +36,6 @@
 
 #include "core.h"
 #include "zone.h"
-#include "net.h"
-#include "addr.h"
-#include "node_subscr.h"
 #include "cluster.h"
 #include "node.h"
 
-- 
1.7.3.2.146.g2d444

