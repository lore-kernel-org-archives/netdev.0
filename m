From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH 1/2] sctp: fix a typo in prototype of __sctp_rcv_lookup()
Date: Wed,  3 Oct 2012 17:43:21 +0200
Message-ID: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-sctp@vger.kernel.org, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40495 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656Ab2JCPjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 11:39:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to avoid confusion when people only reads this prototype.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/sctp/input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 25dfe73..8bd3c27 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -68,8 +68,8 @@
 static int sctp_rcv_ootb(struct sk_buff *);
 static struct sctp_association *__sctp_rcv_lookup(struct net *net,
 				      struct sk_buff *skb,
-				      const union sctp_addr *laddr,
 				      const union sctp_addr *paddr,
+				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp);
 static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
 						const union sctp_addr *laddr);
-- 
1.7.12
