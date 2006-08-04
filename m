From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [6/6] [CRYPTO] s390: Added missing driver name and priority
Date: Fri, 4 Aug 2006 23:38:15 +1000
Message-ID: <20060804133815.GE12832@gondor.apana.org.au>
References: <20060804133157.GA12787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, linux390@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47621 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161129AbWHDNiV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 09:38:21 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060804133157.GA12787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Doh! I can't count.  This is the last one for now.

[CRYPTO] s390: Added missing driver name and priority

Accelerated versions of crypto algorithms must carry a distinct driver name
and priority in order to distinguish themselves from their generic counter-
part.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/arch/s390/crypto/aes_s390.c b/arch/s390/crypto/aes_s390.c
--- a/arch/s390/crypto/aes_s390.c
+++ b/arch/s390/crypto/aes_s390.c
@@ -222,6 +222,8 @@ static unsigned int aes_decrypt_cbc(cons
 
 static struct crypto_alg aes_alg = {
 	.cra_name		=	"aes",
+	.cra_driver_name	=	"aes-s390",
+	.cra_cra_priority	=	CRYPT_S390_PRIORITY,
 	.cra_flags		=	CRYPTO_ALG_TYPE_CIPHER,
 	.cra_blocksize		=	AES_BLOCK_SIZE,
 	.cra_ctxsize		=	sizeof(struct s390_aes_ctx),
diff --git a/arch/s390/crypto/crypt_s390.h b/arch/s390/crypto/crypt_s390.h
--- a/arch/s390/crypto/crypt_s390.h
+++ b/arch/s390/crypto/crypt_s390.h
@@ -20,6 +20,8 @@
 #define CRYPT_S390_OP_MASK 0xFF00
 #define CRYPT_S390_FUNC_MASK 0x00FF
 
+#define CRYPT_S390_PRIORITY 300
+
 /* s930 cryptographic operations */
 enum crypt_s390_operations {
 	CRYPT_S390_KM   = 0x0100,
diff --git a/arch/s390/crypto/des_s390.c b/arch/s390/crypto/des_s390.c
--- a/arch/s390/crypto/des_s390.c
+++ b/arch/s390/crypto/des_s390.c
@@ -135,6 +135,8 @@ static unsigned int des_decrypt_cbc(cons
 
 static struct crypto_alg des_alg = {
 	.cra_name		=	"des",
+	.cra_driver_name	=	"des-s390",
+	.cra_cra_priority	=	CRYPT_S390_PRIORITY,
 	.cra_flags		=	CRYPTO_ALG_TYPE_CIPHER,
 	.cra_blocksize		=	DES_BLOCK_SIZE,
 	.cra_ctxsize		=	sizeof(struct crypt_s390_des_ctx),
@@ -271,6 +273,8 @@ static unsigned int des3_128_decrypt_cbc
 
 static struct crypto_alg des3_128_alg = {
 	.cra_name		=	"des3_ede128",
+	.cra_driver_name	=	"des3_ede128-s390",
+	.cra_cra_priority	=	CRYPT_S390_PRIORITY,
 	.cra_flags		=	CRYPTO_ALG_TYPE_CIPHER,
 	.cra_blocksize		=	DES3_128_BLOCK_SIZE,
 	.cra_ctxsize		=	sizeof(struct crypt_s390_des3_128_ctx),
@@ -411,6 +415,8 @@ static unsigned int des3_192_decrypt_cbc
 
 static struct crypto_alg des3_192_alg = {
 	.cra_name		=	"des3_ede",
+	.cra_driver_name	=	"des3_ede-s390",
+	.cra_cra_priority	=	CRYPT_S390_PRIORITY,
 	.cra_flags		=	CRYPTO_ALG_TYPE_CIPHER,
 	.cra_blocksize		=	DES3_192_BLOCK_SIZE,
 	.cra_ctxsize		=	sizeof(struct crypt_s390_des3_192_ctx),
diff --git a/arch/s390/crypto/sha1_s390.c b/arch/s390/crypto/sha1_s390.c
--- a/arch/s390/crypto/sha1_s390.c
+++ b/arch/s390/crypto/sha1_s390.c
@@ -126,6 +126,8 @@ static void sha1_final(struct crypto_tfm
 
 static struct crypto_alg alg = {
 	.cra_name	=	"sha1",
+	.cra_driver_name =	"sha1-s390",
+	.cra_cra_priority =	CRYPT_S390_PRIORITY,
 	.cra_flags	=	CRYPTO_ALG_TYPE_DIGEST,
 	.cra_blocksize	=	SHA1_BLOCK_SIZE,
 	.cra_ctxsize	=	sizeof(struct crypt_s390_sha1_ctx),
diff --git a/arch/s390/crypto/sha256_s390.c b/arch/s390/crypto/sha256_s390.c
--- a/arch/s390/crypto/sha256_s390.c
+++ b/arch/s390/crypto/sha256_s390.c
@@ -127,6 +127,8 @@ static void sha256_final(struct crypto_t
 
 static struct crypto_alg alg = {
 	.cra_name	=	"sha256",
+	.cra_driver_name =	"sha256-s390",
+	.cra_cra_priority =	CRYPT_S390_PRIORITY,
 	.cra_flags	=	CRYPTO_ALG_TYPE_DIGEST,
 	.cra_blocksize	=	SHA256_BLOCK_SIZE,
 	.cra_ctxsize	=	sizeof(struct s390_sha256_ctx),
