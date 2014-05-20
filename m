From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 07/13] openvswitch: Fix typo.
Date: Tue, 20 May 2014 02:00:24 -0700
Message-ID: <1400576424-2377-1-git-send-email-pshelar@nicira.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:56495 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753573AbaEWRGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 13:06:24 -0400
Received: by mail-pa0-f54.google.com with SMTP id bj1so4373616pad.13
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 10:06:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jrajahalme@nicira.com>

Incorrect struct name was confusing, even though otherwise
inconsequental.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index c80df6f..574c3ab 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -139,7 +139,7 @@ static void flow_free(struct sw_flow *flow)
 {
 	int node;
 
-	kfree((struct sf_flow_acts __force *)flow->sf_acts);
+	kfree((struct sw_flow_actions __force *)flow->sf_acts);
 	for_each_node(node)
 		if (flow->stats[node])
 			kmem_cache_free(flow_stats_cache,
-- 
1.9.0
