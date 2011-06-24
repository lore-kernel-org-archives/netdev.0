From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/20] tipc: Remove unused sanity test macro
Date: Fri, 24 Jun 2011 18:07:09 -0400
Message-ID: <1308953247-25266-3-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34347 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945Ab1FXWHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:40 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates a TIPC-specific assert() macro that is no longer used.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 436dda1..d234a98 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -62,12 +62,6 @@ struct tipc_msg;	/* msg.h */
 struct print_buf;	/* log.h */
 
 /*
- * TIPC sanity test macros
- */
-
-#define assert(i)  BUG_ON(!(i))
-
-/*
  * TIPC system monitoring code
  */
 
-- 
1.7.4.4

