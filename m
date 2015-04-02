From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] pkt_sched: fq: correct spelling of locally
Date: Thu,  2 Apr 2015 11:20:23 +0900
Message-ID: <1427941223-7069-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33540 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbDBCUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 22:20:32 -0400
Received: by pacgg7 with SMTP id gg7so69709598pac.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 19:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct spelling of locally.

Also remove extra space before tab character in struct fq_flow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/sched/sch_fq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index dfcea20e3171..f377702d4b91 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -8,7 +8,7 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  *
- *  Meant to be mostly used for localy generated traffic :
+ *  Meant to be mostly used for locally generated traffic :
  *  Fast classification depends on skb->sk being set before reaching us.
  *  If not, (router workload), we use rxhash as fallback, with 32 bits wide hash.
  *  All packets belonging to a socket are considered as a 'flow'.
@@ -63,7 +63,7 @@ struct fq_flow {
 		struct sk_buff *tail;	/* last skb in the list */
 		unsigned long  age;	/* jiffies when flow was emptied, for gc */
 	};
-	struct rb_node	fq_node; 	/* anchor in fq_root[] trees */
+	struct rb_node	fq_node;	/* anchor in fq_root[] trees */
 	struct sock	*sk;
 	int		qlen;		/* number of packets in flow queue */
 	int		credit;
-- 
2.1.4
