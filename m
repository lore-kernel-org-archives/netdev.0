From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 10/12] openvswitch: Expand action buffer size.
Date: Mon, 17 Jun 2013 17:50:23 -0700
Message-ID: <1371516623-18012-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:47812 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753087Ab3FRAu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:50:26 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so3323311pdi.39
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 17:50:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAX_ACTIONS_BUFSIZE limits action list size, set tunnel action
needs extra space on action list, for now increase max actions list limit.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index aec5e43..bfe80b9 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -159,7 +159,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
 				  const struct nlattr *attr);
 
-#define MAX_ACTIONS_BUFSIZE    (16 * 1024)
+#define MAX_ACTIONS_BUFSIZE    (32 * 1024)
 #define TBL_MIN_BUCKETS		1024
 
 struct flow_table {
-- 
1.7.1
