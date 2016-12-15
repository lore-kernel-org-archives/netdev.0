From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 8/8] Makefile: drop -D__CHECK_ENDIAN__ from cflags
Date: Thu, 15 Dec 2016 07:15:30 +0200
Message-ID: <1481778865-27667-9-git-send-email-mst@redhat.com>
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
 Stanislaw Gruszka <sgruszka@redhat.com>, Gustavo Padovan <gustavo@padovan.org>,
 Arend van Spriel <arend.vanspriel@broadcom.com>,
 Luca Coelho <luciano.coelho@intel.com>, devel@driverdev.osuosl.org,
 Jakub Kicinski <kubakici@wp.pl>, Stefan Schmidt <stefan@osg.samsung.com>,
 linux-mediatek@lists.infradead.org, wil6210@qca.qualcomm.com,
 linux-arm-kernel@lists.infradead.org, Chris Snook <chris.snook@gmail.com>,
 Wolfgang Grandegger <wg@grandegger.com>, Jay Cliburn <jcliburn@gmail.com>,
 linux-wpan@vger.kernel.org, Johan Hedberg <johan.hedberg@gmail.com>,
 Johannes Berg <johannes.berg@intel.com>,
 Intel Linux Wireless <linuxwifi@intel.com>,
 Alexander Aring <aar@pengutronix.de>, Marcel Holtmann <marcel@holtmann.org>,
 Hante Meuleman <hante.meuleman@broadcom.com>, linux-can@vger.kernel.org,
 Marc Kleine-Budde <mkl@pengutronix.de>,
 Matthi
To: linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1481778865-27667-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

That's the default now, no need for makefiles to set it.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/bluetooth/Makefile                                | 2 --
 drivers/net/can/Makefile                                  | 1 -
 drivers/net/ethernet/altera/Makefile                      | 1 -
 drivers/net/ethernet/atheros/alx/Makefile                 | 1 -
 drivers/net/ethernet/freescale/Makefile                   | 2 --
 drivers/net/wireless/ath/Makefile                         | 2 --
 drivers/net/wireless/ath/wil6210/Makefile                 | 2 --
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile | 2 --
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile | 1 -
 drivers/net/wireless/intel/iwlegacy/Makefile              | 2 --
 drivers/net/wireless/intel/iwlwifi/Makefile               | 2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/Makefile           | 2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile           | 2 +-
 drivers/net/wireless/intersil/orinoco/Makefile            | 3 ---
 drivers/net/wireless/mediatek/mt7601u/Makefile            | 2 --
 drivers/net/wireless/realtek/rtlwifi/Makefile             | 2 --
 drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile    | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile   | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile  | 2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile   | 2 --
 drivers/net/wireless/ti/wl1251/Makefile                   | 2 --
 drivers/net/wireless/ti/wlcore/Makefile                   | 2 --
 drivers/staging/rtl8188eu/Makefile                        | 2 +-
 drivers/staging/rtl8192e/Makefile                         | 2 --
 drivers/staging/rtl8192e/rtl8192e/Makefile                | 2 --
 net/bluetooth/Makefile                                    | 2 --
 net/ieee802154/Makefile                                   | 2 --
 net/mac80211/Makefile                                     | 2 +-
 net/mac802154/Makefile                                    | 2 --
 net/wireless/Makefile                                     | 2 --
 38 files changed, 5 insertions(+), 68 deletions(-)

diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index b1fc29a..8062718 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -40,5 +40,3 @@ hci_uart-$(CONFIG_BT_HCIUART_QCA)	+= hci_qca.o
 hci_uart-$(CONFIG_BT_HCIUART_AG6XX)	+= hci_ag6xx.o
 hci_uart-$(CONFIG_BT_HCIUART_MRVL)	+= hci_mrvl.o
 hci_uart-objs				:= $(hci_uart-y)
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 26ba4b7..7a85495 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -31,5 +31,4 @@ obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_XILINXCAN)	+= xilinx_can.o
 obj-$(CONFIG_PCH_CAN)		+= pch_can.o
 
