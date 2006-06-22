From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 12/32] [TIPC] Added support for MODULE_VERSION capability.
Date: Thu, 22 Jun 2006 15:59:25 +0200
Message-ID: <11509847861028-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:35222 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030647AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 31c7dd5..5003acb 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -2,7 +2,7 @@
  * net/tipc/core.c: TIPC module code
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -57,7 +57,7 @@ void tipc_socket_stop(void);
 int  tipc_netlink_start(void);
 void tipc_netlink_stop(void);
 
-#define MOD_NAME "tipc_start: "
+#define TIPC_MOD_VER "1.6.1"
 
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
@@ -224,6 +224,7 @@ module_exit(tipc_exit);
 
 MODULE_DESCRIPTION("TIPC: Transparent Inter Process Communication");
 MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(TIPC_MOD_VER);
 
 /* Native TIPC API for kernel-space applications (see tipc.h) */
 
-- 
1.4.0

