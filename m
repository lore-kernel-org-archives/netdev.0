From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 7/7] sched: protocol only needed when CONFIG_NET_CLS_ACT is enabled
Date: Fri, 25 Feb 2011 16:45:21 +0100
Message-ID: <1298648721-3026-7-git-send-email-hagen@jauu.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57598 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932443Ab1BYPx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:26 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/sched/sch_api.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1507415..7490f3f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1672,12 +1672,12 @@ int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
 		struct tcf_result *res)
 {
 	int err = 0;
-	__be16 protocol;
 #ifdef CONFIG_NET_CLS_ACT
+	__be16 protocol;
 	struct tcf_proto *otp = tp;
 reclassify:
-#endif
 	protocol = skb->protocol;
+#endif
 
 	err = tc_classify_compat(skb, tp, res);
 #ifdef CONFIG_NET_CLS_ACT
-- 
1.7.2.3

