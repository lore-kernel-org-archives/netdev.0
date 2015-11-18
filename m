From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 05/27] b43legacy: move under broadcom vendor directory
Date: Wed, 18 Nov 2015 16:45:44 +0200
Message-ID: <1447857966-19560-6-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Makefile                      |    1 -
 drivers/net/wireless/broadcom/Kconfig              |    1 +
 drivers/net/wireless/broadcom/Makefile             |    1 +
 .../net/wireless/{ => broadcom}/b43legacy/Kconfig  |    0
 .../net/wireless/{ => broadcom}/b43legacy/Makefile |    0
 .../wireless/{ => broadcom}/b43legacy/b43legacy.h  |    0
 .../wireless/{ => broadcom}/b43legacy/debugfs.c    |    0
 .../wireless/{ => broadcom}/b43legacy/debugfs.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/dma.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/dma.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/ilt.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/ilt.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/leds.c   |    0
 .../net/wireless/{ => broadcom}/b43legacy/leds.h   |    0
 .../net/wireless/{ => broadcom}/b43legacy/main.c   |    0
 .../net/wireless/{ => broadcom}/b43legacy/main.h   |    0
 .../net/wireless/{ => broadcom}/b43legacy/phy.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/phy.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/pio.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/pio.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/radio.c  |    0
 .../net/wireless/{ => broadcom}/b43legacy/radio.h  |    0
 .../net/wireless/{ => broadcom}/b43legacy/rfkill.c |    0
 .../net/wireless/{ => broadcom}/b43legacy/rfkill.h |    0
 .../net/wireless/{ => broadcom}/b43legacy/sysfs.c  |    0
 .../net/wireless/{ => broadcom}/b43legacy/sysfs.h  |    0
 .../net/wireless/{ => broadcom}/b43legacy/xmit.c   |    0
 .../net/wireless/{ => broadcom}/b43legacy/xmit.h   |    0
 30 files changed, 3 insertions(+), 3 deletions(-)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/Kconfig (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/Makefile (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/b43legacy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/debugfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/debugfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/dma.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/dma.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/ilt.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/ilt.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/leds.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/leds.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/main.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/main.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/phy.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/phy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/pio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/pio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/radio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/radio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/rfkill.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/rfkill.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/sysfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/sysfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/xmit.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/xmit.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 68793777fdb5..dd20c0b1eb02 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2089,7 +2089,7 @@ L:	linux-wireless@vger.kernel.org
 L:	b43-dev@lists.infradead.org
 W:	http://wireless.kernel.org/en/users/Drivers/b43
 S:	Maintained
-F:	drivers/net/wireless/b43legacy/
+F:	drivers/net/wireless/broadcom/b43legacy/
 
 BACKLIGHT CLASS/SUBSYSTEM
 M:	Jingoo Han <jingoohan1@gmail.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 0c47f2ca2207..e261df26b0dd 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -159,7 +159,6 @@ config MWL8K
 	  will be called mwl8k.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/b43legacy/Kconfig"
 source "drivers/net/wireless/brcm80211/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
 source "drivers/net/wireless/ipw2x00/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 7907674ad5b4..13ac61737acd 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -15,7 +15,6 @@ obj-$(CONFIG_HERMES)		+= orinoco/
 obj-$(CONFIG_PRISM54)		+= prism54/
 
 obj-$(CONFIG_HOSTAP)		+= hostap/
-obj-$(CONFIG_B43LEGACY)		+= b43legacy/
 obj-$(CONFIG_ZD1211RW)		+= zd1211rw/
 obj-$(CONFIG_WLAN)		+= realtek/
 
diff --git a/drivers/net/wireless/broadcom/Kconfig b/drivers/net/wireless/broadcom/Kconfig
index 0ba8119d2cf2..323e738dd96f 100644
--- a/drivers/net/wireless/broadcom/Kconfig
+++ b/drivers/net/wireless/broadcom/Kconfig
@@ -12,5 +12,6 @@ config WLAN_VENDOR_BROADCOM
 if WLAN_VENDOR_BROADCOM
 
 source "drivers/net/wireless/broadcom/b43/Kconfig"
+source "drivers/net/wireless/broadcom/b43legacy/Kconfig"
 
 endif # WLAN_VENDOR_BROADCOM
diff --git a/drivers/net/wireless/broadcom/Makefile b/drivers/net/wireless/broadcom/Makefile
index 0140a810107c..66d7cc461fcf 100644
--- a/drivers/net/wireless/broadcom/Makefile
+++ b/drivers/net/wireless/broadcom/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_B43)		+= b43/
+obj-$(CONFIG_B43LEGACY)		+= b43legacy/
diff --git a/drivers/net/wireless/b43legacy/Kconfig b/drivers/net/wireless/broadcom/b43legacy/Kconfig
similarity index 100%
rename from drivers/net/wireless/b43legacy/Kconfig
rename to drivers/net/wireless/broadcom/b43legacy/Kconfig
diff --git a/drivers/net/wireless/b43legacy/Makefile b/drivers/net/wireless/broadcom/b43legacy/Makefile
similarity index 100%
rename from drivers/net/wireless/b43legacy/Makefile
rename to drivers/net/wireless/broadcom/b43legacy/Makefile
diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/wireless/broadcom/b43legacy/b43legacy.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/b43legacy.h
rename to drivers/net/wireless/broadcom/b43legacy/b43legacy.h
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/broadcom/b43legacy/debugfs.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/debugfs.c
rename to drivers/net/wireless/broadcom/b43legacy/debugfs.c
diff --git a/drivers/net/wireless/b43legacy/debugfs.h b/drivers/net/wireless/broadcom/b43legacy/debugfs.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/debugfs.h
rename to drivers/net/wireless/broadcom/b43legacy/debugfs.h
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/broadcom/b43legacy/dma.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/dma.c
rename to drivers/net/wireless/broadcom/b43legacy/dma.c
diff --git a/drivers/net/wireless/b43legacy/dma.h b/drivers/net/wireless/broadcom/b43legacy/dma.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/dma.h
rename to drivers/net/wireless/broadcom/b43legacy/dma.h
diff --git a/drivers/net/wireless/b43legacy/ilt.c b/drivers/net/wireless/broadcom/b43legacy/ilt.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/ilt.c
rename to drivers/net/wireless/broadcom/b43legacy/ilt.c
diff --git a/drivers/net/wireless/b43legacy/ilt.h b/drivers/net/wireless/broadcom/b43legacy/ilt.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/ilt.h
rename to drivers/net/wireless/broadcom/b43legacy/ilt.h
diff --git a/drivers/net/wireless/b43legacy/leds.c b/drivers/net/wireless/broadcom/b43legacy/leds.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/leds.c
rename to drivers/net/wireless/broadcom/b43legacy/leds.c
diff --git a/drivers/net/wireless/b43legacy/leds.h b/drivers/net/wireless/broadcom/b43legacy/leds.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/leds.h
rename to drivers/net/wireless/broadcom/b43legacy/leds.h
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/broadcom/b43legacy/main.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/main.c
rename to drivers/net/wireless/broadcom/b43legacy/main.c
diff --git a/drivers/net/wireless/b43legacy/main.h b/drivers/net/wireless/broadcom/b43legacy/main.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/main.h
rename to drivers/net/wireless/broadcom/b43legacy/main.h
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireless/broadcom/b43legacy/phy.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/phy.c
rename to drivers/net/wireless/broadcom/b43legacy/phy.c
diff --git a/drivers/net/wireless/b43legacy/phy.h b/drivers/net/wireless/broadcom/b43legacy/phy.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/phy.h
rename to drivers/net/wireless/broadcom/b43legacy/phy.h
diff --git a/drivers/net/wireless/b43legacy/pio.c b/drivers/net/wireless/broadcom/b43legacy/pio.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/pio.c
rename to drivers/net/wireless/broadcom/b43legacy/pio.c
diff --git a/drivers/net/wireless/b43legacy/pio.h b/drivers/net/wireless/broadcom/b43legacy/pio.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/pio.h
rename to drivers/net/wireless/broadcom/b43legacy/pio.h
diff --git a/drivers/net/wireless/b43legacy/radio.c b/drivers/net/wireless/broadcom/b43legacy/radio.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/radio.c
rename to drivers/net/wireless/broadcom/b43legacy/radio.c
diff --git a/drivers/net/wireless/b43legacy/radio.h b/drivers/net/wireless/broadcom/b43legacy/radio.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/radio.h
rename to drivers/net/wireless/broadcom/b43legacy/radio.h
diff --git a/drivers/net/wireless/b43legacy/rfkill.c b/drivers/net/wireless/broadcom/b43legacy/rfkill.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/rfkill.c
rename to drivers/net/wireless/broadcom/b43legacy/rfkill.c
diff --git a/drivers/net/wireless/b43legacy/rfkill.h b/drivers/net/wireless/broadcom/b43legacy/rfkill.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/rfkill.h
rename to drivers/net/wireless/broadcom/b43legacy/rfkill.h
diff --git a/drivers/net/wireless/b43legacy/sysfs.c b/drivers/net/wireless/broadcom/b43legacy/sysfs.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/sysfs.c
rename to drivers/net/wireless/broadcom/b43legacy/sysfs.c
diff --git a/drivers/net/wireless/b43legacy/sysfs.h b/drivers/net/wireless/broadcom/b43legacy/sysfs.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/sysfs.h
rename to drivers/net/wireless/broadcom/b43legacy/sysfs.h
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/broadcom/b43legacy/xmit.c
similarity index 100%
rename from drivers/net/wireless/b43legacy/xmit.c
rename to drivers/net/wireless/broadcom/b43legacy/xmit.c
diff --git a/drivers/net/wireless/b43legacy/xmit.h b/drivers/net/wireless/broadcom/b43legacy/xmit.h
similarity index 100%
rename from drivers/net/wireless/b43legacy/xmit.h
rename to drivers/net/wireless/broadcom/b43legacy/xmit.h
-- 
1.7.9.5
