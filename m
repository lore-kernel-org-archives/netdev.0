From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/17] tipc: Fix print statements that assume pointers are 32-bit values
Date: Wed, 23 Feb 2011 20:26:34 -0500
Message-ID: <1298510805-20630-7-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34494 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079Ab1BXB1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:08 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Corrects print statements that use %x to print pointer values to use
%p instead, so that 64-bit pointer values are displayed correctly.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3c1c28c..d586265 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2983,9 +2983,9 @@ static void link_print(struct link *l_ptr, const char *str)
 		     != (l_ptr->out_queue_size - 1)) ||
 		    (l_ptr->last_out->next != NULL)) {
 			tipc_printf(buf, "\nSend queue inconsistency\n");
-			tipc_printf(buf, "first_out= %x ", l_ptr->first_out);
-			tipc_printf(buf, "next_out= %x ", l_ptr->next_out);
-			tipc_printf(buf, "last_out= %x ", l_ptr->last_out);
+			tipc_printf(buf, "first_out= %p ", l_ptr->first_out);
+			tipc_printf(buf, "next_out= %p ", l_ptr->next_out);
+			tipc_printf(buf, "last_out= %p ", l_ptr->last_out);
 		}
 	} else
 		tipc_printf(buf, "[]");
-- 
1.7.3.3

