From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 20/26] tipc: Remove unused field in bearer structure
Date: Sun, 13 Mar 2011 17:34:08 -0400
Message-ID: <1300052054-7531-21-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49929 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235Ab1CMVe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:57 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates a field in TIPC's bearer objects that is set, but never
referenced.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    1 -
 net/tipc/bearer.h |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9815797..c9b5268 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -560,7 +560,6 @@ restart:
 	b_ptr->media = m_ptr;
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->active = 1;
-	b_ptr->detect_scope = disc_domain;
 	b_ptr->priority = priority;
 	INIT_LIST_HEAD(&b_ptr->cong_links);
 	INIT_LIST_HEAD(&b_ptr->links);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index adebdaf..305b378 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -105,7 +105,6 @@ struct media {
  * @name: bearer name (format = media:interface)
  * @media: ptr to media structure associated with bearer
  * @priority: default link priority for bearer
- * @detect_scope: network address mask used during automatic link creation
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
  * @links: list of non-congested links associated with bearer
@@ -128,7 +127,6 @@ struct tipc_bearer {
 	spinlock_t lock;
 	struct media *media;
 	u32 priority;
-	u32 detect_scope;
 	u32 identity;
 	struct link_req *link_req;
 	struct list_head links;
-- 
1.7.3.3

