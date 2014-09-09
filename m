From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: udp4_gro_complete() is static
Date: Tue, 09 Sep 2014 08:29:12 -0700
Message-ID: <1410276552.7106.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:46062 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaIIP3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:29:14 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so4361041pab.29
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 08:29:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net/ipv4/udp_offload.c:339:5: warning: symbol 'udp4_gro_complete' was
not declared. Should it be static?

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Fixes: 57c67ff4bd92 ("udp: additional GRO support")
---
 net/ipv4/udp_offload.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 84e0e05c9c0e..52d5f46abf86 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -336,7 +336,7 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 	return err;
 }
 
-int udp4_gro_complete(struct sk_buff *skb, int nhoff)
+static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
