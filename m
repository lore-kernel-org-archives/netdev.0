From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next v3 3/7] ipv4: fix checkpatch error with foo * bar
Date: Mon, 23 Dec 2013 13:57:22 +0800
Message-ID: <1387778246-15300-4-git-send-email-chenweilong@huawei.com>
References: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:14504 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014Ab3LWF6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 00:58:40 -0500
In-Reply-To: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/tcp_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bbaf8cb..7297b56 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -827,7 +827,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
 	int err = -1;
-	struct sk_buff * skb;
+	struct sk_buff *skb;
 
 	/* First, grab a route. */
 	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
-- 
1.7.12
