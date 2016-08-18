From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] sit: ipip6_valid_ip_proto() is static
Date: Thu, 18 Aug 2016 10:03:55 -0700
Message-ID: <1471539835.29842.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34704 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753627AbcHSCZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:25:54 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so2662224pac.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:25:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fixes this sparse error :
net/ipv6/sit.c:1129:6: warning: symbol 'ipip6_valid_ip_proto' was not
declared. Should it be static?


Fixes: 49dbe7ae2168b ("sit: support MPLS over IPv4")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/sit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 182b6a9be29d..d6da9febb12d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1126,7 +1126,7 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 }
 #endif
 
-bool ipip6_valid_ip_proto(u8 ipproto)
+static bool ipip6_valid_ip_proto(u8 ipproto)
 {
 	return ipproto == IPPROTO_IPV6 ||
 		ipproto == IPPROTO_IPIP ||