-subdir-ccflags-y += -D__CHECK_ENDIAN__
 subdir-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) += -DDEBUG
diff --git a/drivers/net/ethernet/altera/Makefile b/drivers/net/ethernet/altera/Makefile
index 3eff2fd..d4a187e 100644
--- a/drivers/net/ethernet/altera/Makefile
+++ b/drivers/net/ethernet/altera/Makefile
@@ -5,4 +5,3 @@
 obj-$(CONFIG_ALTERA_TSE) += altera_tse.o
 altera_tse-objs := altera_tse_main.o altera_tse_ethtool.o \
 altera_msgdma.o altera_sgdma.o altera_utils.o
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/ethernet/atheros/alx/Makefile b/drivers/net/ethernet/atheros/alx/Makefile
index 5901fa4..ed4a605 100644
--- a/drivers/net/ethernet/atheros/alx/Makefile
+++ b/drivers/net/ethernet/atheros/alx/Makefile
@@ -1,3 +1,2 @@
 obj-$(CONFIG_ALX) += alx.o
 alx-objs := main.o ethtool.o hw.o
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
index 4a13115..c46df5c 100644
--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -4,8 +4,6 @@
 
 obj-$(CONFIG_FEC) += fec.o
 fec-objs :=fec_main.o fec_ptp.o
-CFLAGS_fec_main.o := -D__CHECK_ENDIAN__
-CFLAGS_fec_ptp.o := -D__CHECK_ENDIAN__
 
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
diff --git a/drivers/net/wireless/ath/Makefile b/drivers/net/wireless/ath/Makefile
index 89f8d59..4cdebc7 100644
--- a/drivers/net/wireless/ath/Makefile
+++ b/drivers/net/wireless/ath/Makefile
@@ -19,6 +19,4 @@ ath-objs :=	main.o \
 ath-$(CONFIG_ATH_DEBUG) += debug.o
 ath-$(CONFIG_ATH_TRACEPOINTS) += trace.o
 
-ccflags-y += -D__CHECK_ENDIAN__
-
 CFLAGS_trace.o := -I$(src)
diff --git a/drivers/net/wireless/ath/wil6210/Makefile b/drivers/net/wireless/ath/wil6210/Makefile
index 11b544b..89bf2f9 100644
--- a/drivers/net/wireless/ath/wil6210/Makefile
+++ b/drivers/net/wireless/ath/wil6210/Makefile
@@ -22,5 +22,3 @@ wil6210-y += p2p.o
 
 # for tracing framework to find trace.h
 CFLAGS_trace.o := -I$(src)
-
-subdir-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
index d1568be..0383ba5 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile
@@ -19,8 +19,6 @@ ccflags-y += \
 	-Idrivers/net/wireless/broadcom/brcm80211/brcmfmac	\
 	-Idrivers/net/wireless/broadcom/brcm80211/include
 
-ccflags-y += -D__CHECK_ENDIAN__
-
 obj-$(CONFIG_BRCMFMAC) += brcmfmac.o
 brcmfmac-objs += \
 		cfg80211.o \
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile
index 960e6b8..ed83f33 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile
@@ -16,7 +16,6 @@
 # CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 
 ccflags-y := \
-	-D__CHECK_ENDIAN__ \
 	-Idrivers/net/wireless/broadcom/brcm80211/brcmsmac \
 	-Idrivers/net/wireless/broadcom/brcm80211/brcmsmac/phy \
 	-Idrivers/net/wireless/broadcom/brcm80211/include
diff --git a/drivers/net/wireless/intel/iwlegacy/Makefile b/drivers/net/wireless/intel/iwlegacy/Makefile
index c985a01..c826a6b 100644
--- a/drivers/net/wireless/intel/iwlegacy/Makefile
+++ b/drivers/net/wireless/intel/iwlegacy/Makefile
@@ -13,5 +13,3 @@ iwl4965-$(CONFIG_IWLEGACY_DEBUGFS) += 4965-debug.o
 obj-$(CONFIG_IWL3945)	+= iwl3945.o
 iwl3945-objs		:= 3945-mac.o 3945.o 3945-rs.o
 iwl3945-$(CONFIG_IWLEGACY_DEBUGFS) += 3945-debug.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/intel/iwlwifi/Makefile b/drivers/net/wireless/intel/iwlwifi/Makefile
