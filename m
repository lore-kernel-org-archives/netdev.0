From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/6] pkt_sched: sch_generic: Add Qdisc_ops peek() method.
Date: Thu, 16 Oct 2008 09:47:06 +0000
Message-ID: <20081016094706.GB19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:42527 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbYJPJrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:47:11 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1628173ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 02:47:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add Qdisc_ops peek() method in order to replace requeuing.

Based on ideas and patches of Herbert Xu, Patrick McHardy and
David S. Miller.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/sch_generic.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3fe49d8..f81f7c4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -111,6 +111,7 @@ struct Qdisc_ops
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
+	struct sk_buff *	(*peek)(struct Qdisc *);
 	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
-- 
1.5.6.5

