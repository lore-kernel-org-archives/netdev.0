From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 5/6] test_rhashtable: Use rhashtable max_size instead of max_shift
Date: Wed, 18 Mar 2015 20:01:19 +1100
Message-ID: <E1YY9qp-0005n0-Ug@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48619 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbbCRJBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts test_rhashtable to use rhashtable max_size
instead of the obsolete max_shift.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/test_rhashtable.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 16974fd..2bc403d 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -201,7 +201,7 @@ static int __init test_rht_init(void)
 		.key_offset = offsetof(struct test_obj, value),
 		.key_len = sizeof(int),
 		.hashfn = jhash,
-		.max_shift = 1, /* we expand/shrink manually here */
+		.max_size = 2, /* we expand/shrink manually here */
 		.nulls_base = (3U << RHT_BASE_SHIFT),
 	};
 	int err;