index 6e7ed90..92e6118 100644
--- a/drivers/net/wireless/intel/iwlwifi/Makefile
+++ b/drivers/net/wireless/intel/iwlwifi/Makefile
@@ -15,7 +15,7 @@ iwlwifi-objs += $(iwlwifi-m)
 
 iwlwifi-$(CONFIG_IWLWIFI_DEVICE_TRACING) += iwl-devtrace.o
 
-ccflags-y += -D__CHECK_ENDIAN__ -I$(src)
+ccflags-y += -I$(src)
 
 obj-$(CONFIG_IWLDVM)	+= dvm/
 obj-$(CONFIG_IWLMVM)	+= mvm/
diff --git a/drivers/net/wireless/intel/iwlwifi/dvm/Makefile b/drivers/net/wireless/intel/iwlwifi/dvm/Makefile
index 4d19685..b256a354 100644
--- a/drivers/net/wireless/intel/iwlwifi/dvm/Makefile
+++ b/drivers/net/wireless/intel/iwlwifi/dvm/Makefile
@@ -10,4 +10,4 @@ iwldvm-objs		+= rxon.o devices.o
 iwldvm-$(CONFIG_IWLWIFI_LEDS) += led.o
 iwldvm-$(CONFIG_IWLWIFI_DEBUGFS) += debugfs.o
 
-ccflags-y += -D__CHECK_ENDIAN__ -I$(src)/../
+ccflags-y += -I$(src)/../
diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/Makefile b/drivers/net/wireless/intel/iwlwifi/mvm/Makefile
index 2e06dfc..83ac807 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/Makefile
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/Makefile
@@ -9,4 +9,4 @@ iwlmvm-$(CONFIG_IWLWIFI_LEDS) += led.o
 iwlmvm-y += tof.o fw-dbg.o
 iwlmvm-$(CONFIG_PM) += d3.o
 
-ccflags-y += -D__CHECK_ENDIAN__ -I$(src)/../
+ccflags-y += -I$(src)/../
diff --git a/drivers/net/wireless/intersil/orinoco/Makefile b/drivers/net/wireless/intersil/orinoco/Makefile
index bfdefb8..b7ecef8 100644
--- a/drivers/net/wireless/intersil/orinoco/Makefile
+++ b/drivers/net/wireless/intersil/orinoco/Makefile
@@ -12,6 +12,3 @@ obj-$(CONFIG_TMD_HERMES)	+= orinoco_tmd.o
 obj-$(CONFIG_NORTEL_HERMES)	+= orinoco_nortel.o
 obj-$(CONFIG_PCMCIA_SPECTRUM)	+= spectrum_cs.o
 obj-$(CONFIG_ORINOCO_USB)	+= orinoco_usb.o
-
-# Orinoco should be endian clean.
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/mediatek/mt7601u/Makefile b/drivers/net/wireless/mediatek/mt7601u/Makefile
index ea9ed8a..08fc802 100644
--- a/drivers/net/wireless/mediatek/mt7601u/Makefile
+++ b/drivers/net/wireless/mediatek/mt7601u/Makefile
@@ -1,5 +1,3 @@
-ccflags-y += -D__CHECK_ENDIAN__
-
 obj-$(CONFIG_MT7601U)	+= mt7601u.o
 
 mt7601u-objs	= \
