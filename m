From: avivh@mellanox.com
Subject: [PATCH net-next 3/3] xfrm: Remove redundant state assignment in xfrm_input()
Date: Tue, 24 Oct 2017 18:10:31 +0300
Message-ID: <1508857831-55824-3-git-send-email-avivh@mellanox.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris Pismenny <borisp@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        netdev@vger.kernel.org, Aviv Heller <avivh@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0069.outbound.protection.outlook.com ([104.47.1.69]:35072
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751817AbdJXPK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 11:10:58 -0400
In-Reply-To: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

x is already initialized to the same value, above.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Yevgeny Kliteynik <kliteyn@mellanox.com>
---
 net/xfrm/xfrm_input.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ea9407f..e134d3b 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -240,7 +240,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		if (xo && (xo->flags & CRYPTO_DONE)) {
 			crypto_done = true;
-			x = xfrm_input_state(skb);
 			family = XFRM_SPI_SKB_CB(skb)->family;
 
 			if (!(xo->status & CRYPTO_SUCCESS)) {
-- 
1.8.3.1
