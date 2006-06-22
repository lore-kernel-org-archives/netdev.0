From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 32/32] [TIPC] Fix incorrect correction to discovery timer frequency computation.
Date: Thu, 22 Jun 2006 15:59:45 +0200
Message-ID: <11509847881839-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:45206 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030664AbWFVN7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:54 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/discover.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ee9b448..2b84412 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -2,7 +2,7 @@
  * net/tipc/discover.c
  * 
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -267,8 +267,8 @@ static void disc_timeout(struct link_req
 		/* leave timer interval "as is" if already at a "normal" rate */
 	} else {
 		req->timer_intv *= 2;
-		if (req->timer_intv > TIPC_LINK_REQ_SLOW)
-			req->timer_intv = TIPC_LINK_REQ_SLOW;
+		if (req->timer_intv > TIPC_LINK_REQ_FAST)
+			req->timer_intv = TIPC_LINK_REQ_FAST;
 		if ((req->timer_intv == TIPC_LINK_REQ_FAST) && 
 		    (req->bearer->nodes.count))
 			req->timer_intv = TIPC_LINK_REQ_SLOW;
-- 
1.4.0

