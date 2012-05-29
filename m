From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 3/3] drop_monitor: Add module alias to enable automatic module loading
Date: Tue, 29 May 2012 15:30:42 -0400
Message-ID: <1338319842-18395-4-git-send-email-nhorman@tuxdriver.com>
References: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36067 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab2E2TbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 15:31:14 -0400
In-Reply-To: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have module alias macros for generic netlink families, lets use
those to mark modules with the appropriate family names for loading

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Miller <davem@davemloft.net>
---
 net/core/drop_monitor.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 3252e7e..ea5fb9f 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -468,3 +468,4 @@ module_exit(exit_net_drop_monitor);
 
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Neil Horman <nhorman@tuxdriver.com>");
+MODULE_ALIAS_GENL_FAMILY("NET_DM");
-- 
1.7.7.6
