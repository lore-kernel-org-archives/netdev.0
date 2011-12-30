From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 5/8] tipc: rename struct bclink to struct tipc_bclink
Date: Thu, 29 Dec 2011 22:48:54 -0500
Message-ID: <1325216937-5856-6-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63619 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079Ab1L3DtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:14 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make this rename so that it is consistent with the majority
of the other tipc structs and to assist in removing any
ambiguity with other similar names in other subsystems.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 653be79..e88da1c 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -84,7 +84,7 @@ struct bcbearer {
 };
 
 /**
- * struct bclink - link used for broadcast messages
+ * struct tipc_bclink - link used for broadcast messages
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
  * @bcast_nodes: map of broadcast-capable nodes
@@ -93,7 +93,7 @@ struct bcbearer {
  * Handles sequence numbering, fragmentation, bundling, etc.
  */
 
-struct bclink {
+struct tipc_bclink {
 	struct link link;
 	struct tipc_node node;
 	struct tipc_node_map bcast_nodes;
@@ -101,10 +101,10 @@ struct bclink {
 };
 
 static struct bcbearer bcast_bearer;
-static struct bclink bcast_link;
+static struct tipc_bclink bcast_link;
 
 static struct bcbearer *bcbearer = &bcast_bearer;
-static struct bclink *bclink = &bcast_link;
+static struct tipc_bclink *bclink = &bcast_link;
 static struct link *bcl = &bcast_link.link;
 
 static DEFINE_SPINLOCK(bc_lock);
-- 
1.7.4.4
