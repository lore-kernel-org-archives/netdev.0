From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 8/9] tipc: eliminate an unnecessary cast of node variable
Date: Thu, 22 Nov 2012 15:59:53 -0500
Message-ID: <1353617994-3962-9-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60005 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932577Ab2KVVAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:15 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

As the variable:node is currently defined to u32 type, it is
unnecessary to cast its type to u32 again when using it.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 55d3928..e0d0805 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -262,7 +262,7 @@ void tipc_named_node_up(unsigned long nodearg)
 	named_distribute(&message_list, node, &publ_zone, max_item_buf);
 	read_unlock_bh(&tipc_nametbl_lock);
 
-	tipc_link_send_names(&message_list, (u32)node);
+	tipc_link_send_names(&message_list, node);
 }
 
 /**
-- 
1.7.12.1
