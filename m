From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 18/27] p54: move under intersil vendor directory
Date: Wed, 18 Nov 2015 16:45:57 +0200
Message-ID: <1447857966-19560-19-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part of reorganising wireless drivers directory and Kconfig.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/Kconfig                       |    1 -
 drivers/net/wireless/Makefile                      |    2 --
 drivers/net/wireless/intersil/Kconfig              |    1 +
 drivers/net/wireless/intersil/Makefile             |    1 +
 drivers/net/wireless/{ => intersil}/p54/Kconfig    |    0
 drivers/net/wireless/{ => intersil}/p54/Makefile   |    0
 drivers/net/wireless/{ => intersil}/p54/eeprom.c   |    0
 drivers/net/wireless/{ => intersil}/p54/eeprom.h   |    0
 drivers/net/wireless/{ => intersil}/p54/fwio.c     |    0
 drivers/net/wireless/{ => intersil}/p54/led.c      |    0
 drivers/net/wireless/{ => intersil}/p54/lmac.h     |    0
 drivers/net/wireless/{ => intersil}/p54/main.c     |    0
 drivers/net/wireless/{ => intersil}/p54/p54.h      |    0
 drivers/net/wireless/{ => intersil}/p54/p54pci.c   |    0
 drivers/net/wireless/{ => intersil}/p54/p54pci.h   |    0
 drivers/net/wireless/{ => intersil}/p54/p54spi.c   |    0
 drivers/net/wireless/{ => intersil}/p54/p54spi.h   |    0
 .../wireless/{ => intersil}/p54/p54spi_eeprom.h    |    0
 drivers/net/wireless/{ => intersil}/p54/p54usb.c   |    0
 drivers/net/wireless/{ => intersil}/p54/p54usb.h   |    0
 drivers/net/wireless/{ => intersil}/p54/txrx.c     |    0
 22 files changed, 3 insertions(+), 4 deletions(-)
 rename drivers/net/wireless/{ => intersil}/p54/Kconfig (100%)
 rename drivers/net/wireless/{ => intersil}/p54/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/p54/eeprom.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/eeprom.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/fwio.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/led.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/lmac.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/main.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54pci.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54pci.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54spi.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54spi.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54spi_eeprom.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54usb.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54usb.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/txrx.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 63c601b04e68..818899a4c268 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7956,7 +7956,7 @@ M:	Christian Lamparter <chunkeey@googlemail.com>
 L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/en/users/Drivers/p54
 S:	Maintained
-F:	drivers/net/wireless/p54/
+F:	drivers/net/wireless/intersil/p54/
 
 PA SEMI ETHERNET DRIVER
 M:	Olof Johansson <olof@lixom.net>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index da10b00d8af1..bea2fbb4a238 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -118,7 +118,6 @@ config MAC80211_HWSIM
 
 source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/orinoco/Kconfig"
-source "drivers/net/wireless/p54/Kconfig"
 source "drivers/net/wireless/rt2x00/Kconfig"
 source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/realtek/rtlwifi/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index a60c5e55b55e..046963fc3958 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -28,8 +28,6 @@ obj-$(CONFIG_RT2X00)	+= rt2x00/
 
 obj-$(CONFIG_WL_MEDIATEK)	+= mediatek/
 
-obj-$(CONFIG_P54_COMMON)	+= p54/
-
 obj-$(CONFIG_ATH_CARDS)		+= ath/
 
 obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
diff --git a/drivers/net/wireless/intersil/Kconfig b/drivers/net/wireless/intersil/Kconfig
index ec80b9117fd2..4bc3688bfa93 100644
--- a/drivers/net/wireless/intersil/Kconfig
+++ b/drivers/net/wireless/intersil/Kconfig
@@ -12,5 +12,6 @@ config WLAN_VENDOR_INTERSIL
 if WLAN_VENDOR_INTERSIL
 
 source "drivers/net/wireless/intersil/hostap/Kconfig"
+source "drivers/net/wireless/intersil/p54/Kconfig"
 
 endif # WLAN_VENDOR_INTERSIL
