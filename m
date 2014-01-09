From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] gre_offload: fix sparse non static symbol warning
Date: Thu, 9 Jan 2014 22:22:05 +0800
Message-ID: <CAPgLHd_s+M1XkL+Bf-Zd8CtOyt0aaOaNLRevO2JK=oX8zunR4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: xeb@mail.ru, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:36807 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbaAIOWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:22:06 -0500
Received: by mail-bk0-f54.google.com with SMTP id v16so1137061bkz.41
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 06:22:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warning:

net/ipv4/gre_offload.c:253:5: warning:
 symbol 'gre_gro_complete' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/ipv4/gre_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 746a7b1..31da9f5 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -250,7 +250,7 @@ out:
 	return pp;
 }
 
-int gre_gro_complete(struct sk_buff *skb, int nhoff)
+static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	struct gre_base_hdr *greh = (struct gre_base_hdr *)(skb->data + nhoff);
 	struct packet_offload *ptype;
