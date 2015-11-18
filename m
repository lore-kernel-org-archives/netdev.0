From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 09/27] iwlegacy: move under intel directory
Date: Wed, 18 Nov 2015 16:45:48 +0200
Message-ID: <1447857966-19560-10-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/intel/Kconfig                 |    1 +
 drivers/net/wireless/intel/Makefile                |    2 ++
 .../net/wireless/{ => intel}/iwlegacy/3945-debug.c |    0
 .../net/wireless/{ => intel}/iwlegacy/3945-mac.c   |    0
 .../net/wireless/{ => intel}/iwlegacy/3945-rs.c    |    0
 drivers/net/wireless/{ => intel}/iwlegacy/3945.c   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/3945.h   |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-calib.c |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-debug.c |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-mac.c   |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-rs.c    |    0
 drivers/net/wireless/{ => intel}/iwlegacy/4965.c   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/4965.h   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/Kconfig  |    0
 drivers/net/wireless/{ => intel}/iwlegacy/Makefile |    0
 .../net/wireless/{ => intel}/iwlegacy/commands.h   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/common.c |    0
 drivers/net/wireless/{ => intel}/iwlegacy/common.h |    0
 drivers/net/wireless/{ => intel}/iwlegacy/csr.h    |    0
 drivers/net/wireless/{ => intel}/iwlegacy/debug.c  |    0
 .../wireless/{ => intel}/iwlegacy/iwl-spectrum.h   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/prph.h   |    0
 25 files changed, 4 insertions(+), 3 deletions(-)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945-debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945-mac.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945-rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-calib.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-mac.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/Kconfig (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/commands.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/common.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/common.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/csr.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/iwl-spectrum.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/prph.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index b341dabeb579..83f9c2ba6962 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5641,7 +5641,7 @@ INTEL WIRELESS 3945ABG/BG, 4965AGN (iwlegacy)
 M:	Stanislaw Gruszka <sgruszka@redhat.com>
 L:	linux-wireless@vger.kernel.org
 S:	Supported
-F:	drivers/net/wireless/iwlegacy/
+F:	drivers/net/wireless/intel/iwlegacy/
 
 INTEL WIRELESS WIFI LINK (iwlwifi)
 M:	Johannes Berg <johannes.berg@intel.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 73e3b53caf45..f293831e2878 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -163,7 +163,6 @@ config MWL8K
 source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
 source "drivers/net/wireless/iwlwifi/Kconfig"
-source "drivers/net/wireless/iwlegacy/Kconfig"
 source "drivers/net/wireless/libertas/Kconfig"
 source "drivers/net/wireless/orinoco/Kconfig"
 source "drivers/net/wireless/p54/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 52946d8dd31d..135aa8753f69 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -31,7 +31,6 @@ obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
 obj-$(CONFIG_MWL8K)	+= mwl8k.o
 
 obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
-obj-$(CONFIG_IWLEGACY)	+= iwlegacy/
 obj-$(CONFIG_RT2X00)	+= rt2x00/
 
 obj-$(CONFIG_WL_MEDIATEK)	+= mediatek/
diff --git a/drivers/net/wireless/intel/Kconfig b/drivers/net/wireless/intel/Kconfig
index 3f8eacc4209a..0a7cd61e528c 100644
--- a/drivers/net/wireless/intel/Kconfig
+++ b/drivers/net/wireless/intel/Kconfig
@@ -12,5 +12,6 @@ config WLAN_VENDOR_INTEL
 if WLAN_VENDOR_INTEL
 
 source "drivers/net/wireless/intel/ipw2x00/Kconfig"
+source "drivers/net/wireless/intel/iwlegacy/Kconfig"
 
 endif # WLAN_VENDOR_INTEL
diff --git a/drivers/net/wireless/intel/Makefile b/drivers/net/wireless/intel/Makefile
index 8e5dcb2d425e..cec507d3c6bf 100644
--- a/drivers/net/wireless/intel/Makefile
+++ b/drivers/net/wireless/intel/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_IPW2100) += ipw2x00/
 obj-$(CONFIG_IPW2200) += ipw2x00/
