From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Fix key serialization.
Date: Thu, 12 Feb 2015 09:58:48 -0800
Message-ID: <1423763928-1554-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, joestringer@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:51212 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751825AbbBLR6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 12:58:53 -0500
Received: by mail-pa0-f53.google.com with SMTP id lf10so12877723pab.12
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 09:58:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix typo where mask is used rather than key.

Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
Reported-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 993281e..254e466 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1516,7 +1516,7 @@ int ovs_nla_put_identifier(const struct sw_flow *flow, struct sk_buff *skb)
 /* Called with ovs_mutex or RCU read lock. */
 int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb)
 {
-	return ovs_nla_put_key(&flow->mask->key, &flow->key,
+	return ovs_nla_put_key(&flow->key, &flow->key,
 				OVS_FLOW_ATTR_KEY, false, skb);
 }
 
-- 
1.7.1
