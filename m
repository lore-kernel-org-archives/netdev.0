From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 6/8] crypto:chcr- Change algo priority
Date: Fri,  6 Jan 2017 14:01:37 +0530
Message-ID: <1f5a51eb4987b28e30c13d3c30dfadde06e403f9.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:43037 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939664AbdAFIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:32:27 -0500
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
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
