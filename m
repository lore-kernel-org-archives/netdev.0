From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/3] rtlwifi: don't add include path for rtl8188ee
Date: Tue, 19 Jul 2016 17:33:00 +0200
Message-ID: <20160719153403.2967812-1-arnd@arndb.de>
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Jes Sorensen <Jes.Sorensen@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For rtl8188ee, we pass -Idrivers/net/wireless/rtlwifi/ to gcc,
however that directy no longer exists, so evidently this option
is no longer required here and can be removed to avoid a warning
when building with 'make W=1' or 'gcc -Wmissing-include-dirs'

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile
index a85419a37651..676e7de27f27 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile
@@ -12,4 +12,4 @@ rtl8188ee-objs :=		\
 
 obj-$(CONFIG_RTL8188EE) += rtl8188ee.o
 
-ccflags-y += -Idrivers/net/wireless/rtlwifi -D__CHECK_ENDIAN__
+ccflags-y += -D__CHECK_ENDIAN__
-- 
2.9.0
