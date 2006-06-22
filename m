From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 3/32] [TIPC] Use correct upper bound when validating network zone number.
Date: Thu, 22 Jun 2006 15:59:16 +0200
Message-ID: <11509847852466-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:38842 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030278AbWFVN7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 3d0a8ee..31c7dd5 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -198,7 +198,7 @@ static int __init tipc_init(void)
 	tipc_max_publications = 10000;
 	tipc_max_subscriptions = 2000;
 	tipc_max_ports = delimit(CONFIG_TIPC_PORTS, 127, 65536);
-	tipc_max_zones = delimit(CONFIG_TIPC_ZONES, 1, 511);
+	tipc_max_zones = delimit(CONFIG_TIPC_ZONES, 1, 255);
 	tipc_max_clusters = delimit(CONFIG_TIPC_CLUSTERS, 1, 1);
 	tipc_max_nodes = delimit(CONFIG_TIPC_NODES, 8, 2047);
 	tipc_max_slaves = delimit(CONFIG_TIPC_SLAVE_NODES, 0, 2047);
-- 
1.4.0

