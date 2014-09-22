From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] udp: Need to make ip6_udp_tunnel.c have GPL license
Date: Mon, 22 Sep 2014 11:39:44 -0700
Message-ID: <1411411184-11993-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, azhou@nicira.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39349 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbaIVSkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:40:02 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so3798639pde.20
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 11:40:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unable to load various tunneling modules without this:

[   80.679049] fou: Unknown symbol udp_sock_create6 (err 0)
[   91.439939] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
[   91.439954] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
[   91.457792] vxlan: Unknown symbol udp_sock_create6 (err 0)
[   91.457831] vxlan: Unknown symbol udp_tunnel6_xmit_skb (err 0)

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/ip6_udp_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index cbc9907..b04ed72 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -103,3 +103,5 @@ int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(udp_tunnel6_xmit_skb);
+
+MODULE_LICENSE("GPL");
-- 
2.1.0.rc2.206.gedb03e5
