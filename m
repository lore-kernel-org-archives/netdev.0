From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 2/9] tipc: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:29 +0100
Message-ID: <1269453456-13599-2-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>, Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml107.kpnxchange.com ([195.121.3.11]:49979 "EHLO
	CPSMTPM-EML107.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756654Ab0CXR5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 13:57:39 -0400
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: Per Liden <per.liden@ericsson.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/link.c |    8 ++++----
 net/tipc/net.c  |    2 +-
 net/tipc/node.c |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 49f2be8..c76e82e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -877,7 +877,7 @@ static void link_state_event(struct link *l_ptr, unsigned event)
 		case TIMEOUT_EVT:
 			dbg_link("TIM ");
 			if (l_ptr->next_in_no != l_ptr->checkpoint) {
-				dbg_link("-> WW \n");
+				dbg_link("-> WW\n");
 				l_ptr->state = WORKING_WORKING;
 				l_ptr->fsm_msg_cnt = 0;
 				l_ptr->checkpoint = l_ptr->next_in_no;
@@ -934,7 +934,7 @@ static void link_state_event(struct link *l_ptr, unsigned event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
-			dbg_link("RES \n");
+			dbg_link("RES\n");
 			dbg_link(" -> RR\n");
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -947,7 +947,7 @@ static void link_state_event(struct link *l_ptr, unsigned event)
 			l_ptr->started = 1;
 			/* fall through */
 		case TIMEOUT_EVT:
-			dbg_link("TIM \n");
+			dbg_link("TIM\n");
 			tipc_link_send_proto_msg(l_ptr, RESET_MSG, 0, 0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv);
@@ -3295,7 +3295,7 @@ static void link_dump_rec_queue(struct link *l_ptr)
 			info("buffer %x invalid\n", crs);
 			return;
 		}
-		msg_dbg(buf_msg(crs), "In rec queue: \n");
+		msg_dbg(buf_msg(crs), "In rec queue:\n");
 		crs = crs->next;
 	}
 }
diff --git a/net/tipc/net.c b/net/tipc/net.c
index f25b1cd..79ce8fa 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -291,6 +291,6 @@ void tipc_net_stop(void)
 	tipc_bclink_stop();
 	net_stop();
 	write_unlock_bh(&tipc_net_lock);
-	info("Left network mode \n");
+	info("Left network mode\n");
 }
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 2c24e7d..17cc394 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -278,7 +278,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 			n_ptr->link_cnt++;
 			return n_ptr;
 		}
-		err("Attempt to establish second link on <%s> to %s \n",
+		err("Attempt to establish second link on <%s> to %s\n",
 		    l_ptr->b_ptr->publ.name,
 		    addr_string_fill(addr_string, l_ptr->addr));
 	}
-- 
1.6.6.1

