From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] ip_tunnel: fix sparse non static symbol warning
Date: Wed, 8 Jan 2014 21:59:30 +0800
Message-ID: <CAPgLHd__qSufRW4YE63SocWV1gcgzBCBX1bdy+WcJ7v8zhE8qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:41534 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbaAHN7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 08:59:31 -0500
Received: by mail-bk0-f49.google.com with SMTP id my13so673689bkb.8
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 05:59:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warning:

net/ipv4/ip_tunnel.c:116:18: warning:
 symbol 'tunnel_dst_check' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/ipv4/ip_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 07a5ed3..d3929a6 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -113,7 +113,7 @@ static inline struct dst_entry *tunnel_dst_get(struct ip_tunnel *t)
 	return dst;
 }
 
-struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
+static struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
 {
 	struct dst_entry *dst = tunnel_dst_get(t);
 
