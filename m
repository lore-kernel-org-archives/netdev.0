From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 25/27] afnetns: ipv4: inherit afnetns from calling application
Date: Mon, 13 Mar 2017 00:01:49 +0100
Message-ID: <20170312230151.5185-26-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48852 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935653AbdCLXCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:17 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 4DE3B20757
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:16 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id AE32F240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:15 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/devinet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 82a7389ec86faa..01bdff8a957ae1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -838,7 +838,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 			goto errout_free;
 		}
 	} else {
-		ifa->afnetns = afnetns_get(net->afnet_ns);
+		ifa->afnetns = afnetns_get(current->nsproxy->afnet_ns);
 	}
 #else
 	if (tb[IFA_AFNETNS_FD]) {
-- 
2.9.3
