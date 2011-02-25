From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 3/7] ipv6: totlen is declared and assigned but not used
Date: Fri, 25 Feb 2011 16:45:17 +0100
Message-ID: <1298648721-3026-3-git-send-email-hagen@jauu.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57593 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752888Ab1BYPxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:25 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/ip6_output.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 2600e22..25a2647 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -274,13 +274,10 @@ int ip6_nd_hdr(struct sock *sk, struct sk_buff *skb, struct net_device *dev,
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *hdr;
-	int totlen;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
 
-	totlen = len + sizeof(struct ipv6hdr);
-
 	skb_reset_network_header(skb);
 	skb_put(skb, sizeof(struct ipv6hdr));
 	hdr = ipv6_hdr(skb);
-- 
1.7.2.3

