From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/16] tipc: Update commenting in TIPC API
Date: Tue, 11 May 2010 20:30:09 -0400
Message-ID: <162c8d4cebefd59289ff69254b8a2d25b024fadf.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35232 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab0ELAa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:29 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0USYX000107
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:28 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate comments in TIPC's main API files that are either obsolete,
incorrect, misleading, or unhelpful.  It also adds in one new comment.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc.h    |    6 +++---
 include/net/tipc/tipc.h |   16 ++++++++--------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index 9536d8a..181c8d0 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -107,7 +107,7 @@ static inline unsigned int tipc_node(__u32 addr)
  * Message importance levels
  */
 
-#define TIPC_LOW_IMPORTANCE		0  /* default */
+#define TIPC_LOW_IMPORTANCE		0
 #define TIPC_MEDIUM_IMPORTANCE		1
 #define TIPC_HIGH_IMPORTANCE		2
 #define TIPC_CRITICAL_IMPORTANCE	3
@@ -182,7 +182,7 @@ struct sockaddr_tipc {
 		struct tipc_name_seq nameseq;
 		struct {
 			struct tipc_name name;
-			__u32 domain; /* 0: own zone */
+			__u32 domain;
 		} name;
 	} addr;
 };
@@ -200,7 +200,7 @@ struct sockaddr_tipc {
  */
 
 #define TIPC_IMPORTANCE		127	/* Default: TIPC_LOW_IMPORTANCE */
-#define TIPC_SRC_DROPPABLE	128	/* Default: 0 (resend congested msg) */
+#define TIPC_SRC_DROPPABLE	128	/* Default: based on socket type */
 #define TIPC_DEST_DROPPABLE	129	/* Default: based on socket type */
 #define TIPC_CONN_TIMEOUT	130	/* Default: 8000 (ms)  */
 #define TIPC_NODE_RECVQ_DEPTH	131	/* Default: none (read only) */
diff --git a/include/net/tipc/tipc.h b/include/net/tipc/tipc.h
index 9566608..15af6dc 100644
--- a/include/net/tipc/tipc.h
+++ b/include/net/tipc/tipc.h
@@ -2,7 +2,7 @@
  * include/net/tipc/tipc.h: Main include file for TIPC users
  * 
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005,2010 Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -126,7 +126,7 @@ int tipc_createport(unsigned int tipc_user,
 		    tipc_msg_event message_cb, 
 		    tipc_named_msg_event named_message_cb, 
 		    tipc_conn_msg_event conn_message_cb, 
-		    tipc_continue_event continue_event_cb,/* May be zero */
+		    tipc_continue_event continue_event_cb,
 		    u32 *portref);
 
 int tipc_deleteport(u32 portref);
@@ -145,13 +145,13 @@ int tipc_set_portunreturnable(u32 portref, unsigned int isunreturnable);
 int tipc_publish(u32 portref, unsigned int scope, 
 		 struct tipc_name_seq const *name_seq);
 int tipc_withdraw(u32 portref, unsigned int scope,
-		  struct tipc_name_seq const *name_seq); /* 0: all */
+		  struct tipc_name_seq const *name_seq);
 
 int tipc_connect2port(u32 portref, struct tipc_portid const *port);
 
 int tipc_disconnect(u32 portref);
 
-int tipc_shutdown(u32 ref); /* Sends SHUTDOWN msg */
+int tipc_shutdown(u32 ref);
 
 int tipc_isconnected(u32 portref, int *isconnected);
 
@@ -176,7 +176,7 @@ int tipc_send_buf(u32 portref,
 
 int tipc_send2name(u32 portref, 
 		   struct tipc_name const *name, 
-		   u32 domain,	/* 0:own zone */
+		   u32 domain,
 		   unsigned int num_sect,
 		   struct iovec const *msg_sect);
 
@@ -188,7 +188,7 @@ int tipc_send_buf2name(u32 portref,
 
 int tipc_forward2name(u32 portref, 
 		      struct tipc_name const *name, 
-		      u32 domain,   /*0: own zone */
+		      u32 domain,
 		      unsigned int section_count,
 		      struct iovec const *msg_sect,
 		      struct tipc_portid const *origin,
@@ -228,14 +228,14 @@ int tipc_forward_buf2port(u32 portref,
 
 int tipc_multicast(u32 portref, 
 		   struct tipc_name_seq const *seq, 
-		   u32 domain,	/* 0:own zone */
+		   u32 domain,	/* currently unused */
 		   unsigned int section_count,
 		   struct iovec const *msg);
 
 #if 0
 int tipc_multicast_buf(u32 portref, 
 		       struct tipc_name_seq const *seq, 
-		       u32 domain,	/* 0:own zone */
+		       u32 domain,
 		       void *buf,
 		       unsigned int size);
 #endif
-- 
1.7.1.rc2

