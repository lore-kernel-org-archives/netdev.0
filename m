From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 10/27] iwlwifi: move under intel vendor directory
Date: Wed, 18 Nov 2015 16:45:49 +0200
Message-ID: <1447857966-19560-11-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/{ => intel}/iwlwifi/Kconfig   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/Makefile  |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/Makefile  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/agn.h |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/calib.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/calib.h   |    0
 .../wireless/{ => intel}/iwlwifi/dvm/commands.h    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/debugfs.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/dev.h |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/devices.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/lib.c |    0
 .../wireless/{ => intel}/iwlwifi/dvm/mac80211.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/main.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/power.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/power.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/rx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/rxon.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/scan.c    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/sta.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/tx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/ucode.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-1000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-2000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-5000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-6000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-7000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-8000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-agn-hw.h  |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-config.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-csr.h |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-debug.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-debug.h   |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-data.h        |    0
 .../wireless/{ => intel}/iwlwifi/iwl-devtrace-io.h |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-iwlwifi.h     |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-msg.h         |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-ucode.h       |    0
 .../wireless/{ => intel}/iwlwifi/iwl-devtrace.c    |    0
 .../wireless/{ => intel}/iwlwifi/iwl-devtrace.h    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.h |    0
 .../{ => intel}/iwlwifi/iwl-eeprom-parse.c         |    0
 .../{ => intel}/iwlwifi/iwl-eeprom-parse.h         |    0
 .../wireless/{ => intel}/iwlwifi/iwl-eeprom-read.c |    0
 .../wireless/{ => intel}/iwlwifi/iwl-eeprom-read.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-fh.h  |    0
 .../{ => intel}/iwlwifi/iwl-fw-error-dump.h        |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-fw-file.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.h  |    0
 .../wireless/{ => intel}/iwlwifi/iwl-modparams.h   |    0
 .../wireless/{ => intel}/iwlwifi/iwl-notif-wait.c  |    0
 .../wireless/{ => intel}/iwlwifi/iwl-notif-wait.h  |    0
 .../wireless/{ => intel}/iwlwifi/iwl-nvm-parse.c   |    0
 .../wireless/{ => intel}/iwlwifi/iwl-nvm-parse.h   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-op-mode.h |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-phy-db.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-phy-db.h  |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-prph.h    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-scd.h |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-trans.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-trans.h   |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/Makefile  |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/binding.c |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/coex.c    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/coex_legacy.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/constants.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/d3.c  |    0
 .../wireless/{ => intel}/iwlwifi/mvm/debugfs-vif.c |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/debugfs.c |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/debugfs.h |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-coex.h |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-d3.h   |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-mac.h  |    0
 .../{ => intel}/iwlwifi/mvm/fw-api-power.h         |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-rs.h   |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-rx.h   |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-scan.h |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-sta.h  |    0
 .../{ => intel}/iwlwifi/mvm/fw-api-stats.h         |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-tof.h  |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-tx.h   |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/fw-api.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/led.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/mac-ctxt.c    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/mac80211.c    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/mvm.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/nvm.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/offloading.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/ops.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/phy-ctxt.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/power.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/quota.c   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/rx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/scan.c    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/sf.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.h |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/tdls.c    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/testmode.h    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/time-event.c  |    0
 .../wireless/{ => intel}/iwlwifi/mvm/time-event.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tt.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/utils.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/pcie/drv.c    |    0
 .../wireless/{ => intel}/iwlwifi/pcie/internal.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/pcie/rx.c |    0
 .../net/wireless/{ => intel}/iwlwifi/pcie/trans.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/pcie/tx.c |    0
 127 files changed, 4 insertions(+), 3 deletions(-)
 rename drivers/net/wireless/{ => intel}/iwlwifi/Kconfig (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/agn.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/calib.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/calib.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/commands.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/debugfs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/dev.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/devices.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/lib.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/mac80211.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/main.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/power.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/power.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rxon.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/scan.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/sta.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/tx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/ucode.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-1000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-2000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-5000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-6000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-7000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-8000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-agn-hw.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-config.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-csr.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-debug.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-data.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-io.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-iwlwifi.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-msg.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-ucode.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-parse.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-parse.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-read.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-read.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fh.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw-error-dump.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw-file.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-modparams.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-notif-wait.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-notif-wait.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-nvm-parse.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-nvm-parse.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-op-mode.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-phy-db.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-phy-db.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-prph.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-scd.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-trans.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-trans.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/binding.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/coex.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/coex_legacy.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/constants.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/d3.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/debugfs-vif.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/debugfs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/debugfs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-coex.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-d3.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-mac.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-power.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-rs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-rx.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-scan.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-sta.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-stats.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-tof.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-tx.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/led.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/mac-ctxt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/mac80211.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/mvm.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/nvm.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/offloading.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/ops.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/phy-ctxt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/power.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/quota.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/rx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/scan.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/sf.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tdls.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/testmode.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/time-event.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/time-event.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/utils.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/drv.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/internal.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/rx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/trans.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/tx.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 83f9c2ba6962..d72be8c88138 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5651,7 +5651,7 @@ L:	linux-wireless@vger.kernel.org
 W:	http://intellinuxwireless.org
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi.git
 S:	Supported
-F:	drivers/net/wireless/iwlwifi/
+F:	drivers/net/wireless/intel/iwlwifi/
 
 INTEL MANAGEMENT ENGINE (mei)
 M:	Tomas Winkler <tomas.winkler@intel.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index f293831e2878..d71efe89970b 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -162,7 +162,6 @@ config MWL8K
 
 source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
-source "drivers/net/wireless/iwlwifi/Kconfig"
 source "drivers/net/wireless/libertas/Kconfig"
 source "drivers/net/wireless/orinoco/Kconfig"
 source "drivers/net/wireless/p54/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 135aa8753f69..6bcb2925a6ce 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -30,7 +30,6 @@ obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
 
 obj-$(CONFIG_MWL8K)	+= mwl8k.o
 
-obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
 obj-$(CONFIG_RT2X00)	+= rt2x00/
 
 obj-$(CONFIG_WL_MEDIATEK)	+= mediatek/
diff --git a/drivers/net/wireless/intel/Kconfig b/drivers/net/wireless/intel/Kconfig
index 0a7cd61e528c..5b14f2f64a8a 100644
--- a/drivers/net/wireless/intel/Kconfig
+++ b/drivers/net/wireless/intel/Kconfig
@@ -13,5 +13,6 @@ if WLAN_VENDOR_INTEL
 
 source "drivers/net/wireless/intel/ipw2x00/Kconfig"
 source "drivers/net/wireless/intel/iwlegacy/Kconfig"
+source "drivers/net/wireless/intel/iwlwifi/Kconfig"
 
 endif # WLAN_VENDOR_INTEL
diff --git a/drivers/net/wireless/intel/Makefile b/drivers/net/wireless/intel/Makefile
index cec507d3c6bf..c9cbcc85b569 100644
--- a/drivers/net/wireless/intel/Makefile
+++ b/drivers/net/wireless/intel/Makefile
@@ -2,3 +2,5 @@ obj-$(CONFIG_IPW2100) += ipw2x00/
 obj-$(CONFIG_IPW2200) += ipw2x00/
 
 obj-$(CONFIG_IWLEGACY)	+= iwlegacy/
+
+obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/intel/iwlwifi/Kconfig
similarity index 100%
rename from drivers/net/wireless/iwlwifi/Kconfig
rename to drivers/net/wireless/intel/iwlwifi/Kconfig
diff --git a/drivers/net/wireless/iwlwifi/Makefile b/drivers/net/wireless/intel/iwlwifi/Makefile
similarity index 100%
rename from drivers/net/wireless/iwlwifi/Makefile
rename to drivers/net/wireless/intel/iwlwifi/Makefile
diff --git a/drivers/net/wireless/iwlwifi/dvm/Makefile b/drivers/net/wireless/intel/iwlwifi/dvm/Makefile
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/Makefile
rename to drivers/net/wireless/intel/iwlwifi/dvm/Makefile
diff --git a/drivers/net/wireless/iwlwifi/dvm/agn.h b/drivers/net/wireless/intel/iwlwifi/dvm/agn.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/agn.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/agn.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/calib.c b/drivers/net/wireless/intel/iwlwifi/dvm/calib.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/calib.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/calib.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/calib.h b/drivers/net/wireless/intel/iwlwifi/dvm/calib.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/calib.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/calib.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/commands.h b/drivers/net/wireless/intel/iwlwifi/dvm/commands.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/commands.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/commands.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/debugfs.c b/drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/debugfs.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/dev.h b/drivers/net/wireless/intel/iwlwifi/dvm/dev.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/dev.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/dev.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/devices.c b/drivers/net/wireless/intel/iwlwifi/dvm/devices.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/devices.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/devices.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/led.c b/drivers/net/wireless/intel/iwlwifi/dvm/led.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/led.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/led.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/led.h b/drivers/net/wireless/intel/iwlwifi/dvm/led.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/led.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/led.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/lib.c b/drivers/net/wireless/intel/iwlwifi/dvm/lib.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/lib.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/lib.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/mac80211.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/main.c b/drivers/net/wireless/intel/iwlwifi/dvm/main.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/main.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/main.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/power.c b/drivers/net/wireless/intel/iwlwifi/dvm/power.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/power.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/power.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/power.h b/drivers/net/wireless/intel/iwlwifi/dvm/power.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/power.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/power.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/rs.c b/drivers/net/wireless/intel/iwlwifi/dvm/rs.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/rs.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/rs.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/rs.h b/drivers/net/wireless/intel/iwlwifi/dvm/rs.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/rs.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/rs.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/rx.c b/drivers/net/wireless/intel/iwlwifi/dvm/rx.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/rx.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/rx.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/rxon.c b/drivers/net/wireless/intel/iwlwifi/dvm/rxon.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/rxon.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/rxon.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/scan.c b/drivers/net/wireless/intel/iwlwifi/dvm/scan.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/scan.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/scan.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/sta.c b/drivers/net/wireless/intel/iwlwifi/dvm/sta.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/sta.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/sta.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/tt.c b/drivers/net/wireless/intel/iwlwifi/dvm/tt.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/tt.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/tt.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/tt.h b/drivers/net/wireless/intel/iwlwifi/dvm/tt.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/tt.h
rename to drivers/net/wireless/intel/iwlwifi/dvm/tt.h
diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/intel/iwlwifi/dvm/tx.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/tx.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/tx.c
diff --git a/drivers/net/wireless/iwlwifi/dvm/ucode.c b/drivers/net/wireless/intel/iwlwifi/dvm/ucode.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/dvm/ucode.c
rename to drivers/net/wireless/intel/iwlwifi/dvm/ucode.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/intel/iwlwifi/iwl-1000.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-1000.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-1000.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-2000.c b/drivers/net/wireless/intel/iwlwifi/iwl-2000.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-2000.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-2000.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/intel/iwlwifi/iwl-5000.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-5000.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-5000.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/intel/iwlwifi/iwl-6000.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-6000.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-6000.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-7000.c b/drivers/net/wireless/intel/iwlwifi/iwl-7000.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-7000.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-7000.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-8000.c b/drivers/net/wireless/intel/iwlwifi/iwl-8000.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-8000.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-8000.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-hw.h b/drivers/net/wireless/intel/iwlwifi/iwl-agn-hw.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-agn-hw.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-agn-hw.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-config.h b/drivers/net/wireless/intel/iwlwifi/iwl-config.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-config.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-config.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-csr.h b/drivers/net/wireless/intel/iwlwifi/iwl-csr.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-csr.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-csr.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.c b/drivers/net/wireless/intel/iwlwifi/iwl-debug.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-debug.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-debug.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/intel/iwlwifi/iwl-debug.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-debug.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-debug.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-data.h b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace-data.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace-data.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace-data.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-io.h b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace-io.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace-io.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace-io.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace-iwlwifi.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace-iwlwifi.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-msg.h b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace-msg.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace-msg.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace-msg.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-ucode.h b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace-ucode.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace-ucode.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace-ucode.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.c b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.h b/drivers/net/wireless/intel/iwlwifi/iwl-devtrace.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-devtrace.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-devtrace.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-drv.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-drv.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.h b/drivers/net/wireless/intel/iwlwifi/iwl-drv.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-drv.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-drv.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c b/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h b/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom-read.c b/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-eeprom-read.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom-read.h b/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-eeprom-read.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-fh.h b/drivers/net/wireless/intel/iwlwifi/iwl-fh.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-fh.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-fh.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h b/drivers/net/wireless/intel/iwlwifi/iwl-fw-error-dump.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-fw-error-dump.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-fw-file.h b/drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-fw-file.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-fw.h b/drivers/net/wireless/intel/iwlwifi/iwl-fw.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-fw.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-fw.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-io.c b/drivers/net/wireless/intel/iwlwifi/iwl-io.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-io.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-io.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-io.h b/drivers/net/wireless/intel/iwlwifi/iwl-io.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-io.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-io.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-modparams.h b/drivers/net/wireless/intel/iwlwifi/iwl-modparams.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-modparams.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-modparams.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-notif-wait.c b/drivers/net/wireless/intel/iwlwifi/iwl-notif-wait.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-notif-wait.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-notif-wait.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-notif-wait.h b/drivers/net/wireless/intel/iwlwifi/iwl-notif-wait.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-notif-wait.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-notif-wait.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-nvm-parse.c b/drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-nvm-parse.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-nvm-parse.h b/drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-nvm-parse.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-op-mode.h b/drivers/net/wireless/intel/iwlwifi/iwl-op-mode.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-op-mode.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-op-mode.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-phy-db.c b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-phy-db.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-phy-db.h b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-phy-db.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-phy-db.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-prph.h b/drivers/net/wireless/intel/iwlwifi/iwl-prph.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-prph.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-prph.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-scd.h b/drivers/net/wireless/intel/iwlwifi/iwl-scd.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-scd.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-scd.h
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.c b/drivers/net/wireless/intel/iwlwifi/iwl-trans.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-trans.c
rename to drivers/net/wireless/intel/iwlwifi/iwl-trans.c
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireless/intel/iwlwifi/iwl-trans.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/iwl-trans.h
rename to drivers/net/wireless/intel/iwlwifi/iwl-trans.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/Makefile b/drivers/net/wireless/intel/iwlwifi/mvm/Makefile
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/Makefile
rename to drivers/net/wireless/intel/iwlwifi/mvm/Makefile
diff --git a/drivers/net/wireless/iwlwifi/mvm/binding.c b/drivers/net/wireless/intel/iwlwifi/mvm/binding.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/binding.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/binding.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex.c b/drivers/net/wireless/intel/iwlwifi/mvm/coex.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/coex.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/coex.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex_legacy.c b/drivers/net/wireless/intel/iwlwifi/mvm/coex_legacy.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/coex_legacy.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/coex_legacy.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/constants.h b/drivers/net/wireless/intel/iwlwifi/mvm/constants.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/constants.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/constants.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/d3.c b/drivers/net/wireless/intel/iwlwifi/mvm/d3.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/d3.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/d3.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c b/drivers/net/wireless/intel/iwlwifi/mvm/debugfs-vif.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/debugfs-vif.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs.c b/drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/debugfs.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs.h b/drivers/net/wireless/intel/iwlwifi/mvm/debugfs.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/debugfs.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/debugfs.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-coex.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-coex.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-mac.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-mac.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-power.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-power.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-power.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-power.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-rx.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-rx.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-scan.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-scan.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-sta.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-sta.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-stats.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-stats.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-stats.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-stats.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-tof.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tof.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-tof.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tof.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api.h b/drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw-api.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw.c b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/fw.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/fw.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/led.c b/drivers/net/wireless/intel/iwlwifi/mvm/led.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/led.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/led.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c b/drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/mac80211.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/intel/iwlwifi/mvm/mvm.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/mvm.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/mvm.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/nvm.c b/drivers/net/wireless/intel/iwlwifi/mvm/nvm.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/nvm.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/nvm.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/offloading.c b/drivers/net/wireless/intel/iwlwifi/mvm/offloading.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/offloading.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/offloading.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c b/drivers/net/wireless/intel/iwlwifi/mvm/ops.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/ops.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/ops.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c b/drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/power.c b/drivers/net/wireless/intel/iwlwifi/mvm/power.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/power.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/power.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/quota.c b/drivers/net/wireless/intel/iwlwifi/mvm/quota.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/quota.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/quota.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.c b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/rs.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/rs.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.h b/drivers/net/wireless/intel/iwlwifi/mvm/rs.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/rs.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/rs.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/rx.c b/drivers/net/wireless/intel/iwlwifi/mvm/rx.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/rx.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/rx.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless/intel/iwlwifi/mvm/scan.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/scan.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/scan.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/sf.c b/drivers/net/wireless/intel/iwlwifi/mvm/sf.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/sf.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/sf.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/intel/iwlwifi/mvm/sta.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/sta.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/sta.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.h b/drivers/net/wireless/intel/iwlwifi/mvm/sta.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/sta.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/sta.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/tdls.c b/drivers/net/wireless/intel/iwlwifi/mvm/tdls.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/tdls.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/tdls.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/testmode.h b/drivers/net/wireless/intel/iwlwifi/mvm/testmode.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/testmode.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/testmode.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wireless/intel/iwlwifi/mvm/time-event.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/time-event.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/time-event.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.h b/drivers/net/wireless/intel/iwlwifi/mvm/time-event.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/time-event.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/time-event.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/tof.c b/drivers/net/wireless/intel/iwlwifi/mvm/tof.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/tof.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/tof.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/tof.h b/drivers/net/wireless/intel/iwlwifi/mvm/tof.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/tof.h
rename to drivers/net/wireless/intel/iwlwifi/mvm/tof.h
diff --git a/drivers/net/wireless/iwlwifi/mvm/tt.c b/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/tt.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/tt.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/tx.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/tx.c
diff --git a/drivers/net/wireless/iwlwifi/mvm/utils.c b/drivers/net/wireless/intel/iwlwifi/mvm/utils.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/mvm/utils.c
rename to drivers/net/wireless/intel/iwlwifi/mvm/utils.c
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/pcie/drv.c
rename to drivers/net/wireless/intel/iwlwifi/pcie/drv.c
diff --git a/drivers/net/wireless/iwlwifi/pcie/internal.h b/drivers/net/wireless/intel/iwlwifi/pcie/internal.h
similarity index 100%
rename from drivers/net/wireless/iwlwifi/pcie/internal.h
rename to drivers/net/wireless/intel/iwlwifi/pcie/internal.h
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/intel/iwlwifi/pcie/rx.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/pcie/rx.c
rename to drivers/net/wireless/intel/iwlwifi/pcie/rx.c
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wireless/intel/iwlwifi/pcie/trans.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/pcie/trans.c
rename to drivers/net/wireless/intel/iwlwifi/pcie/trans.c
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
similarity index 100%
rename from drivers/net/wireless/iwlwifi/pcie/tx.c
rename to drivers/net/wireless/intel/iwlwifi/pcie/tx.c
-- 
1.7.9.5
