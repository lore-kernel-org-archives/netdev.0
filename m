From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/4] [IPSEC] xfrm: Use IPPROTO_MAX instead of 256
Date: Sat, 27 May 2006 21:35:50 +1000
Message-ID: <20060527113550.GD4737@gondor.apana.org.au>
References: <20060527113236.GA4203@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qGV0fN9tzfkG3CxV"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20492 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751477AbWE0Lfw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 07:35:52 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060527113236.GA4203@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qGV0fN9tzfkG3CxV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[IPSEC] xfrm: Use IPPROTO_MAX instead of 256

The size of the type_map array (256) comes from the number of IP protocols,
i.e., IPPROTO_MAX.  This patch is based on a suggestion from Ingo Oeser.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--qGV0fN9tzfkG3CxV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p4.patch"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -207,7 +207,7 @@ struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
-	struct xfrm_type	*type_map[256];
+	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(void);

--qGV0fN9tzfkG3CxV--
