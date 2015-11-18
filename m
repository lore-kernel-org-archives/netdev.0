From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 17/27] hostap: move under intersil vendor directory
Date: Wed, 18 Nov 2015 16:45:56 +0200
Message-ID: <1447857966-19560-18-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Kconfig                       |    2 +-
 drivers/net/wireless/Makefile                      |    2 +-
 drivers/net/wireless/intersil/Kconfig              |   16 ++++++++++++++++
 drivers/net/wireless/intersil/Makefile             |    1 +
 drivers/net/wireless/{ => intersil}/hostap/Kconfig |    0
 .../net/wireless/{ => intersil}/hostap/Makefile    |    0
 .../net/wireless/{ => intersil}/hostap/hostap.h    |    0
 .../wireless/{ => intersil}/hostap/hostap_80211.h  |    0
 .../{ => intersil}/hostap/hostap_80211_rx.c        |    0
 .../{ => intersil}/hostap/hostap_80211_tx.c        |    0
 .../net/wireless/{ => intersil}/hostap/hostap_ap.c |    0
 .../net/wireless/{ => intersil}/hostap/hostap_ap.h |    0
 .../wireless/{ => intersil}/hostap/hostap_common.h |    0
 .../wireless/{ => intersil}/hostap/hostap_config.h |    0
 .../net/wireless/{ => intersil}/hostap/hostap_cs.c |    0
 .../{ => intersil}/hostap/hostap_download.c        |    0
 .../net/wireless/{ => intersil}/hostap/hostap_hw.c |    0
 .../wireless/{ => intersil}/hostap/hostap_info.c   |    0
 .../wireless/{ => intersil}/hostap/hostap_ioctl.c  |    0
 .../wireless/{ => intersil}/hostap/hostap_main.c   |    0
 .../wireless/{ => intersil}/hostap/hostap_pci.c    |    0
 .../wireless/{ => intersil}/hostap/hostap_plx.c    |    0
 .../wireless/{ => intersil}/hostap/hostap_proc.c   |    0
 .../wireless/{ => intersil}/hostap/hostap_wlan.h   |    0
 25 files changed, 20 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/wireless/intersil/Kconfig
 create mode 100644 drivers/net/wireless/intersil/Makefile
 rename drivers/net/wireless/{ => intersil}/hostap/Kconfig (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_80211.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_80211_rx.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_80211_tx.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_ap.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_ap.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_common.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_config.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_cs.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_download.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_hw.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_info.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_ioctl.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_main.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_pci.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_plx.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_proc.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_wlan.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f2e78420488c..63c601b04e68 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5040,7 +5040,7 @@ L:	hostap@shmoo.com (subscribers-only)
 L:	linux-wireless@vger.kernel.org
 W:	http://hostap.epitest.fi/
 S:	Maintained
-F:	drivers/net/wireless/hostap/
+F:	drivers/net/wireless/intersil/hostap/
 
 HP COMPAQ TC1100 TABLET WMI EXTRAS DRIVER
 L:	platform-driver-x86@vger.kernel.org
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index e86dcdd5cfcb..da10b00d8af1 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -22,6 +22,7 @@ source "drivers/net/wireless/atmel/Kconfig"
 source "drivers/net/wireless/broadcom/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
 source "drivers/net/wireless/intel/Kconfig"
+source "drivers/net/wireless/intersil/Kconfig"
 source "drivers/net/wireless/marvell/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
 source "drivers/net/wireless/zydas/Kconfig"
@@ -116,7 +117,6 @@ config MAC80211_HWSIM
 	  called mac80211_hwsim.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/hostap/Kconfig"
 source "drivers/net/wireless/orinoco/Kconfig"
 source "drivers/net/wireless/p54/Kconfig"
 source "drivers/net/wireless/rt2x00/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 8f54adde831e..a60c5e55b55e 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
 obj-$(CONFIG_WLAN_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
+obj-$(CONFIG_WLAN_VENDOR_INTERSIL) += intersil/
 obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
@@ -15,7 +16,6 @@ obj-$(CONFIG_HERMES)		+= orinoco/
 
 obj-$(CONFIG_PRISM54)		+= prism54/
 
-obj-$(CONFIG_HOSTAP)		+= hostap/
 obj-$(CONFIG_WLAN)		+= realtek/
 
 # 16-bit wireless PCMCIA client drivers
diff --git a/drivers/net/wireless/intersil/Kconfig b/drivers/net/wireless/intersil/Kconfig
new file mode 100644
index 000000000000..ec80b9117fd2
--- /dev/null
+++ b/drivers/net/wireless/intersil/Kconfig
@@ -0,0 +1,16 @@
+config WLAN_VENDOR_INTERSIL
+	bool "Intersil devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_INTERSIL
+
+source "drivers/net/wireless/intersil/hostap/Kconfig"
+
+endif # WLAN_VENDOR_INTERSIL
diff --git a/drivers/net/wireless/intersil/Makefile b/drivers/net/wireless/intersil/Makefile
new file mode 100644
index 000000000000..4890ef79f280
--- /dev/null
+++ b/drivers/net/wireless/intersil/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_HOSTAP)		+= hostap/
diff --git a/drivers/net/wireless/hostap/Kconfig b/drivers/net/wireless/intersil/hostap/Kconfig
similarity index 100%
rename from drivers/net/wireless/hostap/Kconfig
rename to drivers/net/wireless/intersil/hostap/Kconfig
diff --git a/drivers/net/wireless/hostap/Makefile b/drivers/net/wireless/intersil/hostap/Makefile
similarity index 100%
rename from drivers/net/wireless/hostap/Makefile
rename to drivers/net/wireless/intersil/hostap/Makefile
diff --git a/drivers/net/wireless/hostap/hostap.h b/drivers/net/wireless/intersil/hostap/hostap.h
similarity index 100%
rename from drivers/net/wireless/hostap/hostap.h
rename to drivers/net/wireless/intersil/hostap/hostap.h
diff --git a/drivers/net/wireless/hostap/hostap_80211.h b/drivers/net/wireless/intersil/hostap/hostap_80211.h
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_80211.h
rename to drivers/net/wireless/intersil/hostap/hostap_80211.h
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_80211_rx.c
rename to drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/intersil/hostap/hostap_80211_tx.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_80211_tx.c
rename to drivers/net/wireless/intersil/hostap/hostap_80211_tx.c
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/intersil/hostap/hostap_ap.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_ap.c
rename to drivers/net/wireless/intersil/hostap/hostap_ap.c
diff --git a/drivers/net/wireless/hostap/hostap_ap.h b/drivers/net/wireless/intersil/hostap/hostap_ap.h
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_ap.h
rename to drivers/net/wireless/intersil/hostap/hostap_ap.h
diff --git a/drivers/net/wireless/hostap/hostap_common.h b/drivers/net/wireless/intersil/hostap/hostap_common.h
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_common.h
rename to drivers/net/wireless/intersil/hostap/hostap_common.h
diff --git a/drivers/net/wireless/hostap/hostap_config.h b/drivers/net/wireless/intersil/hostap/hostap_config.h
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_config.h
rename to drivers/net/wireless/intersil/hostap/hostap_config.h
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/intersil/hostap/hostap_cs.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_cs.c
rename to drivers/net/wireless/intersil/hostap/hostap_cs.c
diff --git a/drivers/net/wireless/hostap/hostap_download.c b/drivers/net/wireless/intersil/hostap/hostap_download.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_download.c
rename to drivers/net/wireless/intersil/hostap/hostap_download.c
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/intersil/hostap/hostap_hw.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_hw.c
rename to drivers/net/wireless/intersil/hostap/hostap_hw.c
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/intersil/hostap/hostap_info.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_info.c
rename to drivers/net/wireless/intersil/hostap/hostap_info.c
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_ioctl.c
rename to drivers/net/wireless/intersil/hostap/hostap_ioctl.c
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/intersil/hostap/hostap_main.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_main.c
rename to drivers/net/wireless/intersil/hostap/hostap_main.c
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/intersil/hostap/hostap_pci.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_pci.c
rename to drivers/net/wireless/intersil/hostap/hostap_pci.c
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/intersil/hostap/hostap_plx.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_plx.c
rename to drivers/net/wireless/intersil/hostap/hostap_plx.c
diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wireless/intersil/hostap/hostap_proc.c
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_proc.c
rename to drivers/net/wireless/intersil/hostap/hostap_proc.c
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/intersil/hostap/hostap_wlan.h
similarity index 100%
rename from drivers/net/wireless/hostap/hostap_wlan.h
rename to drivers/net/wireless/intersil/hostap/hostap_wlan.h
-- 
1.7.9.5
