From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH]  ipv6: xfrm6: fix dubious code
Date: Mon, 23 May 2011 10:42:47 +0200
Message-ID: <1306140167.2869.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33997 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab1EWImu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 04:42:50 -0400
Received: by wwa36 with SMTP id 36so5945908wwa.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 01:42:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv6/xfrm6_tunnel.c: In function =E2=80=98xfrm6_tunnel_rcv=E2=80=99=
:
net/ipv6/xfrm6_tunnel.c:244:53: warning: the omitted middle operand
in ?: will always be =E2=80=98true=E2=80=99, suggest explicit middle op=
erand

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/xfrm6_tunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index a6770a0..fb9b0c3 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -241,7 +241,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 	__be32 spi;
=20
 	spi =3D xfrm6_tunnel_spi_lookup(net, (const xfrm_address_t *)&iph->sa=
ddr);
-	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
+	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? 1 : 0;
 }
=20
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm=
 *opt,


