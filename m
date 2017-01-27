From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 6/8] crypto:chcr- Change algo priority
Date: Fri, 27 Jan 2017 16:09:10 +0530
Message-ID: <dfc4b9bed016b9dbbcc22549a9bf8d48756684a9.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:22946 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932533AbdA0KlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 05:41:19 -0500
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update priorities to 3000

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_crypto.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index 7ec0a8f..81cfd0b 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -48,7 +48,7 @@
  * giving the processed data
  */
 
-#define CHCR_CRA_PRIORITY 300
+#define CHCR_CRA_PRIORITY 3000
 
 #define CHCR_AES_MAX_KEY_LEN  (2 * (AES_MAX_KEY_SIZE)) /* consider xts */
 #define CHCR_MAX_CRYPTO_IV_LEN 16 /* AES IV len */
-- 
1.8.2.3
