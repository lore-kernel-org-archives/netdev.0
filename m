From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH net-next] crypto: af_alg - make exports consistant
Date: Mon, 30 Mar 2015 14:25:43 -0700
Message-ID: <20150330212543.7156.92708.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16482 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062AbbC3V2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 17:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use EXPORT_SYMBOL_GPL instead of EXPORT_SYMBOL.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/af_alg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 26089d1..f22cc56 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -381,7 +381,7 @@ void af_alg_link_sg(struct af_alg_sgl *sgl_prev, struct af_alg_sgl *sgl_new)
 	sg_unmark_end(sgl_prev->sg + sgl_prev->npages - 1);
 	sg_chain(sgl_prev->sg, sgl_prev->npages + 1, sgl_new->sg);
 }
-EXPORT_SYMBOL(af_alg_link_sg);
+EXPORT_SYMBOL_GPL(af_alg_link_sg);
 
 void af_alg_free_sg(struct af_alg_sgl *sgl)
 {
