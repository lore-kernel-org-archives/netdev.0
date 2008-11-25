From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 50/53] netns xfrm: AH/ESP in netns!
Date: Tue, 25 Nov 2008 20:27:22 +0300
Message-ID: <1227634045-27534-50-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-41-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-44-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-45-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-46-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-47-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-48-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-49-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:41393 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbYKYRZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:44 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23517eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:42 -0800 (PST)
In-Reply-To: <1227634045-27534-49-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/ipv4/ah4.c  |    4 +++-
 net/ipv4/esp4.c |    4 +++-
 net/ipv6/ah6.c  |    3 ++-
 net/ipv6/esp6.c |    3 ++-
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 750426b..e878e49 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -201,6 +201,7 @@ out:
 
 static void ah4_err(struct sk_buff *skb, u32 info)
 {
+	struct net *net = dev_net(skb->dev);
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
@@ -209,7 +210,7 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
+	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/%08x\n",
@@ -314,6 +315,7 @@ static struct net_protocol ah4_protocol = {
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ah4_err,
 	.no_policy	=	1,
+	.netns_ok	=	1,
 };
 
 static int __init ah4_init(void)
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 3595012..18bb383 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -413,6 +413,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 
 static void esp4_err(struct sk_buff *skb, u32 info)
 {
+	struct net *net = dev_net(skb->dev);
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
@@ -421,7 +422,7 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
+	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
@@ -618,6 +619,7 @@ static struct net_protocol esp4_protocol = {
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	esp4_err,
 	.no_policy	=	1,
+	.netns_ok	=	1,
 };
 
 static int __init esp4_init(void)
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 6ae014b..52449f7 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -407,6 +407,7 @@ out:
 static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    int type, int code, int offset, __be32 info)
 {
+	struct net *net = dev_net(skb->dev);
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
@@ -415,7 +416,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
+	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
 	if (!x)
 		return;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 68f2af8..c2f2501 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -356,6 +356,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		     int type, int code, int offset, __be32 info)
 {
+	struct net *net = dev_net(skb->dev);
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
@@ -364,7 +365,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
+	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%pI6\n",
-- 
1.5.6.5

