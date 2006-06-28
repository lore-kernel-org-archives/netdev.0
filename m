From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 3/3] [TIPC] Initial activation message now includes TIPC version number
Date: Wed, 28 Jun 2006 14:07:52 +0200
Message-ID: <1151496472474-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:50063 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1423298AbWF1MH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 08:07:56 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
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

