From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 3/14] netlink: Use rhashtable max_size instead of max_shift
Date: Sun, 15 Mar 2015 21:44:27 +1100
Message-ID: <E1YX61z-0005mm-Rg@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56567 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbbCOKoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts netlink to use rhashtable max_size instead
of the obsolete max_shift.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6b0f219..d97aed6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3123,7 +3123,7 @@ static int __init netlink_proto_init(void)
 		.key_offset = offsetof(struct netlink_sock, portid),
 		.key_len = sizeof(u32), /* portid */
 		.hashfn = jhash,
-		.max_shift = 16, /* 64K */
+		.max_size = 65536,
 	};
 
 	if (err != 0)
