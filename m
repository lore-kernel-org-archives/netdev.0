From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/6] crypto: testmgr - Include crypto/aead.h
Date: Wed, 22 Apr 2015 15:06:31 +0800
Message-ID: <E1Ykojv-0002Cu-4b@gondolin.me.apana.org.au>
References: <20150422070455.GA8351@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:55527 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757870AbbDVHGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users of AEAD should include crypto/aead.h instead of
include/linux/crypto.h.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/testmgr.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index 18b7d49..d463978 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -20,6 +20,7 @@
  *
  */
 
+#include <crypto/aead.h>
 #include <crypto/hash.h>
 #include <linux/err.h>
 #include <linux/fips.h>
