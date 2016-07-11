From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Subject: [PATCH 3/3] crypto: Added Chelsio Menu to the Kconfig file
Date: Mon, 11 Jul 2016 11:28:08 -0700
Message-ID: <1468261688-24525-4-git-send-email-yeshaswi@chelsio.com>
References: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
Cc: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, linux-crypto@vger.kernel.org,
	jlulla@chelsio.com, atul.gupta@chelsio.com, harsh@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds the config entry for the Chelsio Crypto Driver, Makefile changes
for the same.

Signed-off-by: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
---
 drivers/crypto/Kconfig  |    2 ++
 drivers/crypto/Makefile |    1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/crypto/Kconfig b/drivers/crypto/Kconfig
index d77ba2f..b44faf0 100644
--- a/drivers/crypto/Kconfig
+++ b/drivers/crypto/Kconfig
@@ -537,4 +537,6 @@ config CRYPTO_DEV_ROCKCHIP
 	  This driver interfaces with the hardware crypto accelerator.
 	  Supporting cbc/ecb chainmode, and aes/des/des3_ede cipher mode.
 
+source "drivers/crypto/chelsio/Kconfig"
+
 endif # CRYPTO_HW
diff --git a/drivers/crypto/Makefile b/drivers/crypto/Makefile
index 3c6432d..ad7250f 100644
--- a/drivers/crypto/Makefile
+++ b/drivers/crypto/Makefile
@@ -31,3 +31,4 @@ obj-$(CONFIG_CRYPTO_DEV_QCE) += qce/
 obj-$(CONFIG_CRYPTO_DEV_VMX) += vmx/
 obj-$(CONFIG_CRYPTO_DEV_SUN4I_SS) += sunxi-ss/
 obj-$(CONFIG_CRYPTO_DEV_ROCKCHIP) += rockchip/
+obj-$(CONFIG_CRYPTO_DEV_CHELSIO) += chelsio/
-- 
1.7.10.1
