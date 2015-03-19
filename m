From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 2/5] mpls: Remove incorrect PHP comment
Date: Thu, 19 Mar 2015 21:32:49 +0000
Message-ID: <1426800772-22378-3-git-send-email-rshearma@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:39219 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750940AbbCSVeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:34:44 -0400
In-Reply-To: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
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
