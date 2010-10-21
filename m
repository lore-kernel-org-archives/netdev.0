From: kaber@trash.net
Subject: [PATCH 69/72] netfilter: xtables: add a missing pair of parentheses
Date: Thu, 21 Oct 2010 17:19:56 +0200
Message-ID: <1287674399-31455-70-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59992 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555Ab0JUPUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:17 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 742bec0..9f69599 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -177,7 +177,7 @@ struct xt_counters_info {
 
 /* can only be xt_entry_match, so no use of typeof here */
 #define xt_ematch_foreach(pos, entry) \
-	for ((pos) = (struct xt_entry_match *)entry->elems; \
+	for ((pos) = (struct xt_entry_match *)(entry)->elems; \
 	     (pos) < (struct xt_entry_match *)((char *)(entry) + \
 	             (entry)->target_offset); \
 	     (pos) = (struct xt_entry_match *)((char *)(pos) + \
-- 
1.7.1

