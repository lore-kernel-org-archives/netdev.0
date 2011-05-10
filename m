From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/21] tipc: make zone/cluster mask constants a define
Date: Tue, 10 May 2011 16:44:29 -0400
Message-ID: <1305060277-15600-14-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52412 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab1EJUpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:06 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows them to be available for easy re-use in other places
and avoids trivial mistakes caused by  "count the f's and 0's".

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 8971aba..e4f35af 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -37,14 +37,17 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
 
+#define TIPC_ZONE_MASK		0xff000000u
+#define TIPC_CLUSTER_MASK	0xfffff000u
+
 static inline u32 tipc_zone_mask(u32 addr)
 {
-	return addr & 0xff000000u;
+	return addr & TIPC_ZONE_MASK;
 }
 
 static inline u32 tipc_cluster_mask(u32 addr)
 {
-	return addr & 0xfffff000u;
+	return addr & TIPC_CLUSTER_MASK;
 }
 
 static inline int in_own_cluster(u32 addr)
-- 
1.7.4.4

