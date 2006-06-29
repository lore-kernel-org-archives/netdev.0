From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 3/3] [TIPC] Initial activation message now includes TIPC version number
Date: Thu, 29 Jun 2006 17:36:08 +0200
Message-ID: <11515953692130-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606291719220.1695@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:41941 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1750806AbWF2PgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:36:14 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606291719220.1695@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 5003acb..0539a83 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -191,7 +191,8 @@ static int __init tipc_init(void)
 	int res;
 
 	tipc_log_reinit(CONFIG_TIPC_LOG);
-	info("Activated (compiled " __DATE__ " " __TIME__ ")\n");
+	info("Activated (version " TIPC_MOD_VER 
+	     " compiled " __DATE__ " " __TIME__ ")\n");
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
-- 
1.4.0

