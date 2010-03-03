From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 2/8] dccp: use limited socket backlog
Date: Wed,  3 Mar 2010 14:35:05 +0800
Message-ID: <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65441 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab0CCGdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:33:31 -0500
In-Reply-To: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make dccp adapt to the limited socket backlog change.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/dccp/minisocks.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index af226a0..0d508c3 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -254,7 +254,7 @@ int dccp_child_process(struct sock *parent, struct sock *child,
 		 * in main socket hash table and lock on listening
 		 * socket does not protect us more.
 		 */
-		sk_add_backlog(child, skb);
+		__sk_add_backlog(child, skb);
 	}
 
 	bh_unlock_sock(child);
-- 
1.6.3.3

