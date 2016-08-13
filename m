From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] sit: make function ipip6_valid_ip_proto() static
Date: Sat, 13 Aug 2016 01:54:15 +0000
Message-ID: <1471053255-31395-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34502 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbcHMByX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 21:54:23 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so188916pac.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 18:54:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following sparse warning:

net/ipv6/sit.c:1129:6: warning:
 symbol 'ipip6_valid_ip_proto' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 696edee..b1cdf80 100644
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