diff --git a/drivers/net/wireless/realtek/rtlwifi/Makefile b/drivers/net/wireless/realtek/rtlwifi/Makefile
index ad6d3c5..84c2e82 100644
--- a/drivers/net/wireless/realtek/rtlwifi/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/Makefile
@@ -30,5 +30,3 @@ obj-$(CONFIG_RTLBTCOEXIST)	+= btcoexist/
 obj-$(CONFIG_RTL8723_COMMON)	+= rtl8723com/
 obj-$(CONFIG_RTL8821AE)		+= rtl8821ae/
 obj-$(CONFIG_RTL8192EE)		+= rtl8192ee/
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile b/drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile
index 47ceecf..d1454d4 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile
@@ -3,5 +3,3 @@ btcoexist-objs :=	halbtc8723b2ant.o	\
 			rtl_btc.o
 
 obj-$(CONFIG_RTLBTCOEXIST) += btcoexist.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile
index 676e7de..dae4f0f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile
@@ -11,5 +11,3 @@ rtl8188ee-objs :=		\
 		trx.o
 
 obj-$(CONFIG_RTL8188EE) += rtl8188ee.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile
index aee42d7..0546b75 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile
@@ -5,5 +5,3 @@ rtl8192c-common-objs :=		\
 		phy_common.o
 
 obj-$(CONFIG_RTL8192C_COMMON) += rtl8192c-common.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile
index c0cb0cf..577c7ad 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile
@@ -9,5 +9,3 @@ rtl8192ce-objs :=		\
 		trx.o
 
 obj-$(CONFIG_RTL8192CE) += rtl8192ce.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile
index ad2de6b..97437da 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile
@@ -10,5 +10,3 @@ rtl8192cu-objs :=		\
 		trx.o
 
 obj-$(CONFIG_RTL8192CU) += rtl8192cu.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile
index e3213c8..d0703f2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile
@@ -10,5 +10,3 @@ rtl8192de-objs :=		\
 		trx.o
 
 obj-$(CONFIG_RTL8192DE) += rtl8192de.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile
index 0315eed..f254b9f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile
@@ -12,5 +12,3 @@ rtl8192ee-objs :=		\
 
 
 obj-$(CONFIG_RTL8192EE) += rtl8192ee.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile
index b7eb138..dfa9dbb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile
@@ -11,5 +11,3 @@ rtl8192se-objs :=		\
 
 obj-$(CONFIG_RTL8192SE) += rtl8192se.o
 
-ccflags-y += -D__CHECK_ENDIAN__
-
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile
index 6220672..e7607d2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile
@@ -14,5 +14,3 @@ rtl8723ae-objs :=		\
 
 
 obj-$(CONFIG_RTL8723AE) += rtl8723ae.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile
index a77c341..a841cbd 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile
@@ -12,5 +12,3 @@ rtl8723be-objs :=		\
 
 
 obj-$(CONFIG_RTL8723BE) += rtl8723be.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile
index 345a68a..73da755 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile
@@ -5,5 +5,3 @@ rtl8723-common-objs :=		\
 		phy_common.o
 
 obj-$(CONFIG_RTL8723_COMMON) += rtl8723-common.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile
index f7a26f7..8ca406b 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile
@@ -12,5 +12,3 @@ rtl8821ae-objs :=		\
 
 
 obj-$(CONFIG_RTL8821AE) += rtl8821ae.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/ti/wl1251/Makefile b/drivers/net/wireless/ti/wl1251/Makefile
index a5c6328..58b4f93 100644
--- a/drivers/net/wireless/ti/wl1251/Makefile
+++ b/drivers/net/wireless/ti/wl1251/Makefile
@@ -6,5 +6,3 @@ wl1251_sdio-objs	+= sdio.o
 obj-$(CONFIG_WL1251)		+= wl1251.o
 obj-$(CONFIG_WL1251_SPI)	+= wl1251_spi.o
 obj-$(CONFIG_WL1251_SDIO)	+= wl1251_sdio.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/ti/wlcore/Makefile b/drivers/net/wireless/ti/wlcore/Makefile
index 0a69c13..e286713 100644
--- a/drivers/net/wireless/ti/wlcore/Makefile
+++ b/drivers/net/wireless/ti/wlcore/Makefile
@@ -8,5 +8,3 @@ wlcore-$(CONFIG_NL80211_TESTMODE)	+= testmode.o
 obj-$(CONFIG_WLCORE)			+= wlcore.o
 obj-$(CONFIG_WLCORE_SPI)		+= wlcore_spi.o
 obj-$(CONFIG_WLCORE_SDIO)		+= wlcore_sdio.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/staging/rtl8188eu/Makefile b/drivers/staging/rtl8188eu/Makefile
