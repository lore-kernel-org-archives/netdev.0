From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: [PATCH 4/6] [IPSEC] added the definition of Camellia cipher
 algorithm.
Date: Wed, 18 Oct 2006 16:17:28 +0900 (JST)
Message-ID: <20061018.161728.179962417.takamiya@po.ntts.co.jp>
References: <20061018.161510.796986352.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp
Return-path: <linux-crypto-owner@vger.kernel.org>
To: linux-crypto@vger.kernel.org
In-Reply-To: <20061018.161510.796986352.takamiya@po.ntts.co.jp>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds the definitions used by pfkeyv2 interface for Camellia
cipher algorithm.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

---

 include/linux/pfkeyv2.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

1b6712cdb8fd31482d7e7da56e5f602357ec4aa4
diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index d5dd471..b16e474 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -296,6 +296,7 @@ #define SADB_X_EALG_CASTCBC		6
 #define SADB_X_EALG_BLOWFISHCBC		7
 #define SADB_EALG_NULL			11
 #define SADB_X_EALG_AESCBC		12
+#define SADB_X_EALG_CAMELLIACBC		22
 #define SADB_EALG_MAX                   253 /* last EALG */
 /* private allocations should use 249-255 (RFC2407) */
 #define SADB_X_EALG_SERPENTCBC  252     /* draft-ietf-ipsec-ciph-aes-cbc-00 */
-- 
Noriaki TAKAMIYA
