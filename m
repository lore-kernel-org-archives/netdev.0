From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v2 2/5] mpls: Remove incorrect PHP comment
Date: Fri, 20 Mar 2015 15:42:47 +0000
Message-ID: <1426866170-28739-3-git-send-email-rshearma@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
 <1426866170-28739-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34909 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbbCTPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 11:44:00 -0400
In-Reply-To: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Popping the last label on the stack does not necessarily imply
performing penultimate hop popping. There is no reason why this
couldn't be the last hop in the network, so remove the comment.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0d6763a..bf3459a 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -199,7 +199,6 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	skb->protocol = htons(ETH_P_MPLS_UC);
 
 	if (unlikely(!new_header_size && dec.bos)) {
-		/* Penultimate hop popping */
 		if (!mpls_egress(rt, skb, dec))
 			goto drop;
 	} else {
-- 
2.1.4
