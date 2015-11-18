From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 08/27] ipw2x00: move under intel vendor directory
Date: Wed, 18 Nov 2015 16:45:47 +0200
Message-ID: <1447857966-19560-9-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Makefile                      |    4 +---
 drivers/net/wireless/intel/Kconfig                 |   16 ++++++++++++++++
 drivers/net/wireless/intel/Makefile                |    2 ++
 drivers/net/wireless/{ => intel}/ipw2x00/Kconfig   |    0
 drivers/net/wireless/{ => intel}/ipw2x00/Makefile  |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw.h     |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.c |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.h |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.c |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.h |    0
 drivers/net/wireless/{ => intel}/ipw2x00/libipw.h  |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_geo.c  |    0
 .../wireless/{ => intel}/ipw2x00/libipw_module.c   |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_rx.c   |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_tx.c   |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_wx.c   |    0
 18 files changed, 21 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/wireless/intel/Kconfig
 create mode 100644 drivers/net/wireless/intel/Makefile
 rename drivers/net/wireless/{ => intel}/ipw2x00/Kconfig (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_geo.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_module.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_rx.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_tx.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_wx.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4cbd4641e6fb..b341dabeb579 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5607,7 +5607,7 @@ L:	linux-wireless@vger.kernel.org
 S:	Maintained
 F:	Documentation/networking/README.ipw2100
 F:	Documentation/networking/README.ipw2200
-F:	drivers/net/wireless/ipw2x00/
+F:	drivers/net/wireless/intel/ipw2x00/
 
 INTEL(R) TRACE HUB
 M:	Alexander Shishkin <alexander.shishkin@linux.intel.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index c1742f228fec..73e3b53caf45 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -21,6 +21,7 @@ source "drivers/net/wireless/admtek/Kconfig"
 source "drivers/net/wireless/atmel/Kconfig"
 source "drivers/net/wireless/broadcom/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
+source "drivers/net/wireless/intel/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
 
 config PCMCIA_RAYCS
@@ -161,7 +162,6 @@ config MWL8K
 
 source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
-source "drivers/net/wireless/ipw2x00/Kconfig"
 source "drivers/net/wireless/iwlwifi/Kconfig"
 source "drivers/net/wireless/iwlegacy/Kconfig"
 source "drivers/net/wireless/libertas/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index d7211a7949e6..52946d8dd31d 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -6,11 +6,9 @@ obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
 obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
 obj-$(CONFIG_WLAN_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 
-obj-$(CONFIG_IPW2100) += ipw2x00/
-obj-$(CONFIG_IPW2200) += ipw2x00/
-
 obj-$(CONFIG_HERMES)		+= orinoco/
 
 obj-$(CONFIG_PRISM54)		+= prism54/
diff --git a/drivers/net/wireless/intel/Kconfig b/drivers/net/wireless/intel/Kconfig
new file mode 100644
index 000000000000..3f8eacc4209a
--- /dev/null
+++ b/drivers/net/wireless/intel/Kconfig
@@ -0,0 +1,16 @@
+config WLAN_VENDOR_INTEL
+	bool "Intel devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_INTEL
+
+source "drivers/net/wireless/intel/ipw2x00/Kconfig"
+
+endif # WLAN_VENDOR_INTEL
diff --git a/drivers/net/wireless/intel/Makefile b/drivers/net/wireless/intel/Makefile
new file mode 100644
index 000000000000..8e5dcb2d425e
--- /dev/null
+++ b/drivers/net/wireless/intel/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_IPW2100) += ipw2x00/
+obj-$(CONFIG_IPW2200) += ipw2x00/
diff --git a/drivers/net/wireless/ipw2x00/Kconfig b/drivers/net/wireless/intel/ipw2x00/Kconfig
similarity index 100%
rename from drivers/net/wireless/ipw2x00/Kconfig
rename to drivers/net/wireless/intel/ipw2x00/Kconfig
diff --git a/drivers/net/wireless/ipw2x00/Makefile b/drivers/net/wireless/intel/ipw2x00/Makefile
similarity index 100%
rename from drivers/net/wireless/ipw2x00/Makefile
rename to drivers/net/wireless/intel/ipw2x00/Makefile
diff --git a/drivers/net/wireless/ipw2x00/ipw.h b/drivers/net/wireless/intel/ipw2x00/ipw.h
similarity index 100%
rename from drivers/net/wireless/ipw2x00/ipw.h
rename to drivers/net/wireless/intel/ipw2x00/ipw.h
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/ipw2100.c
rename to drivers/net/wireless/intel/ipw2x00/ipw2100.c
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.h b/drivers/net/wireless/intel/ipw2x00/ipw2100.h
similarity index 100%
rename from drivers/net/wireless/ipw2x00/ipw2100.h
rename to drivers/net/wireless/intel/ipw2x00/ipw2100.h
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/ipw2200.c
rename to drivers/net/wireless/intel/ipw2x00/ipw2200.c
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.h b/drivers/net/wireless/intel/ipw2x00/ipw2200.h
similarity index 100%
rename from drivers/net/wireless/ipw2x00/ipw2200.h
rename to drivers/net/wireless/intel/ipw2x00/ipw2200.h
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/intel/ipw2x00/libipw.h
similarity index 100%
rename from drivers/net/wireless/ipw2x00/libipw.h
rename to drivers/net/wireless/intel/ipw2x00/libipw.h
diff --git a/drivers/net/wireless/ipw2x00/libipw_geo.c b/drivers/net/wireless/intel/ipw2x00/libipw_geo.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/libipw_geo.c
rename to drivers/net/wireless/intel/ipw2x00/libipw_geo.c
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/libipw_module.c
rename to drivers/net/wireless/intel/ipw2x00/libipw_module.c
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/intel/ipw2x00/libipw_rx.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/libipw_rx.c
rename to drivers/net/wireless/intel/ipw2x00/libipw_rx.c
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/intel/ipw2x00/libipw_tx.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/libipw_tx.c
rename to drivers/net/wireless/intel/ipw2x00/libipw_tx.c
diff --git a/drivers/net/wireless/ipw2x00/libipw_wx.c b/drivers/net/wireless/intel/ipw2x00/libipw_wx.c
similarity index 100%
rename from drivers/net/wireless/ipw2x00/libipw_wx.c
rename to drivers/net/wireless/intel/ipw2x00/libipw_wx.c
-- 
1.7.9.5