diff --git a/drivers/net/wireless/intersil/Makefile b/drivers/net/wireless/intersil/Makefile
index 4890ef79f280..90a72830b1ae 100644
--- a/drivers/net/wireless/intersil/Makefile
+++ b/drivers/net/wireless/intersil/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_HOSTAP)		+= hostap/
+obj-$(CONFIG_P54_COMMON)	+= p54/
diff --git a/drivers/net/wireless/p54/Kconfig b/drivers/net/wireless/intersil/p54/Kconfig
similarity index 100%
rename from drivers/net/wireless/p54/Kconfig
rename to drivers/net/wireless/intersil/p54/Kconfig
diff --git a/drivers/net/wireless/p54/Makefile b/drivers/net/wireless/intersil/p54/Makefile
similarity index 100%
rename from drivers/net/wireless/p54/Makefile
rename to drivers/net/wireless/intersil/p54/Makefile
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/intersil/p54/eeprom.c
similarity index 100%
rename from drivers/net/wireless/p54/eeprom.c
rename to drivers/net/wireless/intersil/p54/eeprom.c
diff --git a/drivers/net/wireless/p54/eeprom.h b/drivers/net/wireless/intersil/p54/eeprom.h
similarity index 100%
rename from drivers/net/wireless/p54/eeprom.h
rename to drivers/net/wireless/intersil/p54/eeprom.h
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/intersil/p54/fwio.c
similarity index 100%
rename from drivers/net/wireless/p54/fwio.c
rename to drivers/net/wireless/intersil/p54/fwio.c
diff --git a/drivers/net/wireless/p54/led.c b/drivers/net/wireless/intersil/p54/led.c
similarity index 100%
rename from drivers/net/wireless/p54/led.c
rename to drivers/net/wireless/intersil/p54/led.c
diff --git a/drivers/net/wireless/p54/lmac.h b/drivers/net/wireless/intersil/p54/lmac.h
similarity index 100%
rename from drivers/net/wireless/p54/lmac.h
rename to drivers/net/wireless/intersil/p54/lmac.h
diff --git a/drivers/net/wireless/p54/main.c b/drivers/net/wireless/intersil/p54/main.c
similarity index 100%
rename from drivers/net/wireless/p54/main.c
rename to drivers/net/wireless/intersil/p54/main.c
diff --git a/drivers/net/wireless/p54/p54.h b/drivers/net/wireless/intersil/p54/p54.h
similarity index 100%
rename from drivers/net/wireless/p54/p54.h
rename to drivers/net/wireless/intersil/p54/p54.h
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/intersil/p54/p54pci.c
similarity index 100%
rename from drivers/net/wireless/p54/p54pci.c
rename to drivers/net/wireless/intersil/p54/p54pci.c
diff --git a/drivers/net/wireless/p54/p54pci.h b/drivers/net/wireless/intersil/p54/p54pci.h
similarity index 100%
rename from drivers/net/wireless/p54/p54pci.h
rename to drivers/net/wireless/intersil/p54/p54pci.h
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/intersil/p54/p54spi.c
similarity index 100%
rename from drivers/net/wireless/p54/p54spi.c
rename to drivers/net/wireless/intersil/p54/p54spi.c
diff --git a/drivers/net/wireless/p54/p54spi.h b/drivers/net/wireless/intersil/p54/p54spi.h
similarity index 100%
rename from drivers/net/wireless/p54/p54spi.h
rename to drivers/net/wireless/intersil/p54/p54spi.h
diff --git a/drivers/net/wireless/p54/p54spi_eeprom.h b/drivers/net/wireless/intersil/p54/p54spi_eeprom.h
similarity index 100%
rename from drivers/net/wireless/p54/p54spi_eeprom.h
rename to drivers/net/wireless/intersil/p54/p54spi_eeprom.h
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/intersil/p54/p54usb.c
similarity index 100%
rename from drivers/net/wireless/p54/p54usb.c
rename to drivers/net/wireless/intersil/p54/p54usb.c
diff --git a/drivers/net/wireless/p54/p54usb.h b/drivers/net/wireless/intersil/p54/p54usb.h
similarity index 100%
rename from drivers/net/wireless/p54/p54usb.h
rename to drivers/net/wireless/intersil/p54/p54usb.h
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
similarity index 100%
rename from drivers/net/wireless/p54/txrx.c
rename to drivers/net/wireless/intersil/p54/txrx.c
-- 
1.7.9.5
