From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 08/10] openvswitch: datapath.h: Fix a stale comment.
Date: Tue, 16 Apr 2013 14:00:17 -0700
Message-ID: <1366146019-9015-9-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:44366 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965290Ab3DPVAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:24 -0400
Received: by mail-da0-f70.google.com with SMTP id i30so682501dad.9
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:24 -0700 (PDT)
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 9125ad5..655beb1 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -57,7 +57,6 @@ struct dp_stats_percpu {
  * struct datapath - datapath for flow-based packet switching
  * @rcu: RCU callback head for deferred destruction.
  * @list_node: Element in global 'dps' list.
- * @n_flows: Number of flows currently in flow table.
  * @table: Current flow table.  Protected by genl_lock and RCU.
  * @ports: Hash table for ports.  %OVSP_LOCAL port always exists.  Protected by
  * RTNL and RCU.
-- 
1.7.10.4
