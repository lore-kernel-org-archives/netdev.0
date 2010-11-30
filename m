From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/11] tipc: Delete useless function prototypes
Date: Tue, 30 Nov 2010 17:00:57 -0500
Message-ID: <1291154463-26346-6-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58710 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0K3WBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:12 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Removes several function declarations that aren't used anywhere,
either because they reference routines that no longer exist or
because all users of the function reference it after it has already
been defined.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.h  |    1 -
 net/tipc/cluster.c |    1 -
 net/tipc/node.c    |    1 -
 net/tipc/port.h    |    1 -
 4 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 8dc0e92..85f451d 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -192,7 +192,6 @@ void tipc_bearer_schedule(struct bearer *b_ptr, struct link *l_ptr);
 struct bearer *tipc_bearer_find_interface(const char *if_name);
 int tipc_bearer_resolve_congestion(struct bearer *b_ptr, struct link *l_ptr);
 int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr);
-int tipc_bearer_init(void);
 void tipc_bearer_stop(void);
 void tipc_bearer_lock_push(struct bearer *b_ptr);
 
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index ee25179..405be87 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -40,7 +40,6 @@
 
 static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
 				u32 lower, u32 upper);
-static struct sk_buff *tipc_cltr_prepare_routing_msg(u32 data_size, u32 dest);
 
 struct tipc_node **tipc_local_nodes = NULL;
 struct tipc_node_map tipc_cltr_bcast_nodes = {0,{0,}};
diff --git a/net/tipc/node.c b/net/tipc/node.c
index bd959a8..df71dfc 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -40,7 +40,6 @@
 #include "port.h"
 #include "name_distr.h"
 
-void node_print(struct print_buf *buf, struct tipc_node *n_ptr, char *str);
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
 
diff --git a/net/tipc/port.h b/net/tipc/port.h
index e038ce1..547cd6e 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -242,7 +242,6 @@ int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
 			      int err);
 struct sk_buff *tipc_port_get_ports(void);
-struct sk_buff *port_show_stats(const void *req_tlv_area, int req_tlv_space);
 void tipc_port_recv_proto_msg(struct sk_buff *buf);
 void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp);
 void tipc_port_reinit(void);
-- 
1.7.3.2.146.g2d444

