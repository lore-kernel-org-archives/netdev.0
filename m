From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/7] ipv6: make udpv6_queue_rcv_skb static
Date: Tue, 10 Jan 2017 10:18:15 -0800
Message-ID: <20170110181816.18991-7-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32892 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940006AbdAJSSb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:31 -0500
Received: by mail-pf0-f171.google.com with SMTP id y143so29964210pfb.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:31 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only called once, and no prototype.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv6/udp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4d5c4eee4b3f..2f8ad6477eaf 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -555,7 +555,7 @@ void udpv6_encap_enable(void)
 }
 EXPORT_SYMBOL(udpv6_encap_enable);
 
-int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int is_udplite = IS_UDPLITE(sk);
-- 
2.11.0
