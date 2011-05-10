From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/21] tipc: Eliminate unused routing message definitions
Date: Tue, 10 May 2011 16:44:19 -0400
Message-ID: <1305060277-15600-4-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52291 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab1EJUo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:44:57 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of unused constants defining the types used in routing
messages. These messages no longer exist in TIPC now that multicluster
and multizone support has been eliminated.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.h |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index d098317..c5593ac 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -741,15 +741,6 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 #define ORIGINAL_MSG     1
 
 /*
- * Routing table message types
- */
-#define EXT_ROUTING_TABLE    0
-#define LOCAL_ROUTING_TABLE  1		/* obsoleted */
-#define SLAVE_ROUTING_TABLE  2
-#define ROUTE_ADDITION       3
-#define ROUTE_REMOVAL        4
-
-/*
  * Config protocol message types
  */
 
-- 
1.7.4.4

