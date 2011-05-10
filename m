From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/21] tipc: Drop __TIME__ usage
Date: Tue, 10 May 2011 16:44:17 -0400
Message-ID: <1305060277-15600-2-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Michal Marek <mmarek@suse.cz>,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52300 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab1EJUo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:44:59 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Marek <mmarek@suse.cz>

The kernel already prints its build timestamp during boot, no need to
repeat it in random drivers and produce different object files each
time.

Signed-off-by: Michal Marek <mmarek@suse.cz>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org
Cc: tipc-discussion@lists.sourceforge.net
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index c9a73e7..943b6af 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -179,8 +179,7 @@ static int __init tipc_init(void)
 	if (tipc_log_resize(CONFIG_TIPC_LOG) != 0)
 		warn("Unable to create log buffer\n");
 
-	info("Activated (version " TIPC_MOD_VER
-	     " compiled " __DATE__ " " __TIME__ ")\n");
+	info("Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
-- 
1.7.4.4

