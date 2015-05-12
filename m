From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: __ip_local_out_sk() is static
Date: Tue, 12 May 2015 06:31:48 -0700
Message-ID: <1431437508.566.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36163 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932579AbbELNbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 09:31:50 -0400
Received: by igbpi8 with SMTP id pi8so107908225igb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 06:31:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__ip_local_out_sk() is only used from net/ipv4/ip_output.c

net/ipv4/ip_output.c:94:5: warning: symbol '__ip_local_out_sk' was not
declared. Should it be static?

Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---

Same remark : This also applies to net tree, your choice David.

 net/ipv4/ip_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65b93a7b7113660d9f946128c0a4acee810de0f..2acc5dc32807bd5c24a6d3ac52a9662f1ac880ce 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -91,7 +91,7 @@ void ip_send_check(struct iphdr *iph)
 }
 EXPORT_SYMBOL(ip_send_check);
 
-int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
+static int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 
