From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 23/27] rt2x00: move under ralink vendor directory
Date: Wed, 18 Nov 2015 16:46:02 +0200
Message-ID: <1447857966-19560-24-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Makefile                      |    3 +--
 drivers/net/wireless/ralink/Kconfig                |   16 ++++++++++++++++
 drivers/net/wireless/ralink/Makefile               |    1 +
 drivers/net/wireless/{ => ralink}/rt2x00/Kconfig   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/Makefile  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2400pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2400pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500usb.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500usb.h   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt2800.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800lib.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800lib.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800mmio.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800mmio.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800soc.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800usb.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800usb.h   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt2x00.h  |    0
 .../wireless/{ => ralink}/rt2x00/rt2x00config.c    |    0
 .../wireless/{ => ralink}/rt2x00/rt2x00crypto.c    |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00debug.c |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00debug.h |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00dev.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00dump.h  |    0
 .../wireless/{ => ralink}/rt2x00/rt2x00firmware.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00leds.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00leds.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00lib.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00link.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00mac.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00mmio.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00mmio.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00queue.c |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00queue.h |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00reg.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00soc.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00soc.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00usb.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00usb.h   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.c |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.h |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.c |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.h |    0
 51 files changed, 20 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/wireless/ralink/Kconfig
 create mode 100644 drivers/net/wireless/ralink/Makefile
 rename drivers/net/wireless/{ => ralink}/rt2x00/Kconfig (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/Makefile (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2400pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2400pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500usb.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800lib.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800lib.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800mmio.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800mmio.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800soc.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800usb.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00config.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00crypto.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00debug.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00debug.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00dev.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00dump.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00firmware.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00leds.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00leds.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00lib.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00link.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00mac.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00mmio.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00mmio.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00queue.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00queue.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00reg.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00soc.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00soc.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00usb.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index a9f7f968f64e..38c049d07966 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8801,7 +8801,7 @@ M:	Stanislaw Gruszka <sgruszka@redhat.com>
 M:	Helmut Schaa <helmut.schaa@googlemail.com>
 L:	linux-wireless@vger.kernel.org
 S:	Maintained
-F:	drivers/net/wireless/rt2x00/
+F:	drivers/net/wireless/ralink/rt2x00/
 
 RAMDISK RAM BLOCK DEVICE DRIVER
 M:	Jens Axboe <axboe@kernel.dk>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 518608403bd3..c58e244b5079 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/wireless/cisco/Kconfig"
 source "drivers/net/wireless/intel/Kconfig"
 source "drivers/net/wireless/intersil/Kconfig"
 source "drivers/net/wireless/marvell/Kconfig"
+source "drivers/net/wireless/ralink/Kconfig"
 source "drivers/net/wireless/realtek/Kconfig"
 source "drivers/net/wireless/rsi/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
@@ -97,7 +98,6 @@ config MAC80211_HWSIM
 	  called mac80211_hwsim.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/rt2x00/Kconfig"
 source "drivers/net/wireless/mediatek/Kconfig"
 source "drivers/net/wireless/ti/Kconfig"
 
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index d38b6cc338df..8ac72fd44d17 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
 obj-$(CONFIG_WLAN_VENDOR_INTERSIL) += intersil/
 obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
+obj-$(CONFIG_WLAN_VENDOR_RALINK) += ralink/
 obj-$(CONFIG_WLAN_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_WLAN_VENDOR_RSI) += rsi/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
@@ -20,8 +21,6 @@ obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
 
 obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 
-obj-$(CONFIG_RT2X00)	+= rt2x00/
-
 obj-$(CONFIG_WL_MEDIATEK)	+= mediatek/
 
 obj-$(CONFIG_ATH_CARDS)		+= ath/
diff --git a/drivers/net/wireless/ralink/Kconfig b/drivers/net/wireless/ralink/Kconfig
new file mode 100644
index 000000000000..41dbf3130e2b
--- /dev/null
+++ b/drivers/net/wireless/ralink/Kconfig
@@ -0,0 +1,16 @@
+config WLAN_VENDOR_RALINK
+	bool "Ralink devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_RALINK
+
+source "drivers/net/wireless/ralink/rt2x00/Kconfig"
+
+endif # WLAN_VENDOR_RALINK
diff --git a/drivers/net/wireless/ralink/Makefile b/drivers/net/wireless/ralink/Makefile
new file mode 100644
index 000000000000..f84c0a2e4f4d
--- /dev/null
+++ b/drivers/net/wireless/ralink/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_RT2X00)	+= rt2x00/
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/ralink/rt2x00/Kconfig
similarity index 100%
rename from drivers/net/wireless/rt2x00/Kconfig
rename to drivers/net/wireless/ralink/rt2x00/Kconfig
diff --git a/drivers/net/wireless/rt2x00/Makefile b/drivers/net/wireless/ralink/rt2x00/Makefile
similarity index 100%
rename from drivers/net/wireless/rt2x00/Makefile
rename to drivers/net/wireless/ralink/rt2x00/Makefile
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/ralink/rt2x00/rt2400pci.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2400pci.c
rename to drivers/net/wireless/ralink/rt2x00/rt2400pci.c
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.h b/drivers/net/wireless/ralink/rt2x00/rt2400pci.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2400pci.h
rename to drivers/net/wireless/ralink/rt2x00/rt2400pci.h
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/ralink/rt2x00/rt2500pci.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2500pci.c
rename to drivers/net/wireless/ralink/rt2x00/rt2500pci.c
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.h b/drivers/net/wireless/ralink/rt2x00/rt2500pci.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2500pci.h
rename to drivers/net/wireless/ralink/rt2x00/rt2500pci.h
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2500usb.c
rename to drivers/net/wireless/ralink/rt2x00/rt2500usb.c
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.h b/drivers/net/wireless/ralink/rt2x00/rt2500usb.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2500usb.h
rename to drivers/net/wireless/ralink/rt2x00/rt2500usb.h
diff --git a/drivers/net/wireless/rt2x00/rt2800.h b/drivers/net/wireless/ralink/rt2x00/rt2800.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800.h
rename to drivers/net/wireless/ralink/rt2x00/rt2800.h
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800lib.c
rename to drivers/net/wireless/ralink/rt2x00/rt2800lib.c
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.h b/drivers/net/wireless/ralink/rt2x00/rt2800lib.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800lib.h
rename to drivers/net/wireless/ralink/rt2x00/rt2800lib.h
diff --git a/drivers/net/wireless/rt2x00/rt2800mmio.c b/drivers/net/wireless/ralink/rt2x00/rt2800mmio.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800mmio.c
rename to drivers/net/wireless/ralink/rt2x00/rt2800mmio.c
diff --git a/drivers/net/wireless/rt2x00/rt2800mmio.h b/drivers/net/wireless/ralink/rt2x00/rt2800mmio.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800mmio.h
rename to drivers/net/wireless/ralink/rt2x00/rt2800mmio.h
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/ralink/rt2x00/rt2800pci.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800pci.c
rename to drivers/net/wireless/ralink/rt2x00/rt2800pci.c
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.h b/drivers/net/wireless/ralink/rt2x00/rt2800pci.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800pci.h
rename to drivers/net/wireless/ralink/rt2x00/rt2800pci.h
diff --git a/drivers/net/wireless/rt2x00/rt2800soc.c b/drivers/net/wireless/ralink/rt2x00/rt2800soc.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800soc.c
rename to drivers/net/wireless/ralink/rt2x00/rt2800soc.c
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800usb.c
rename to drivers/net/wireless/ralink/rt2x00/rt2800usb.c
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.h b/drivers/net/wireless/ralink/rt2x00/rt2800usb.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2800usb.h
rename to drivers/net/wireless/ralink/rt2x00/rt2800usb.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/ralink/rt2x00/rt2x00.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/ralink/rt2x00/rt2x00config.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00config.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00config.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00crypto.c b/drivers/net/wireless/ralink/rt2x00/rt2x00crypto.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00crypto.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00crypto.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00debug.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.h b/drivers/net/wireless/ralink/rt2x00/rt2x00debug.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00debug.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00debug.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/ralink/rt2x00/rt2x00dev.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00dev.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00dev.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00dump.h b/drivers/net/wireless/ralink/rt2x00/rt2x00dump.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00dump.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00dump.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/net/wireless/ralink/rt2x00/rt2x00firmware.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00firmware.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00firmware.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00leds.c b/drivers/net/wireless/ralink/rt2x00/rt2x00leds.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00leds.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00leds.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00leds.h b/drivers/net/wireless/ralink/rt2x00/rt2x00leds.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00leds.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00leds.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/ralink/rt2x00/rt2x00lib.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00lib.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00lib.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00link.c b/drivers/net/wireless/ralink/rt2x00/rt2x00link.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00link.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00link.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/ralink/rt2x00/rt2x00mac.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00mac.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00mac.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.c b/drivers/net/wireless/ralink/rt2x00/rt2x00mmio.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00mmio.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00mmio.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.h b/drivers/net/wireless/ralink/rt2x00/rt2x00mmio.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00mmio.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00mmio.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/ralink/rt2x00/rt2x00pci.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00pci.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00pci.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.h b/drivers/net/wireless/ralink/rt2x00/rt2x00pci.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00pci.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00pci.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/ralink/rt2x00/rt2x00queue.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00queue.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00queue.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.h b/drivers/net/wireless/ralink/rt2x00/rt2x00queue.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00queue.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00queue.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00reg.h b/drivers/net/wireless/ralink/rt2x00/rt2x00reg.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00reg.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00reg.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00soc.c b/drivers/net/wireless/ralink/rt2x00/rt2x00soc.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00soc.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00soc.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00soc.h b/drivers/net/wireless/ralink/rt2x00/rt2x00soc.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00soc.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00soc.h
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/ralink/rt2x00/rt2x00usb.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00usb.c
rename to drivers/net/wireless/ralink/rt2x00/rt2x00usb.c
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.h b/drivers/net/wireless/ralink/rt2x00/rt2x00usb.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt2x00usb.h
rename to drivers/net/wireless/ralink/rt2x00/rt2x00usb.h
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/ralink/rt2x00/rt61pci.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt61pci.c
rename to drivers/net/wireless/ralink/rt2x00/rt61pci.c
diff --git a/drivers/net/wireless/rt2x00/rt61pci.h b/drivers/net/wireless/ralink/rt2x00/rt61pci.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt61pci.h
rename to drivers/net/wireless/ralink/rt2x00/rt61pci.h
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/ralink/rt2x00/rt73usb.c
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt73usb.c
rename to drivers/net/wireless/ralink/rt2x00/rt73usb.c
diff --git a/drivers/net/wireless/rt2x00/rt73usb.h b/drivers/net/wireless/ralink/rt2x00/rt73usb.h
similarity index 100%
rename from drivers/net/wireless/rt2x00/rt73usb.h
rename to drivers/net/wireless/ralink/rt2x00/rt73usb.h
-- 
1.7.9.5
