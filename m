From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 29/34] tipc: Drop __TIME__ usage
Date: Tue,  5 Apr 2011 16:59:16 +0200
Message-ID: <1302015561-21047-30-git-send-email-mmarek@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Cc: linux-kernel@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel already prints its build timestamp during boot, no need to
repeat it in random drivers and produce different object files each
time.

Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Cc: tipc-discussion@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 net/tipc/core.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index e071579..33532fe 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -185,8 +185,7 @@ static int __init tipc_init(void)
 	if (tipc_log_resize(CONFIG_TIPC_LOG) != 0)
 		warn("Unable to create log buffer\n");
 
-	info("Activated (version " TIPC_MOD_VER
-	     " compiled " __DATE__ " " __TIME__ ")\n");
+	info("Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
-- 
1.7.4.1
