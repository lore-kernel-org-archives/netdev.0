From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/5] ah: Add struct crypto_ahash to ah_data
Date: Thu, 8 Oct 2009 10:47:16 +0200
Message-ID: <20091008084716.GK15653@secunet.com>
References: <20091008084631.GJ15653@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43197 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbZJHIry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 04:47:54 -0400
Content-Disposition: inline
In-Reply-To: <20091008084631.GJ15653@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support for ahash algorithms, we add a pointer to a
crypto_ahash to ah_data.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ah.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index ae1c322..7ac5221 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -14,6 +14,7 @@ struct ah_data
 	int			icv_trunc_len;
 
 	struct crypto_hash	*tfm;
+	struct crypto_ahash	*ahash;
 };
 
 static inline int ah_mac_digest(struct ah_data *ahp, struct sk_buff *skb,
-- 
1.5.4.2

