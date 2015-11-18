From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 06/27] brcm80211: move under broadcom vendor directory
Date: Wed, 18 Nov 2015 16:45:45 +0200
Message-ID: <1447857966-19560-7-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part of reorganising wireless drivers directory and Kconfig. Note that I had to
edit Makefiles from subdirectories to use the new location.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/Kconfig                       |    1 -
 drivers/net/wireless/Makefile                      |    3 ---
 drivers/net/wireless/broadcom/Kconfig              |    1 +
 drivers/net/wireless/broadcom/Makefile             |    3 +++
 .../net/wireless/{ => broadcom}/brcm80211/Kconfig  |    0
 .../net/wireless/{ => broadcom}/brcm80211/Makefile |    0
 .../{ => broadcom}/brcm80211/brcmfmac/Makefile     |    4 ++--
 .../{ => broadcom}/brcm80211/brcmfmac/bcdc.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/bcdc.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/bcmsdh.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/btcoex.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/btcoex.h     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/bus.h        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/cfg80211.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/cfg80211.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/chip.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/chip.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/common.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/common.h     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/commonring.c |    0
 .../{ => broadcom}/brcm80211/brcmfmac/commonring.h |    0
 .../{ => broadcom}/brcm80211/brcmfmac/core.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/core.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/debug.c      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/debug.h      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/feature.c    |    0
 .../{ => broadcom}/brcm80211/brcmfmac/feature.h    |    0
 .../{ => broadcom}/brcm80211/brcmfmac/firmware.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/firmware.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/flowring.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/flowring.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fweh.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fweh.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwil.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwil.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwil_types.h |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwsignal.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwsignal.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/msgbuf.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/msgbuf.h     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/of.c         |    0
 .../{ => broadcom}/brcm80211/brcmfmac/of.h         |    0
 .../{ => broadcom}/brcm80211/brcmfmac/p2p.c        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/p2p.h        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/pcie.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/pcie.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/proto.c      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/proto.h      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/sdio.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/sdio.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/tracepoint.c |    0
 .../{ => broadcom}/brcm80211/brcmfmac/tracepoint.h |    0
 .../{ => broadcom}/brcm80211/brcmfmac/usb.c        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/usb.h        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/vendor.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/vendor.h     |    0
 .../{ => broadcom}/brcm80211/brcmsmac/Makefile     |    6 +++---
 .../{ => broadcom}/brcm80211/brcmsmac/aiutils.c    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/aiutils.h    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/ampdu.c      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/ampdu.h      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/antsel.c     |    0
 .../{ => broadcom}/brcm80211/brcmsmac/antsel.h     |    0
 .../brcm80211/brcmsmac/brcms_trace_brcmsmac.h      |    0
 .../brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h  |    0
 .../brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h   |    0
 .../brcm80211/brcmsmac/brcms_trace_events.c        |    0
 .../brcm80211/brcmsmac/brcms_trace_events.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/channel.c    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/channel.h    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/d11.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/debug.c      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/debug.h      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/dma.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/dma.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/led.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/led.h        |    0
 .../brcm80211/brcmsmac/mac80211_if.c               |    0
 .../brcm80211/brcmsmac/mac80211_if.h               |    0
 .../{ => broadcom}/brcm80211/brcmsmac/main.c       |    0
 .../{ => broadcom}/brcm80211/brcmsmac/main.h       |    0
 .../brcm80211/brcmsmac/phy/phy_cmn.c               |    0
 .../brcm80211/brcmsmac/phy/phy_hal.h               |    0
 .../brcm80211/brcmsmac/phy/phy_int.h               |    0
 .../brcm80211/brcmsmac/phy/phy_lcn.c               |    0
 .../brcm80211/brcmsmac/phy/phy_lcn.h               |    0
 .../{ => broadcom}/brcm80211/brcmsmac/phy/phy_n.c  |    0
 .../brcm80211/brcmsmac/phy/phy_qmath.c             |    0
 .../brcm80211/brcmsmac/phy/phy_qmath.h             |    0
 .../brcm80211/brcmsmac/phy/phy_radio.h             |    0
 .../brcm80211/brcmsmac/phy/phyreg_n.h              |    0
 .../brcm80211/brcmsmac/phy/phytbl_lcn.c            |    0
 .../brcm80211/brcmsmac/phy/phytbl_lcn.h            |    0
 .../brcm80211/brcmsmac/phy/phytbl_n.c              |    0
 .../brcm80211/brcmsmac/phy/phytbl_n.h              |    0
 .../{ => broadcom}/brcm80211/brcmsmac/phy_shim.c   |    0
 .../{ => broadcom}/brcm80211/brcmsmac/phy_shim.h   |    0
 .../{ => broadcom}/brcm80211/brcmsmac/pmu.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/pmu.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/pub.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/rate.c       |    0
 .../{ => broadcom}/brcm80211/brcmsmac/rate.h       |    0
 .../{ => broadcom}/brcm80211/brcmsmac/scb.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/stf.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/stf.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/types.h      |    0
 .../brcm80211/brcmsmac/ucode_loader.c              |    0
 .../brcm80211/brcmsmac/ucode_loader.h              |    0
 .../{ => broadcom}/brcm80211/brcmutil/Makefile     |    4 ++--
 .../{ => broadcom}/brcm80211/brcmutil/d11.c        |    0
 .../{ => broadcom}/brcm80211/brcmutil/utils.c      |    0
 .../{ => broadcom}/brcm80211/include/brcm_hw_ids.h |    0
 .../{ => broadcom}/brcm80211/include/brcmu_d11.h   |    0
 .../{ => broadcom}/brcm80211/include/brcmu_utils.h |    0
 .../{ => broadcom}/brcm80211/include/brcmu_wifi.h  |    0
 .../{ => broadcom}/brcm80211/include/chipcommon.h  |    0
 .../{ => broadcom}/brcm80211/include/defs.h        |    0
 .../{ => broadcom}/brcm80211/include/soc.h         |    0
 119 files changed, 12 insertions(+), 12 deletions(-)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/Kconfig (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/Makefile (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/Makefile (93%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bcdc.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bcdc.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bcmsdh.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/btcoex.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/btcoex.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bus.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/cfg80211.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/cfg80211.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/chip.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/chip.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/common.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/common.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/commonring.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/commonring.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/core.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/core.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/debug.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/debug.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/feature.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/feature.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/firmware.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/firmware.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/flowring.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/flowring.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fweh.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fweh.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwil.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwil.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwil_types.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwsignal.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwsignal.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/msgbuf.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/msgbuf.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/of.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/of.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/p2p.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/p2p.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/pcie.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/pcie.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/proto.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/proto.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/sdio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/sdio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/tracepoint.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/tracepoint.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/usb.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/usb.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/vendor.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/vendor.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/Makefile (88%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/aiutils.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/aiutils.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ampdu.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ampdu.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/antsel.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/antsel.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_brcmsmac.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_events.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_events.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/channel.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/channel.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/d11.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/debug.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/debug.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/dma.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/dma.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/led.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/led.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/mac80211_if.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/mac80211_if.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/main.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/main.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_cmn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_hal.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_int.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_n.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_qmath.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_qmath.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_radio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phyreg_n.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_n.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_n.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy_shim.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy_shim.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/pmu.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/pmu.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/pub.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/rate.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/rate.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/scb.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/stf.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/stf.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/types.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ucode_loader.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ucode_loader.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmutil/Makefile (89%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmutil/d11.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmutil/utils.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcm_hw_ids.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcmu_d11.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcmu_utils.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcmu_wifi.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/chipcommon.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/defs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/soc.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index dd20c0b1eb02..748ee82f2ebe 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2390,7 +2390,7 @@ M:	Hante Meuleman <meuleman@broadcom.com>
 L:	linux-wireless@vger.kernel.org
 L:	brcm80211-dev-list@broadcom.com
 S:	Supported
-F:	drivers/net/wireless/brcm80211/
+F:	drivers/net/wireless/broadcom/brcm80211/
 
 BROADCOM BNX2FC 10 GIGABIT FCOE DRIVER
 M:	QLogic-Storage-Upstream@qlogic.com
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index e261df26b0dd..c627d9e41ede 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -159,7 +159,6 @@ config MWL8K
 	  will be called mwl8k.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/brcm80211/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
 source "drivers/net/wireless/ipw2x00/Kconfig"
 source "drivers/net/wireless/iwlwifi/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 13ac61737acd..41ebe5641c01 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -47,8 +47,5 @@ obj-$(CONFIG_WL_TI)	+= ti/
 
 obj-$(CONFIG_MWIFIEX)	+= mwifiex/
 
-obj-$(CONFIG_BRCMFMAC)	+= brcm80211/
-obj-$(CONFIG_BRCMSMAC)	+= brcm80211/
-
 obj-$(CONFIG_CW1200)	+= cw1200/
 obj-$(CONFIG_RSI_91X)	+= rsi/
diff --git a/drivers/net/wireless/broadcom/Kconfig b/drivers/net/wireless/broadcom/Kconfig
index 323e738dd96f..d3651ceb5046 100644
--- a/drivers/net/wireless/broadcom/Kconfig
+++ b/drivers/net/wireless/broadcom/Kconfig
@@ -13,5 +13,6 @@ if WLAN_VENDOR_BROADCOM
 
 source "drivers/net/wireless/broadcom/b43/Kconfig"
 source "drivers/net/wireless/broadcom/b43legacy/Kconfig"
+source "drivers/net/wireless/broadcom/brcm80211/Kconfig"
 
 endif # WLAN_VENDOR_BROADCOM
diff --git a/drivers/net/wireless/broadcom/Makefile b/drivers/net/wireless/broadcom/Makefile
index 66d7cc461fcf..9d5ac95710c3 100644
--- a/drivers/net/wireless/broadcom/Makefile
+++ b/drivers/net/wireless/broadcom/Makefile
@@ -1,2 +1,5 @@
 obj-$(CONFIG_B43)		+= b43/
 obj-$(CONFIG_B43LEGACY)		+= b43legacy/
+
+obj-$(CONFIG_BRCMFMAC)	+= brcm80211/
+obj-$(CONFIG_BRCMSMAC)	+= brcm80211/
diff --git a/drivers/net/wireless/brcm80211/Kconfig b/drivers/net/wireless/broadcom/brcm80211/Kconfig
similarity index 100%
rename from drivers/net/wireless/brcm80211/Kconfig
rename to drivers/net/wireless/broadcom/brcm80211/Kconfig
diff --git a/drivers/net/wireless/brcm80211/Makefile b/drivers/net/wireless/broadcom/brcm80211/Makefile
similarity index 100%
rename from drivers/net/wireless/brcm80211/Makefile
rename to drivers/net/wireless/broadcom/brcm80211/Makefile
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
similarity index 93%
rename from drivers/net/wireless/brcm80211/brcmfmac/Makefile
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
index dc4c75083085..9e4b505ca593 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
@@ -16,8 +16,8 @@
 # CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 
 ccflags-y += \
-	-Idrivers/net/wireless/brcm80211/brcmfmac	\
-	-Idrivers/net/wireless/brcm80211/include
+	-Idrivers/net/wireless/broadcom/brcm80211/brcmfmac	\
+	-Idrivers/net/wireless/broadcom/brcm80211/include
 
 ccflags-y += -D__CHECK_ENDIAN__
 
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/bcdc.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/btcoex.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/btcoex.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/btcoex.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/btcoex.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bus.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bus.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/bus.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/bus.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/cfg80211.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/chip.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/chip.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/chip.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/chip.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/common.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/common.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/common.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/common.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/commonring.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/commonring.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/commonring.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/commonring.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/commonring.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/commonring.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/commonring.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/commonring.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/core.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/core.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/core.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/debug.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/debug.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/debug.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/debug.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/debug.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/debug.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/debug.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/debug.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/feature.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/feature.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/feature.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/feature.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/feature.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/feature.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/feature.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/feature.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/firmware.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/firmware.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/firmware.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/firmware.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/flowring.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/flowring.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/flowring.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/flowring.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fweh.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fweh.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwil.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fwil.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwil.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fwil.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil_types.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil_types.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/of.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/of.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/of.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/of.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/of.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/of.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/of.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/of.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/p2p.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/p2p.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/pcie.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/pcie.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/pcie.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/proto.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/proto.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/proto.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/proto.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/sdio.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/sdio.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/tracepoint.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/tracepoint.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/tracepoint.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/tracepoint.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/usb.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/usb.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.h
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/vendor.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/vendor.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/vendor.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/vendor.c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/vendor.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/vendor.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmfmac/vendor.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmfmac/vendor.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile
similarity index 88%
rename from drivers/net/wireless/brcm80211/brcmsmac/Makefile
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile
index 32464acccd90..960e6b86bbcb 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile
@@ -17,9 +17,9 @@
 
 ccflags-y := \
 	-D__CHECK_ENDIAN__ \
-	-Idrivers/net/wireless/brcm80211/brcmsmac \
-	-Idrivers/net/wireless/brcm80211/brcmsmac/phy \
-	-Idrivers/net/wireless/brcm80211/include
+	-Idrivers/net/wireless/broadcom/brcm80211/brcmsmac \
+	-Idrivers/net/wireless/broadcom/brcm80211/brcmsmac/phy \
+	-Idrivers/net/wireless/broadcom/brcm80211/include
 
 brcmsmac-y := \
 	mac80211_if.o \
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/aiutils.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/aiutils.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/aiutils.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/aiutils.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/aiutils.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/ampdu.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/ampdu.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/ampdu.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/ampdu.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/ampdu.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/antsel.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/antsel.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/antsel.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/antsel.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/antsel.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/antsel.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/antsel.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/antsel.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_brcmsmac.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_brcmsmac.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_brcmsmac.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_brcmsmac.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_events.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_events.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_events.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_events.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_events.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_events.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_events.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/brcms_trace_events.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/channel.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/channel.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/channel.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/channel.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/channel.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/channel.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/channel.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/channel.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/d11.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/d11.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/d11.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/d11.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/debug.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/debug.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/debug.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/debug.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/debug.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/debug.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/debug.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/debug.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/dma.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/dma.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/dma.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/dma.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/dma.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/dma.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/led.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/led.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/led.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/led.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/led.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/led.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/led.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/led.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/mac80211_if.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/mac80211_if.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/mac80211_if.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/mac80211_if.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/main.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/main.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_hal.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_hal.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_int.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_int.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_qmath.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_qmath.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_qmath.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_qmath.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_qmath.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_qmath.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_qmath.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_qmath.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_radio.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_radio.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phy_radio.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_radio.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phyreg_n.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phyreg_n.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phyreg_n.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phyreg_n.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_lcn.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_lcn.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_lcn.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_lcn.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_n.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_n.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_n.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy_shim.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy_shim.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy_shim.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy_shim.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy_shim.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy_shim.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/pmu.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/pmu.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/pmu.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/pmu.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/pmu.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/pmu.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/pmu.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/pmu.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/pub.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/pub.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/pub.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/pub.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/rate.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/rate.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/rate.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/rate.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/rate.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/rate.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/rate.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/rate.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/scb.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/scb.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/scb.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/scb.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/stf.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/stf.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/stf.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/stf.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/stf.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/stf.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/stf.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/stf.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/types.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/types.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/types.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/types.h
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/ucode_loader.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/ucode_loader.c
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/ucode_loader.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h
rename to drivers/net/wireless/broadcom/brcm80211/brcmsmac/ucode_loader.h
diff --git a/drivers/net/wireless/brcm80211/brcmutil/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmutil/Makefile
similarity index 89%
rename from drivers/net/wireless/brcm80211/brcmutil/Makefile
rename to drivers/net/wireless/broadcom/brcm80211/brcmutil/Makefile
index 8a928184016a..256c91f9ac4b 100644
--- a/drivers/net/wireless/brcm80211/brcmutil/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmutil/Makefile
@@ -16,8 +16,8 @@
 # CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 
 ccflags-y :=				\
-	-Idrivers/net/wireless/brcm80211/brcmutil \
-	-Idrivers/net/wireless/brcm80211/include
+	-Idrivers/net/wireless/broadcom/brcm80211/brcmutil \
+	-Idrivers/net/wireless/broadcom/brcm80211/include
 
 obj-$(CONFIG_BRCMUTIL)	+= brcmutil.o
 brcmutil-objs	= utils.o d11.o
diff --git a/drivers/net/wireless/brcm80211/brcmutil/d11.c b/drivers/net/wireless/broadcom/brcm80211/brcmutil/d11.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmutil/d11.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmutil/d11.c
diff --git a/drivers/net/wireless/brcm80211/brcmutil/utils.c b/drivers/net/wireless/broadcom/brcm80211/brcmutil/utils.c
similarity index 100%
rename from drivers/net/wireless/brcm80211/brcmutil/utils.c
rename to drivers/net/wireless/broadcom/brcm80211/brcmutil/utils.c
diff --git a/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h b/drivers/net/wireless/broadcom/brcm80211/include/brcm_hw_ids.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
rename to drivers/net/wireless/broadcom/brcm80211/include/brcm_hw_ids.h
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_d11.h b/drivers/net/wireless/broadcom/brcm80211/include/brcmu_d11.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/brcmu_d11.h
rename to drivers/net/wireless/broadcom/brcm80211/include/brcmu_d11.h
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_utils.h b/drivers/net/wireless/broadcom/brcm80211/include/brcmu_utils.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/brcmu_utils.h
rename to drivers/net/wireless/broadcom/brcm80211/include/brcmu_utils.h
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_wifi.h b/drivers/net/wireless/broadcom/brcm80211/include/brcmu_wifi.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/brcmu_wifi.h
rename to drivers/net/wireless/broadcom/brcm80211/include/brcmu_wifi.h
diff --git a/drivers/net/wireless/brcm80211/include/chipcommon.h b/drivers/net/wireless/broadcom/brcm80211/include/chipcommon.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/chipcommon.h
rename to drivers/net/wireless/broadcom/brcm80211/include/chipcommon.h
diff --git a/drivers/net/wireless/brcm80211/include/defs.h b/drivers/net/wireless/broadcom/brcm80211/include/defs.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/defs.h
rename to drivers/net/wireless/broadcom/brcm80211/include/defs.h
diff --git a/drivers/net/wireless/brcm80211/include/soc.h b/drivers/net/wireless/broadcom/brcm80211/include/soc.h
similarity index 100%
rename from drivers/net/wireless/brcm80211/include/soc.h
rename to drivers/net/wireless/broadcom/brcm80211/include/soc.h
-- 
1.7.9.5
