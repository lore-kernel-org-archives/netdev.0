From: David Miller <davem@davemloft.net>
Subject: [PATCH] pkt_sched: Kill set but unused variable 'protocol' in
 tc_classify()
Date: Thu, 19 May 2011 18:33:21 -0400 (EDT)
Message-ID: <20110519.183321.1667430366119579493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab1ESWdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:33:23 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMXLpm028151
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:33:22 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I checked the history and this has been like this since the
beginning of time.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7490f3f..6b86276 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1673,10 +1673,8 @@ int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
 {
 	int err = 0;
 #ifdef CONFIG_NET_CLS_ACT
-	__be16 protocol;
 	struct tcf_proto *otp = tp;
 reclassify:
-	protocol = skb->protocol;
 #endif
 
 	err = tc_classify_compat(skb, tp, res);
-- 
1.7.4.4