index 29b9834..27af86e 100644
--- a/drivers/staging/rtl8188eu/Makefile
+++ b/drivers/staging/rtl8188eu/Makefile
@@ -53,4 +53,4 @@ r8188eu-y :=				\
 
 obj-$(CONFIG_R8188EU)	:= r8188eu.o
 
-ccflags-y += -D__CHECK_ENDIAN__ -I$(srctree)/$(src)/include
+ccflags-y += -I$(srctree)/$(src)/include
diff --git a/drivers/staging/rtl8192e/Makefile b/drivers/staging/rtl8192e/Makefile
index cb18db7..7101fcc 100644
--- a/drivers/staging/rtl8192e/Makefile
+++ b/drivers/staging/rtl8192e/Makefile
@@ -17,5 +17,3 @@ obj-$(CONFIG_RTLLIB_CRYPTO_TKIP) += rtllib_crypt_tkip.o
 obj-$(CONFIG_RTLLIB_CRYPTO_WEP) += rtllib_crypt_wep.o
 
 obj-$(CONFIG_RTL8192E) += rtl8192e/
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/staging/rtl8192e/rtl8192e/Makefile b/drivers/staging/rtl8192e/rtl8192e/Makefile
index a2c4fb4..176a4a2 100644
--- a/drivers/staging/rtl8192e/rtl8192e/Makefile
+++ b/drivers/staging/rtl8192e/rtl8192e/Makefile
@@ -16,5 +16,3 @@ r8192e_pci-objs :=		\
 	rtl_wx.o		\
 
 obj-$(CONFIG_RTL8192E) += r8192e_pci.o
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/bluetooth/Makefile b/net/bluetooth/Makefile
index b3ff12e..4bfaa19 100644
--- a/net/bluetooth/Makefile
+++ b/net/bluetooth/Makefile
@@ -20,5 +20,3 @@ bluetooth-$(CONFIG_BT_HS) += a2mp.o amp.o
 bluetooth-$(CONFIG_BT_LEDS) += leds.o
 bluetooth-$(CONFIG_BT_DEBUGFS) += hci_debugfs.o
 bluetooth-$(CONFIG_BT_SELFTEST) += selftest.o
-
-subdir-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index 4adfd4d..9b92ade 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -7,5 +7,3 @@ ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o core.o \
 ieee802154_socket-y := socket.o
 
 CFLAGS_trace.o := -I$(src)
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 0b202b3..2829122 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -61,4 +61,4 @@ rc80211_minstrel_ht-$(CONFIG_MAC80211_DEBUGFS) += rc80211_minstrel_ht_debugfs.o
 mac80211-$(CONFIG_MAC80211_RC_MINSTREL) += $(rc80211_minstrel-y)
 mac80211-$(CONFIG_MAC80211_RC_MINSTREL_HT) += $(rc80211_minstrel_ht-y)
 
-ccflags-y += -D__CHECK_ENDIAN__ -DDEBUG
+ccflags-y += -DDEBUG
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index 17a51e8..5857bb1 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -3,5 +3,3 @@ mac802154-objs		:= main.o rx.o tx.o mac_cmd.o mib.o \
 			   iface.o llsec.o util.o cfg.o trace.o
 
 CFLAGS_trace.o := -I$(src)
-
-ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index 4c9e39f..816c933 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -17,8 +17,6 @@ cfg80211-$(CONFIG_CFG80211_INTERNAL_REGDB) += regdb.o
 
 CFLAGS_trace.o := -I$(src)
 
-ccflags-y += -D__CHECK_ENDIAN__
-
 $(obj)/regdb.c: $(src)/db.txt $(src)/genregdb.awk
 	@$(AWK) -f $(srctree)/$(src)/genregdb.awk < $< > $@
 
-- 
MST
