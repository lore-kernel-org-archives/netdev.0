From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 21/28] tipc: Lower limits for number of bearers and media types
Date: Sat, 17 Sep 2011 23:32:17 -0400
Message-ID: <1316316744-29514-22-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49997 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756367Ab1IRDc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:58 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Reduces the number of bearers a node can support to 2, which can use
identical or non-identical media. This change won't impact users,
since they are currently limited to a maximum of 2 Ethernet bearers,
and will save memory by eliminating a number of unused entries in
TIPC's media and bearer arrays.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.h    |    4 ++--
 net/tipc/eth_media.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 5ad70ef..d696f9e 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -39,8 +39,8 @@
 
 #include "bcast.h"
 
-#define MAX_BEARERS 8
-#define MAX_MEDIA 4
+#define MAX_BEARERS	2
+#define MAX_MEDIA	2
 
 /*
  * Identifiers of supported TIPC media types
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 413b337..e728d4c 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -37,7 +37,7 @@
 #include "core.h"
 #include "bearer.h"
 
-#define MAX_ETH_BEARERS		2
+#define MAX_ETH_BEARERS		MAX_BEARERS
 #define ETH_LINK_PRIORITY	TIPC_DEF_LINK_PRI
 #define ETH_LINK_TOLERANCE	TIPC_DEF_LINK_TOL
 #define ETH_LINK_WINDOW		TIPC_DEF_LINK_WIN
-- 
1.7.4.4
