From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] tipc: delete extra semicolon blocking node deletion
Date: Mon, 14 Mar 2011 13:11:22 -0400
Message-ID: <1300122682-13752-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54413 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab1CNRLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 13:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove bogus semicolon only recently introduced in 34e46258cb9f5
that blocks cleanup of nodes for N>1 on shutdown.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

Also available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git tipc-Mar14-2011

 net/tipc/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 8fbc7e6..68b3dd6 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -221,7 +221,7 @@ void tipc_net_stop(void)
 	tipc_bearer_stop();
 	tipc_mode = TIPC_NODE_MODE;
 	tipc_bclink_stop();
-	list_for_each_entry_safe(node, t_node, &tipc_node_list, list);
+	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
 		tipc_node_delete(node);
 	write_unlock_bh(&tipc_net_lock);
 	info("Left network mode\n");
-- 
1.7.3.3

