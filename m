From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 19/27] orinoco: move under intersil vendor directory
Date: Wed, 18 Nov 2015 16:45:58 +0200
Message-ID: <1447857966-19560-20-git-send-email-kvalo@codeaurora.org>
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
 .../net/wireless/{ => intersil}/orinoco/Kconfig    |    0
 .../net/wireless/{ => intersil}/orinoco/Makefile   |    0
 .../net/wireless/{ => intersil}/orinoco/airport.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/cfg.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/cfg.h  |    0
 drivers/net/wireless/{ => intersil}/orinoco/fw.c   |    0
 drivers/net/wireless/{ => intersil}/orinoco/fw.h   |    0
 .../net/wireless/{ => intersil}/orinoco/hermes.c   |    0
 .../net/wireless/{ => intersil}/orinoco/hermes.h   |    0
 .../wireless/{ => intersil}/orinoco/hermes_dld.c   |    0
 .../wireless/{ => intersil}/orinoco/hermes_dld.h   |    0
 .../wireless/{ => intersil}/orinoco/hermes_rid.h   |    0
 drivers/net/wireless/{ => intersil}/orinoco/hw.c   |    0
 drivers/net/wireless/{ => intersil}/orinoco/hw.h   |    0
 drivers/net/wireless/{ => intersil}/orinoco/main.c |    0
 drivers/net/wireless/{ => intersil}/orinoco/main.h |    0
 drivers/net/wireless/{ => intersil}/orinoco/mic.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/mic.h  |    0
 .../net/wireless/{ => intersil}/orinoco/orinoco.h  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_cs.c   |    0
 .../{ => intersil}/orinoco/orinoco_nortel.c        |    0
 .../wireless/{ => intersil}/orinoco/orinoco_pci.c  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_pci.h  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_plx.c  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_tmd.c  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_usb.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/scan.c |    0
 drivers/net/wireless/{ => intersil}/orinoco/scan.h |    0
 .../wireless/{ => intersil}/orinoco/spectrum_cs.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/wext.c |    0
 drivers/net/wireless/{ => intersil}/orinoco/wext.h |    0
 36 files changed, 3 insertions(+), 4 deletions(-)
 rename drivers/net/wireless/{ => intersil}/orinoco/Kconfig (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/airport.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/cfg.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/cfg.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/fw.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/fw.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes_dld.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes_dld.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes_rid.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hw.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hw.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/main.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/main.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/mic.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/mic.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_cs.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_nortel.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_pci.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_pci.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_plx.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_tmd.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_usb.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/scan.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/scan.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/spectrum_cs.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/wext.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/wext.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 818899a4c268..53c15af0d967 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7930,7 +7930,7 @@ L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/en/users/Drivers/orinoco
 W:	http://www.nongnu.org/orinoco/
 S:	Orphan
-F:	drivers/net/wireless/orinoco/
+F:	drivers/net/wireless/intersil/orinoco/
 
 OSD LIBRARY and FILESYSTEM
 M:	Boaz Harrosh <ooo@electrozaur.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index bea2fbb4a238..cc1f168603dc 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -117,7 +117,6 @@ config MAC80211_HWSIM
 	  called mac80211_hwsim.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/orinoco/Kconfig"
 source "drivers/net/wireless/rt2x00/Kconfig"
 source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/realtek/rtlwifi/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 046963fc3958..dd6d17cc4b7e 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -12,8 +12,6 @@ obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
 
-obj-$(CONFIG_HERMES)		+= orinoco/
-
 obj-$(CONFIG_PRISM54)		+= prism54/
 
 obj-$(CONFIG_WLAN)		+= realtek/
diff --git a/drivers/net/wireless/intersil/Kconfig b/drivers/net/wireless/intersil/Kconfig
index 4bc3688bfa93..2b056b6daef8 100644
--- a/drivers/net/wireless/intersil/Kconfig
+++ b/drivers/net/wireless/intersil/Kconfig
@@ -12,6 +12,7 @@ config WLAN_VENDOR_INTERSIL
 if WLAN_VENDOR_INTERSIL
 
 source "drivers/net/wireless/intersil/hostap/Kconfig"
+source "drivers/net/wireless/intersil/orinoco/Kconfig"
 source "drivers/net/wireless/intersil/p54/Kconfig"
 
 endif # WLAN_VENDOR_INTERSIL
diff --git a/drivers/net/wireless/intersil/Makefile b/drivers/net/wireless/intersil/Makefile
index 90a72830b1ae..aedb713da746 100644
--- a/drivers/net/wireless/intersil/Makefile
+++ b/drivers/net/wireless/intersil/Makefile
@@ -1,2 +1,3 @@
 obj-$(CONFIG_HOSTAP)		+= hostap/
+obj-$(CONFIG_HERMES)		+= orinoco/
 obj-$(CONFIG_P54_COMMON)	+= p54/
diff --git a/drivers/net/wireless/orinoco/Kconfig b/drivers/net/wireless/intersil/orinoco/Kconfig
similarity index 100%
rename from drivers/net/wireless/orinoco/Kconfig
rename to drivers/net/wireless/intersil/orinoco/Kconfig
diff --git a/drivers/net/wireless/orinoco/Makefile b/drivers/net/wireless/intersil/orinoco/Makefile
similarity index 100%
rename from drivers/net/wireless/orinoco/Makefile
rename to drivers/net/wireless/intersil/orinoco/Makefile
diff --git a/drivers/net/wireless/orinoco/airport.c b/drivers/net/wireless/intersil/orinoco/airport.c
similarity index 100%
rename from drivers/net/wireless/orinoco/airport.c
rename to drivers/net/wireless/intersil/orinoco/airport.c
diff --git a/drivers/net/wireless/orinoco/cfg.c b/drivers/net/wireless/intersil/orinoco/cfg.c
similarity index 100%
rename from drivers/net/wireless/orinoco/cfg.c
rename to drivers/net/wireless/intersil/orinoco/cfg.c
diff --git a/drivers/net/wireless/orinoco/cfg.h b/drivers/net/wireless/intersil/orinoco/cfg.h
similarity index 100%
rename from drivers/net/wireless/orinoco/cfg.h
rename to drivers/net/wireless/intersil/orinoco/cfg.h
diff --git a/drivers/net/wireless/orinoco/fw.c b/drivers/net/wireless/intersil/orinoco/fw.c
similarity index 100%
rename from drivers/net/wireless/orinoco/fw.c
rename to drivers/net/wireless/intersil/orinoco/fw.c
diff --git a/drivers/net/wireless/orinoco/fw.h b/drivers/net/wireless/intersil/orinoco/fw.h
similarity index 100%
rename from drivers/net/wireless/orinoco/fw.h
rename to drivers/net/wireless/intersil/orinoco/fw.h
diff --git a/drivers/net/wireless/orinoco/hermes.c b/drivers/net/wireless/intersil/orinoco/hermes.c
similarity index 100%
rename from drivers/net/wireless/orinoco/hermes.c
rename to drivers/net/wireless/intersil/orinoco/hermes.c
diff --git a/drivers/net/wireless/orinoco/hermes.h b/drivers/net/wireless/intersil/orinoco/hermes.h
similarity index 100%
rename from drivers/net/wireless/orinoco/hermes.h
rename to drivers/net/wireless/intersil/orinoco/hermes.h
diff --git a/drivers/net/wireless/orinoco/hermes_dld.c b/drivers/net/wireless/intersil/orinoco/hermes_dld.c
similarity index 100%
rename from drivers/net/wireless/orinoco/hermes_dld.c
rename to drivers/net/wireless/intersil/orinoco/hermes_dld.c
diff --git a/drivers/net/wireless/orinoco/hermes_dld.h b/drivers/net/wireless/intersil/orinoco/hermes_dld.h
similarity index 100%
rename from drivers/net/wireless/orinoco/hermes_dld.h
rename to drivers/net/wireless/intersil/orinoco/hermes_dld.h
diff --git a/drivers/net/wireless/orinoco/hermes_rid.h b/drivers/net/wireless/intersil/orinoco/hermes_rid.h
similarity index 100%
rename from drivers/net/wireless/orinoco/hermes_rid.h
rename to drivers/net/wireless/intersil/orinoco/hermes_rid.h
diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/intersil/orinoco/hw.c
similarity index 100%
rename from drivers/net/wireless/orinoco/hw.c
rename to drivers/net/wireless/intersil/orinoco/hw.c
diff --git a/drivers/net/wireless/orinoco/hw.h b/drivers/net/wireless/intersil/orinoco/hw.h
similarity index 100%
rename from drivers/net/wireless/orinoco/hw.h
rename to drivers/net/wireless/intersil/orinoco/hw.h
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/intersil/orinoco/main.c
similarity index 100%
rename from drivers/net/wireless/orinoco/main.c
rename to drivers/net/wireless/intersil/orinoco/main.c
diff --git a/drivers/net/wireless/orinoco/main.h b/drivers/net/wireless/intersil/orinoco/main.h
similarity index 100%
rename from drivers/net/wireless/orinoco/main.h
rename to drivers/net/wireless/intersil/orinoco/main.h
diff --git a/drivers/net/wireless/orinoco/mic.c b/drivers/net/wireless/intersil/orinoco/mic.c
similarity index 100%
rename from drivers/net/wireless/orinoco/mic.c
rename to drivers/net/wireless/intersil/orinoco/mic.c
diff --git a/drivers/net/wireless/orinoco/mic.h b/drivers/net/wireless/intersil/orinoco/mic.h
similarity index 100%
rename from drivers/net/wireless/orinoco/mic.h
rename to drivers/net/wireless/intersil/orinoco/mic.h
diff --git a/drivers/net/wireless/orinoco/orinoco.h b/drivers/net/wireless/intersil/orinoco/orinoco.h
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco.h
rename to drivers/net/wireless/intersil/orinoco/orinoco.h
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/intersil/orinoco/orinoco_cs.c
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_cs.c
rename to drivers/net/wireless/intersil/orinoco/orinoco_cs.c
diff --git a/drivers/net/wireless/orinoco/orinoco_nortel.c b/drivers/net/wireless/intersil/orinoco/orinoco_nortel.c
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_nortel.c
rename to drivers/net/wireless/intersil/orinoco/orinoco_nortel.c
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.c b/drivers/net/wireless/intersil/orinoco/orinoco_pci.c
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_pci.c
rename to drivers/net/wireless/intersil/orinoco/orinoco_pci.c
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.h b/drivers/net/wireless/intersil/orinoco/orinoco_pci.h
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_pci.h
rename to drivers/net/wireless/intersil/orinoco/orinoco_pci.h
diff --git a/drivers/net/wireless/orinoco/orinoco_plx.c b/drivers/net/wireless/intersil/orinoco/orinoco_plx.c
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_plx.c
rename to drivers/net/wireless/intersil/orinoco/orinoco_plx.c
diff --git a/drivers/net/wireless/orinoco/orinoco_tmd.c b/drivers/net/wireless/intersil/orinoco/orinoco_tmd.c
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_tmd.c
rename to drivers/net/wireless/intersil/orinoco/orinoco_tmd.c
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
similarity index 100%
rename from drivers/net/wireless/orinoco/orinoco_usb.c
rename to drivers/net/wireless/intersil/orinoco/orinoco_usb.c
diff --git a/drivers/net/wireless/orinoco/scan.c b/drivers/net/wireless/intersil/orinoco/scan.c
similarity index 100%
rename from drivers/net/wireless/orinoco/scan.c
rename to drivers/net/wireless/intersil/orinoco/scan.c
diff --git a/drivers/net/wireless/orinoco/scan.h b/drivers/net/wireless/intersil/orinoco/scan.h
similarity index 100%
rename from drivers/net/wireless/orinoco/scan.h
rename to drivers/net/wireless/intersil/orinoco/scan.h
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/intersil/orinoco/spectrum_cs.c
similarity index 100%
rename from drivers/net/wireless/orinoco/spectrum_cs.c
rename to drivers/net/wireless/intersil/orinoco/spectrum_cs.c
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/intersil/orinoco/wext.c
similarity index 100%
rename from drivers/net/wireless/orinoco/wext.c
rename to drivers/net/wireless/intersil/orinoco/wext.c
diff --git a/drivers/net/wireless/orinoco/wext.h b/drivers/net/wireless/intersil/orinoco/wext.h
similarity index 100%
rename from drivers/net/wireless/orinoco/wext.h
rename to drivers/net/wireless/intersil/orinoco/wext.h
-- 
1.7.9.5
