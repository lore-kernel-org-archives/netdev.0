From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 3/7] ah: Add struct crypto_ahash to ah_data
Date: Thu, 16 Jul 2009 13:18:33 +0200
Message-ID: <20090716111833.GS20288@secunet.com>
References: <20090716111548.GP20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090716111548.GP20288@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

