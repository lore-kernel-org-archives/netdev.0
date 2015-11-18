From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 16/27] zd1211rw: move under zydas vendor directory
Date: Wed, 18 Nov 2015 16:45:55 +0200
Message-ID: <1447857966-19560-17-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/zydas/Kconfig                 |    2 ++
 drivers/net/wireless/zydas/Makefile                |    2 ++
 drivers/net/wireless/{ => zydas}/zd1211rw/Kconfig  |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/Makefile |    0
 .../net/wireless/{ => zydas}/zd1211rw/zd_chip.c    |    0
 .../net/wireless/{ => zydas}/zd1211rw/zd_chip.h    |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_def.h |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.c |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.h |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.c  |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.h  |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_al2230.c   |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_al7230b.c  |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_rf2959.c   |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_uw2453.c   |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.c |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.h |    0
 20 files changed, 5 insertions(+), 3 deletions(-)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/Kconfig (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/Makefile (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_chip.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_chip.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_def.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_al2230.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_al7230b.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_rf2959.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_uw2453.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index ec098370ef3d..f2e78420488c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11883,7 +11883,7 @@ W:	http://zd1211.ath.cx/wiki/DriverRewrite
 L:	linux-wireless@vger.kernel.org
 L:	zd1211-devs@lists.sourceforge.net (subscribers-only)
 S:	Maintained
-F:	drivers/net/wireless/zd1211rw/
+F:	drivers/net/wireless/zydas/zd1211rw/
 
 ZPOOL COMPRESSED PAGE STORAGE API
 M:	Dan Streetman <ddstreet@ieee.org>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 35155e2dc8bf..e86dcdd5cfcb 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -124,7 +124,6 @@ source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/realtek/rtlwifi/Kconfig"
 source "drivers/net/wireless/realtek/rtl8xxxu/Kconfig"
 source "drivers/net/wireless/ti/Kconfig"
-source "drivers/net/wireless/zd1211rw/Kconfig"
 source "drivers/net/wireless/rsi/Kconfig"
 
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 4ee6d6d08743..8f54adde831e 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -16,7 +16,6 @@ obj-$(CONFIG_HERMES)		+= orinoco/
 obj-$(CONFIG_PRISM54)		+= prism54/
 
 obj-$(CONFIG_HOSTAP)		+= hostap/
-obj-$(CONFIG_ZD1211RW)		+= zd1211rw/
 obj-$(CONFIG_WLAN)		+= realtek/
 
 # 16-bit wireless PCMCIA client drivers
diff --git a/drivers/net/wireless/zydas/Kconfig b/drivers/net/wireless/zydas/Kconfig
index 6140dfa04fed..a58c0f65e376 100644
--- a/drivers/net/wireless/zydas/Kconfig
+++ b/drivers/net/wireless/zydas/Kconfig
@@ -30,4 +30,6 @@ config USB_ZD1201
 	  To compile this driver as a module, choose M here: the
 	  module will be called zd1201.
 
+source "drivers/net/wireless/zydas/zd1211rw/Kconfig"
+
 endif # WLAN_VENDOR_ZYDAS
diff --git a/drivers/net/wireless/zydas/Makefile b/drivers/net/wireless/zydas/Makefile
index 37179ef890ea..679fbbf3a6cd 100644
--- a/drivers/net/wireless/zydas/Makefile
+++ b/drivers/net/wireless/zydas/Makefile
@@ -1 +1,3 @@
+obj-$(CONFIG_ZD1211RW)		+= zd1211rw/
+
 obj-$(CONFIG_USB_ZD1201)	+= zd1201.o
diff --git a/drivers/net/wireless/zd1211rw/Kconfig b/drivers/net/wireless/zydas/zd1211rw/Kconfig
similarity index 100%
rename from drivers/net/wireless/zd1211rw/Kconfig
rename to drivers/net/wireless/zydas/zd1211rw/Kconfig
diff --git a/drivers/net/wireless/zd1211rw/Makefile b/drivers/net/wireless/zydas/zd1211rw/Makefile
similarity index 100%
rename from drivers/net/wireless/zd1211rw/Makefile
rename to drivers/net/wireless/zydas/zd1211rw/Makefile
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zydas/zd1211rw/zd_chip.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_chip.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_chip.c
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zydas/zd1211rw/zd_chip.h
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_chip.h
rename to drivers/net/wireless/zydas/zd1211rw/zd_chip.h
diff --git a/drivers/net/wireless/zd1211rw/zd_def.h b/drivers/net/wireless/zydas/zd1211rw/zd_def.h
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_def.h
rename to drivers/net/wireless/zydas/zd1211rw/zd_def.h
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_mac.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_mac.c
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zydas/zd1211rw/zd_mac.h
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_mac.h
rename to drivers/net/wireless/zydas/zd1211rw/zd_mac.h
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.c b/drivers/net/wireless/zydas/zd1211rw/zd_rf.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_rf.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_rf.c
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.h b/drivers/net/wireless/zydas/zd1211rw/zd_rf.h
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_rf.h
rename to drivers/net/wireless/zydas/zd1211rw/zd_rf.h
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/zydas/zd1211rw/zd_rf_al2230.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_rf_al2230.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_rf_al2230.c
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/zydas/zd1211rw/zd_rf_al7230b.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_rf_al7230b.c
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c b/drivers/net/wireless/zydas/zd1211rw/zd_rf_rf2959.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_rf_rf2959.c
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c b/drivers/net/wireless/zydas/zd1211rw/zd_rf_uw2453.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_rf_uw2453.c
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_usb.c
rename to drivers/net/wireless/zydas/zd1211rw/zd_usb.c
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zydas/zd1211rw/zd_usb.h
similarity index 100%
rename from drivers/net/wireless/zd1211rw/zd_usb.h
rename to drivers/net/wireless/zydas/zd1211rw/zd_usb.h
-- 
1.7.9.5
