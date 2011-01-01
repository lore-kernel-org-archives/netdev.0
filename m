From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/20] tipc: remove redundant #includes
Date: Fri, 31 Dec 2010 23:59:29 -0500
Message-ID: <1293857975-30267-15-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53332 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1AAFAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:11 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates a number of #include statements that no longer serve any
useful purpose.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.c       |    1 -
 net/tipc/bcast.c      |    1 -
 net/tipc/bearer.c     |    1 -
 net/tipc/config.c     |    1 -
 net/tipc/core.c       |    6 ------
 net/tipc/discover.c   |    2 --
 net/tipc/eth_media.c  |    4 ----
 net/tipc/msg.c        |    1 -
 net/tipc/name_distr.c |    1 -
 net/tipc/net.c        |    2 --
 net/tipc/node.c       |    1 -
 net/tipc/socket.c     |   11 -----------
 12 files changed, 0 insertions(+), 32 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 483868a..88463d9 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "node.h"
 #include "addr.h"
 
 /**
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 22a10fa..c0f3b09 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -38,7 +38,6 @@
 #include "core.h"
 #include "link.h"
 #include "port.h"
-#include "name_distr.h"
 #include "bcast.h"
 
 #define MAX_PKT_DEFAULT_MCAST 1500	/* bcast link max packet size (fixed) */
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 24dc6c2..040f3ed 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -37,7 +37,6 @@
 #include "core.h"
 #include "config.h"
 #include "bearer.h"
-#include "port.h"
 #include "discover.h"
 
 #define MAX_ADDR_STR 32
diff --git a/net/tipc/config.c b/net/tipc/config.c
index a7894ff..6c67132 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -36,7 +36,6 @@
 
 #include "core.h"
 #include "port.h"
-#include "link.h"
 #include "name_table.h"
 #include "config.h"
 
diff --git a/net/tipc/core.c b/net/tipc/core.c
index a02bc49..60b85ec 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -34,14 +34,8 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/random.h>
-
 #include "core.h"
 #include "ref.h"
-#include "net.h"
 #include "name_table.h"
 #include "subscr.h"
 #include "config.h"
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index e722378..be28f5a 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -37,8 +37,6 @@
 #include "core.h"
 #include "link.h"
 #include "discover.h"
-#include "port.h"
-#include "name_table.h"
 
 #define TIPC_LINK_REQ_INIT	125	/* min delay during bearer start up */
 #define TIPC_LINK_REQ_FAST	2000	/* normal delay if bearer has no links */
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index ee683cc..101d9cb 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -34,10 +34,6 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/netdevice.h>
-#include <linux/slab.h>
-#include <net/net_namespace.h>
-
 #include "core.h"
 #include "bearer.h"
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a029cdc..2571ffb 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "addr.h"
 #include "msg.h"
 
 u32 tipc_msg_tot_importance(struct tipc_msg *m)
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 0dd648e..376a30b 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "addr.h"
 #include "link.h"
 #include "name_distr.h"
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 6290bec..9bacfd0 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -36,10 +36,8 @@
 
 #include "core.h"
 #include "net.h"
-#include "name_table.h"
 #include "name_distr.h"
 #include "subscr.h"
-#include "link.h"
 #include "port.h"
 #include "config.h"
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index fb54719..126d774 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -37,7 +37,6 @@
 #include "core.h"
 #include "config.h"
 #include "node.h"
-#include "port.h"
 #include "name_distr.h"
 
 static void node_lost_contact(struct tipc_node *n_ptr);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7a21a5e..f972c0b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -34,17 +34,6 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/module.h>
-#include <linux/types.h>
-#include <linux/net.h>
-#include <linux/socket.h>
-#include <linux/errno.h>
-#include <linux/mm.h>
-#include <linux/poll.h>
-#include <linux/fcntl.h>
-#include <linux/gfp.h>
-#include <asm/string.h>
-#include <asm/atomic.h>
 #include <net/sock.h>
 
 #include <linux/tipc.h>
-- 
1.7.3.3

