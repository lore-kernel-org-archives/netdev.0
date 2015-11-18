From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 11/27] libertas: move under marvell vendor directory
Date: Wed, 18 Nov 2015 16:45:50 +0200
Message-ID: <1447857966-19560-12-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/marvell/Kconfig               |   16 ++++++++++++++++
 drivers/net/wireless/marvell/Makefile              |    1 +
 .../net/wireless/{ => marvell}/libertas/Kconfig    |    0
 .../net/wireless/{ => marvell}/libertas/LICENSE    |    0
 .../net/wireless/{ => marvell}/libertas/Makefile   |    0
 drivers/net/wireless/{ => marvell}/libertas/README |    0
 drivers/net/wireless/{ => marvell}/libertas/cfg.c  |    0
 drivers/net/wireless/{ => marvell}/libertas/cfg.h  |    0
 drivers/net/wireless/{ => marvell}/libertas/cmd.c  |    0
 drivers/net/wireless/{ => marvell}/libertas/cmd.h  |    0
 .../net/wireless/{ => marvell}/libertas/cmdresp.c  |    0
 .../net/wireless/{ => marvell}/libertas/debugfs.c  |    0
 .../net/wireless/{ => marvell}/libertas/debugfs.h  |    0
 drivers/net/wireless/{ => marvell}/libertas/decl.h |    0
 drivers/net/wireless/{ => marvell}/libertas/defs.h |    0
 drivers/net/wireless/{ => marvell}/libertas/dev.h  |    0
 .../net/wireless/{ => marvell}/libertas/ethtool.c  |    0
 .../net/wireless/{ => marvell}/libertas/firmware.c |    0
 drivers/net/wireless/{ => marvell}/libertas/host.h |    0
 .../net/wireless/{ => marvell}/libertas/if_cs.c    |    0
 .../net/wireless/{ => marvell}/libertas/if_sdio.c  |    0
 .../net/wireless/{ => marvell}/libertas/if_sdio.h  |    0
 .../net/wireless/{ => marvell}/libertas/if_spi.c   |    0
 .../net/wireless/{ => marvell}/libertas/if_spi.h   |    0
 .../net/wireless/{ => marvell}/libertas/if_usb.c   |    0
 .../net/wireless/{ => marvell}/libertas/if_usb.h   |    0
 drivers/net/wireless/{ => marvell}/libertas/main.c |    0
 drivers/net/wireless/{ => marvell}/libertas/mesh.c |    0
 drivers/net/wireless/{ => marvell}/libertas/mesh.h |    0
 .../net/wireless/{ => marvell}/libertas/radiotap.h |    0
 drivers/net/wireless/{ => marvell}/libertas/rx.c   |    0
 drivers/net/wireless/{ => marvell}/libertas/tx.c   |    0
 .../net/wireless/{ => marvell}/libertas/types.h    |    0
 36 files changed, 20 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/wireless/marvell/Kconfig
 create mode 100644 drivers/net/wireless/marvell/Makefile
 rename drivers/net/wireless/{ => marvell}/libertas/Kconfig (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/LICENSE (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/Makefile (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/README (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cfg.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cfg.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cmd.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cmdresp.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/debugfs.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/debugfs.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/decl.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/defs.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/dev.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/ethtool.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/firmware.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/host.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_cs.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_sdio.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_sdio.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_spi.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_spi.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_usb.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_usb.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/main.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/mesh.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/mesh.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/radiotap.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/rx.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/tx.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/types.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index d72be8c88138..75ff7434db0e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6708,7 +6708,7 @@ F:	drivers/net/ethernet/marvell/sk*
 MARVELL LIBERTAS WIRELESS DRIVER
 L:	libertas-dev@lists.infradead.org
 S:	Orphan
-F:	drivers/net/wireless/libertas/
+F:	drivers/net/wireless/marvell/libertas/
 
 MARVELL MV643XX ETHERNET DRIVER
 M:	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index d71efe89970b..b11a2d364200 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -22,6 +22,7 @@ source "drivers/net/wireless/atmel/Kconfig"
 source "drivers/net/wireless/broadcom/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
 source "drivers/net/wireless/intel/Kconfig"
+source "drivers/net/wireless/marvell/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
 
 config PCMCIA_RAYCS
@@ -162,7 +163,6 @@ config MWL8K
 
 source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
-source "drivers/net/wireless/libertas/Kconfig"
 source "drivers/net/wireless/orinoco/Kconfig"
 source "drivers/net/wireless/p54/Kconfig"
 source "drivers/net/wireless/rt2x00/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 6bcb2925a6ce..a974a6edb4b6 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
 obj-$(CONFIG_WLAN_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
+obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 
 obj-$(CONFIG_HERMES)		+= orinoco/
@@ -24,7 +25,6 @@ obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
 obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 
 obj-$(CONFIG_USB_ZD1201)	+= zd1201.o
-obj-$(CONFIG_LIBERTAS)		+= libertas/
 
 obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
 
diff --git a/drivers/net/wireless/marvell/Kconfig b/drivers/net/wireless/marvell/Kconfig
new file mode 100644
index 000000000000..7842096bea53
--- /dev/null
+++ b/drivers/net/wireless/marvell/Kconfig
@@ -0,0 +1,16 @@
+config WLAN_VENDOR_MARVELL
+	bool "Marvell devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_MARVELL
+
+source "drivers/net/wireless/marvell/libertas/Kconfig"
+
+endif # WLAN_VENDOR_MARVELL
diff --git a/drivers/net/wireless/marvell/Makefile b/drivers/net/wireless/marvell/Makefile
new file mode 100644
index 000000000000..6f7ac46ded33
--- /dev/null
+++ b/drivers/net/wireless/marvell/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_LIBERTAS)		+= libertas/
diff --git a/drivers/net/wireless/libertas/Kconfig b/drivers/net/wireless/marvell/libertas/Kconfig
similarity index 100%
rename from drivers/net/wireless/libertas/Kconfig
rename to drivers/net/wireless/marvell/libertas/Kconfig
diff --git a/drivers/net/wireless/libertas/LICENSE b/drivers/net/wireless/marvell/libertas/LICENSE
similarity index 100%
rename from drivers/net/wireless/libertas/LICENSE
rename to drivers/net/wireless/marvell/libertas/LICENSE
diff --git a/drivers/net/wireless/libertas/Makefile b/drivers/net/wireless/marvell/libertas/Makefile
similarity index 100%
rename from drivers/net/wireless/libertas/Makefile
rename to drivers/net/wireless/marvell/libertas/Makefile
diff --git a/drivers/net/wireless/libertas/README b/drivers/net/wireless/marvell/libertas/README
similarity index 100%
rename from drivers/net/wireless/libertas/README
rename to drivers/net/wireless/marvell/libertas/README
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/marvell/libertas/cfg.c
similarity index 100%
rename from drivers/net/wireless/libertas/cfg.c
rename to drivers/net/wireless/marvell/libertas/cfg.c
diff --git a/drivers/net/wireless/libertas/cfg.h b/drivers/net/wireless/marvell/libertas/cfg.h
similarity index 100%
rename from drivers/net/wireless/libertas/cfg.h
rename to drivers/net/wireless/marvell/libertas/cfg.h
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/marvell/libertas/cmd.c
similarity index 100%
rename from drivers/net/wireless/libertas/cmd.c
rename to drivers/net/wireless/marvell/libertas/cmd.c
diff --git a/drivers/net/wireless/libertas/cmd.h b/drivers/net/wireless/marvell/libertas/cmd.h
similarity index 100%
rename from drivers/net/wireless/libertas/cmd.h
rename to drivers/net/wireless/marvell/libertas/cmd.h
diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/marvell/libertas/cmdresp.c
similarity index 100%
rename from drivers/net/wireless/libertas/cmdresp.c
rename to drivers/net/wireless/marvell/libertas/cmdresp.c
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/marvell/libertas/debugfs.c
similarity index 100%
rename from drivers/net/wireless/libertas/debugfs.c
rename to drivers/net/wireless/marvell/libertas/debugfs.c
diff --git a/drivers/net/wireless/libertas/debugfs.h b/drivers/net/wireless/marvell/libertas/debugfs.h
similarity index 100%
rename from drivers/net/wireless/libertas/debugfs.h
rename to drivers/net/wireless/marvell/libertas/debugfs.h
diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/marvell/libertas/decl.h
similarity index 100%
rename from drivers/net/wireless/libertas/decl.h
rename to drivers/net/wireless/marvell/libertas/decl.h
diff --git a/drivers/net/wireless/libertas/defs.h b/drivers/net/wireless/marvell/libertas/defs.h
similarity index 100%
rename from drivers/net/wireless/libertas/defs.h
rename to drivers/net/wireless/marvell/libertas/defs.h
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/marvell/libertas/dev.h
similarity index 100%
rename from drivers/net/wireless/libertas/dev.h
rename to drivers/net/wireless/marvell/libertas/dev.h
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/marvell/libertas/ethtool.c
similarity index 100%
rename from drivers/net/wireless/libertas/ethtool.c
rename to drivers/net/wireless/marvell/libertas/ethtool.c
diff --git a/drivers/net/wireless/libertas/firmware.c b/drivers/net/wireless/marvell/libertas/firmware.c
similarity index 100%
rename from drivers/net/wireless/libertas/firmware.c
rename to drivers/net/wireless/marvell/libertas/firmware.c
diff --git a/drivers/net/wireless/libertas/host.h b/drivers/net/wireless/marvell/libertas/host.h
similarity index 100%
rename from drivers/net/wireless/libertas/host.h
rename to drivers/net/wireless/marvell/libertas/host.h
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/marvell/libertas/if_cs.c
similarity index 100%
rename from drivers/net/wireless/libertas/if_cs.c
rename to drivers/net/wireless/marvell/libertas/if_cs.c
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/marvell/libertas/if_sdio.c
similarity index 100%
rename from drivers/net/wireless/libertas/if_sdio.c
rename to drivers/net/wireless/marvell/libertas/if_sdio.c
diff --git a/drivers/net/wireless/libertas/if_sdio.h b/drivers/net/wireless/marvell/libertas/if_sdio.h
similarity index 100%
rename from drivers/net/wireless/libertas/if_sdio.h
rename to drivers/net/wireless/marvell/libertas/if_sdio.h
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/marvell/libertas/if_spi.c
similarity index 100%
rename from drivers/net/wireless/libertas/if_spi.c
rename to drivers/net/wireless/marvell/libertas/if_spi.c
diff --git a/drivers/net/wireless/libertas/if_spi.h b/drivers/net/wireless/marvell/libertas/if_spi.h
similarity index 100%
rename from drivers/net/wireless/libertas/if_spi.h
rename to drivers/net/wireless/marvell/libertas/if_spi.h
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/marvell/libertas/if_usb.c
similarity index 100%
rename from drivers/net/wireless/libertas/if_usb.c
rename to drivers/net/wireless/marvell/libertas/if_usb.c
diff --git a/drivers/net/wireless/libertas/if_usb.h b/drivers/net/wireless/marvell/libertas/if_usb.h
similarity index 100%
rename from drivers/net/wireless/libertas/if_usb.h
rename to drivers/net/wireless/marvell/libertas/if_usb.h
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/marvell/libertas/main.c
similarity index 100%
rename from drivers/net/wireless/libertas/main.c
rename to drivers/net/wireless/marvell/libertas/main.c
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
similarity index 100%
rename from drivers/net/wireless/libertas/mesh.c
rename to drivers/net/wireless/marvell/libertas/mesh.c
diff --git a/drivers/net/wireless/libertas/mesh.h b/drivers/net/wireless/marvell/libertas/mesh.h
similarity index 100%
rename from drivers/net/wireless/libertas/mesh.h
rename to drivers/net/wireless/marvell/libertas/mesh.h
diff --git a/drivers/net/wireless/libertas/radiotap.h b/drivers/net/wireless/marvell/libertas/radiotap.h
similarity index 100%
rename from drivers/net/wireless/libertas/radiotap.h
rename to drivers/net/wireless/marvell/libertas/radiotap.h
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/marvell/libertas/rx.c
similarity index 100%
rename from drivers/net/wireless/libertas/rx.c
rename to drivers/net/wireless/marvell/libertas/rx.c
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/marvell/libertas/tx.c
similarity index 100%
rename from drivers/net/wireless/libertas/tx.c
rename to drivers/net/wireless/marvell/libertas/tx.c
diff --git a/drivers/net/wireless/libertas/types.h b/drivers/net/wireless/marvell/libertas/types.h
similarity index 100%
rename from drivers/net/wireless/libertas/types.h
rename to drivers/net/wireless/marvell/libertas/types.h
-- 
1.7.9.5
