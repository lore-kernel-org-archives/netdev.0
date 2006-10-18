From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: [PATCH 1/6] [CRYPTO] added Kconfig entry for Camellia.
Date: Wed, 18 Oct 2006 16:16:16 +0900 (JST)
Message-ID: <20061018.161616.783375937.takamiya@po.ntts.co.jp>
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

Hi, 

  This patch adds the Kconfig entry for Camellia.

  Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

---

 crypto/Kconfig |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

01b0c3898fdf1cb4da8cdf5577e58328ecb11e4e
diff --git a/crypto/Kconfig b/crypto/Kconfig
index cbae839..19858ee 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -424,6 +424,20 @@ config CRYPTO_CRC32C
 	  See Castagnoli93.  This implementation uses lib/libcrc32c.
           Module will be crc32c.
 
+config CRYPTO_CAMELLIA
+      tristate "Camellia cipher algorithms"
+      depends on CRYPTO
+      help
+       Camellia cipher algorithms module.
+
+        Camellia is a symmetric key block cipher developed jointly 
+        at NTT and Mitsubishi Electric Corporation. 
+
+        The Camellia specifies three key sizes: 128, 192 and 256 bits   
+
+        See also:
+        <https://info.isl.ntt.co.jp/crypt/eng/camellia/index_s.html>
+
 config CRYPTO_TEST
 	tristate "Testing module"
 	depends on m
-- 
Noriaki TAKAMIYA
