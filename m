From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipsec: Fix name of CAST algorithm
Date: Wed, 24 Jun 2009 18:51:46 +0800
Message-ID: <20090624105146.GA21355@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45408 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750720AbZFXKvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 06:51:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

ipsec: Fix name of CAST algorithm

Our CAST algorithm is called cast5, not cast128.  Clearly nobody
has ever used it :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index d31ccb4..faf54c6 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -292,8 +292,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 	}
 },
 {
-	.name = "cbc(cast128)",
-	.compat = "cast128",
+	.name = "cbc(cast5)",
+	.compat = "cast5",
 
 	.uinfo = {
 		.encr = {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
