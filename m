From: mathieu.poirier@linaro.org
Subject: [PATCH 4/8] drivers/net: iwmc3200 depends on EXPERIMENTAL
Date: Fri, 20 Apr 2012 14:56:12 -0600
Message-ID: <1334955376-17793-5-git-send-email-mathieu.poirier@linaro.org>
References: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The iwmc3200 driver selects other code in Kconfig that depends on
EXPERIMENTAL. Kconfig warns about this when CONFIG_EXPERIMENTAL
is not already set, so logically, these options should also
be marked experimental or promoted to stable.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/wimax/i2400m/Kconfig          |    3 ++-
 drivers/net/wireless/iwmc3200wifi/Kconfig |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
index 3f70338..672de18 100644
--- a/drivers/net/wimax/i2400m/Kconfig
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -32,8 +32,9 @@ config WIMAX_I2400M_SDIO
 	  If unsure, it is safe to select M (module).
 
 config WIMAX_IWMC3200_SDIO
-	bool "Intel Wireless Multicom WiMAX Connection 3200 over SDIO"
+	bool "Intel Wireless Multicom WiMAX Connection 3200 over SDIO (EXPERIMENTAL)"
 	depends on WIMAX_I2400M_SDIO
+	depends on EXPERIMENTAL
 	select IWMC3200TOP
 	help
 	  Select if you have a device based on the Intel Multicom WiMAX
diff --git a/drivers/net/wireless/iwmc3200wifi/Kconfig b/drivers/net/wireless/iwmc3200wifi/Kconfig
index 03f998d..7107ce5 100644
--- a/drivers/net/wireless/iwmc3200wifi/Kconfig
+++ b/drivers/net/wireless/iwmc3200wifi/Kconfig
@@ -1,5 +1,5 @@
 config IWM
-	tristate "Intel Wireless Multicomm 3200 WiFi driver"
+	tristate "Intel Wireless Multicomm 3200 WiFi driver (EXPERIMENTAL)"
 	depends on MMC && EXPERIMENTAL
 	depends on CFG80211
 	select FW_LOADER
-- 
1.7.5.4