+
+obj-$(CONFIG_IWLEGACY)	+= iwlegacy/
diff --git a/drivers/net/wireless/iwlegacy/3945-debug.c b/drivers/net/wireless/intel/iwlegacy/3945-debug.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/3945-debug.c
rename to drivers/net/wireless/intel/iwlegacy/3945-debug.c
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/intel/iwlegacy/3945-mac.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/3945-mac.c
rename to drivers/net/wireless/intel/iwlegacy/3945-mac.c
diff --git a/drivers/net/wireless/iwlegacy/3945-rs.c b/drivers/net/wireless/intel/iwlegacy/3945-rs.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/3945-rs.c
rename to drivers/net/wireless/intel/iwlegacy/3945-rs.c
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/intel/iwlegacy/3945.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/3945.c
rename to drivers/net/wireless/intel/iwlegacy/3945.c
diff --git a/drivers/net/wireless/iwlegacy/3945.h b/drivers/net/wireless/intel/iwlegacy/3945.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/3945.h
rename to drivers/net/wireless/intel/iwlegacy/3945.h
diff --git a/drivers/net/wireless/iwlegacy/4965-calib.c b/drivers/net/wireless/intel/iwlegacy/4965-calib.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/4965-calib.c
rename to drivers/net/wireless/intel/iwlegacy/4965-calib.c
diff --git a/drivers/net/wireless/iwlegacy/4965-debug.c b/drivers/net/wireless/intel/iwlegacy/4965-debug.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/4965-debug.c
rename to drivers/net/wireless/intel/iwlegacy/4965-debug.c
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/intel/iwlegacy/4965-mac.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/4965-mac.c
rename to drivers/net/wireless/intel/iwlegacy/4965-mac.c
diff --git a/drivers/net/wireless/iwlegacy/4965-rs.c b/drivers/net/wireless/intel/iwlegacy/4965-rs.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/4965-rs.c
rename to drivers/net/wireless/intel/iwlegacy/4965-rs.c
diff --git a/drivers/net/wireless/iwlegacy/4965.c b/drivers/net/wireless/intel/iwlegacy/4965.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/4965.c
rename to drivers/net/wireless/intel/iwlegacy/4965.c
diff --git a/drivers/net/wireless/iwlegacy/4965.h b/drivers/net/wireless/intel/iwlegacy/4965.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/4965.h
rename to drivers/net/wireless/intel/iwlegacy/4965.h
diff --git a/drivers/net/wireless/iwlegacy/Kconfig b/drivers/net/wireless/intel/iwlegacy/Kconfig
similarity index 100%
rename from drivers/net/wireless/iwlegacy/Kconfig
rename to drivers/net/wireless/intel/iwlegacy/Kconfig
diff --git a/drivers/net/wireless/iwlegacy/Makefile b/drivers/net/wireless/intel/iwlegacy/Makefile
similarity index 100%
rename from drivers/net/wireless/iwlegacy/Makefile
rename to drivers/net/wireless/intel/iwlegacy/Makefile
diff --git a/drivers/net/wireless/iwlegacy/commands.h b/drivers/net/wireless/intel/iwlegacy/commands.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/commands.h
rename to drivers/net/wireless/intel/iwlegacy/commands.h
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/intel/iwlegacy/common.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/common.c
rename to drivers/net/wireless/intel/iwlegacy/common.c
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/intel/iwlegacy/common.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/common.h
rename to drivers/net/wireless/intel/iwlegacy/common.h
diff --git a/drivers/net/wireless/iwlegacy/csr.h b/drivers/net/wireless/intel/iwlegacy/csr.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/csr.h
rename to drivers/net/wireless/intel/iwlegacy/csr.h
diff --git a/drivers/net/wireless/iwlegacy/debug.c b/drivers/net/wireless/intel/iwlegacy/debug.c
similarity index 100%
rename from drivers/net/wireless/iwlegacy/debug.c
rename to drivers/net/wireless/intel/iwlegacy/debug.c
diff --git a/drivers/net/wireless/iwlegacy/iwl-spectrum.h b/drivers/net/wireless/intel/iwlegacy/iwl-spectrum.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/iwl-spectrum.h
rename to drivers/net/wireless/intel/iwlegacy/iwl-spectrum.h
diff --git a/drivers/net/wireless/iwlegacy/prph.h b/drivers/net/wireless/intel/iwlegacy/prph.h
similarity index 100%
rename from drivers/net/wireless/iwlegacy/prph.h
rename to drivers/net/wireless/intel/iwlegacy/prph.h
-- 
1.7.9.5
