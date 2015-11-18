From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 07/27] cw1200: move under st vendor directory
Date: Wed, 18 Nov 2015 16:45:46 +0200
Message-ID: <1447857966-19560-8-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34852 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061AbbKROqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:46:35 -0500
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of reorganising wireless drivers directory and Kconfig.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/Kconfig                       |    2 +-
 drivers/net/wireless/Makefile                      |    2 +-
 drivers/net/wireless/st/Kconfig                    |   16 ++++++++++++++++
 drivers/net/wireless/st/Makefile                   |    1 +
 drivers/net/wireless/{ => st}/cw1200/Kconfig       |    0
 drivers/net/wireless/{ => st}/cw1200/Makefile      |    0
 drivers/net/wireless/{ => st}/cw1200/bh.c          |    0
 drivers/net/wireless/{ => st}/cw1200/bh.h          |    0
 drivers/net/wireless/{ => st}/cw1200/cw1200.h      |    0
 drivers/net/wireless/{ => st}/cw1200/cw1200_sdio.c |    0
 drivers/net/wireless/{ => st}/cw1200/cw1200_spi.c  |    0
 drivers/net/wireless/{ => st}/cw1200/debug.c       |    0
 drivers/net/wireless/{ => st}/cw1200/debug.h       |    0
 drivers/net/wireless/{ => st}/cw1200/fwio.c        |    0
 drivers/net/wireless/{ => st}/cw1200/fwio.h        |    0
 drivers/net/wireless/{ => st}/cw1200/hwbus.h       |    0
 drivers/net/wireless/{ => st}/cw1200/hwio.c        |    0
 drivers/net/wireless/{ => st}/cw1200/hwio.h        |    0
 drivers/net/wireless/{ => st}/cw1200/main.c        |    0
 drivers/net/wireless/{ => st}/cw1200/pm.c          |    0
 drivers/net/wireless/{ => st}/cw1200/pm.h          |    0
 drivers/net/wireless/{ => st}/cw1200/queue.c       |    0
 drivers/net/wireless/{ => st}/cw1200/queue.h       |    0
 drivers/net/wireless/{ => st}/cw1200/scan.c        |    0
 drivers/net/wireless/{ => st}/cw1200/scan.h        |    0
 drivers/net/wireless/{ => st}/cw1200/sta.c         |    0
 drivers/net/wireless/{ => st}/cw1200/sta.h         |    0
 drivers/net/wireless/{ => st}/cw1200/txrx.c        |    0
 drivers/net/wireless/{ => st}/cw1200/txrx.h        |    0
 drivers/net/wireless/{ => st}/cw1200/wsm.c         |    0
 drivers/net/wireless/{ => st}/cw1200/wsm.h         |    0
 32 files changed, 20 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/wireless/st/Kconfig
 create mode 100644 drivers/net/wireless/st/Makefile
 rename drivers/net/wireless/{ => st}/cw1200/Kconfig (100%)
 rename drivers/net/wireless/{ => st}/cw1200/Makefile (100%)
 rename drivers/net/wireless/{ => st}/cw1200/bh.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/bh.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/cw1200.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/cw1200_sdio.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/cw1200_spi.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/debug.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/debug.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/fwio.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/fwio.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/hwbus.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/hwio.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/hwio.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/main.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/pm.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/pm.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/queue.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/queue.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/scan.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/scan.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/sta.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/sta.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/txrx.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/txrx.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/wsm.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/wsm.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 748ee82f2ebe..4cbd4641e6fb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3100,7 +3100,7 @@ F:	sound/pci/cs5535audio/
 CW1200 WLAN driver
 M:	Solomon Peachy <pizza@shaftnet.org>
 S:	Maintained
-F:	drivers/net/wireless/cw1200/
+F:	drivers/net/wireless/st/cw1200/
 
 CX18 VIDEO4LINUX DRIVER
 M:	Andy Walls <awalls@md.metrocast.net>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index c627d9e41ede..c1742f228fec 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -21,6 +21,7 @@ source "drivers/net/wireless/admtek/Kconfig"
 source "drivers/net/wireless/atmel/Kconfig"
 source "drivers/net/wireless/broadcom/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
+source "drivers/net/wireless/st/Kconfig"
 
 config PCMCIA_RAYCS
 	tristate "Aviator/Raytheon 2.4GHz wireless support"
@@ -173,7 +174,6 @@ source "drivers/net/wireless/realtek/rtl8xxxu/Kconfig"
 source "drivers/net/wireless/ti/Kconfig"
 source "drivers/net/wireless/zd1211rw/Kconfig"
 source "drivers/net/wireless/mwifiex/Kconfig"
-source "drivers/net/wireless/cw1200/Kconfig"
 source "drivers/net/wireless/rsi/Kconfig"
 
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 41ebe5641c01..d7211a7949e6 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
 obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
 obj-$(CONFIG_WLAN_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 
 obj-$(CONFIG_IPW2100) += ipw2x00/
 obj-$(CONFIG_IPW2200) += ipw2x00/
@@ -47,5 +48,4 @@ obj-$(CONFIG_WL_TI)	+= ti/
 
 obj-$(CONFIG_MWIFIEX)	+= mwifiex/
 
-obj-$(CONFIG_CW1200)	+= cw1200/
 obj-$(CONFIG_RSI_91X)	+= rsi/
diff --git a/drivers/net/wireless/st/Kconfig b/drivers/net/wireless/st/Kconfig
new file mode 100644
index 000000000000..969b4f6e53b5
--- /dev/null
+++ b/drivers/net/wireless/st/Kconfig
@@ -0,0 +1,16 @@
+config WLAN_VENDOR_ST
+	bool "STMicroelectronics devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_ST
+
+source "drivers/net/wireless/st/cw1200/Kconfig"
+
+endif # WLAN_VENDOR_ST
diff --git a/drivers/net/wireless/st/Makefile b/drivers/net/wireless/st/Makefile
new file mode 100644
index 000000000000..a60d6350ba46
--- /dev/null
+++ b/drivers/net/wireless/st/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_CW1200)	+= cw1200/
diff --git a/drivers/net/wireless/cw1200/Kconfig b/drivers/net/wireless/st/cw1200/Kconfig
similarity index 100%
rename from drivers/net/wireless/cw1200/Kconfig
rename to drivers/net/wireless/st/cw1200/Kconfig
diff --git a/drivers/net/wireless/cw1200/Makefile b/drivers/net/wireless/st/cw1200/Makefile
similarity index 100%
rename from drivers/net/wireless/cw1200/Makefile
rename to drivers/net/wireless/st/cw1200/Makefile
diff --git a/drivers/net/wireless/cw1200/bh.c b/drivers/net/wireless/st/cw1200/bh.c
similarity index 100%
rename from drivers/net/wireless/cw1200/bh.c
rename to drivers/net/wireless/st/cw1200/bh.c
diff --git a/drivers/net/wireless/cw1200/bh.h b/drivers/net/wireless/st/cw1200/bh.h
similarity index 100%
rename from drivers/net/wireless/cw1200/bh.h
rename to drivers/net/wireless/st/cw1200/bh.h
diff --git a/drivers/net/wireless/cw1200/cw1200.h b/drivers/net/wireless/st/cw1200/cw1200.h
similarity index 100%
rename from drivers/net/wireless/cw1200/cw1200.h
rename to drivers/net/wireless/st/cw1200/cw1200.h
diff --git a/drivers/net/wireless/cw1200/cw1200_sdio.c b/drivers/net/wireless/st/cw1200/cw1200_sdio.c
similarity index 100%
rename from drivers/net/wireless/cw1200/cw1200_sdio.c
rename to drivers/net/wireless/st/cw1200/cw1200_sdio.c
diff --git a/drivers/net/wireless/cw1200/cw1200_spi.c b/drivers/net/wireless/st/cw1200/cw1200_spi.c
similarity index 100%
rename from drivers/net/wireless/cw1200/cw1200_spi.c
rename to drivers/net/wireless/st/cw1200/cw1200_spi.c
diff --git a/drivers/net/wireless/cw1200/debug.c b/drivers/net/wireless/st/cw1200/debug.c
similarity index 100%
rename from drivers/net/wireless/cw1200/debug.c
rename to drivers/net/wireless/st/cw1200/debug.c
diff --git a/drivers/net/wireless/cw1200/debug.h b/drivers/net/wireless/st/cw1200/debug.h
similarity index 100%
rename from drivers/net/wireless/cw1200/debug.h
rename to drivers/net/wireless/st/cw1200/debug.h
diff --git a/drivers/net/wireless/cw1200/fwio.c b/drivers/net/wireless/st/cw1200/fwio.c
similarity index 100%
rename from drivers/net/wireless/cw1200/fwio.c
rename to drivers/net/wireless/st/cw1200/fwio.c
diff --git a/drivers/net/wireless/cw1200/fwio.h b/drivers/net/wireless/st/cw1200/fwio.h
similarity index 100%
rename from drivers/net/wireless/cw1200/fwio.h
rename to drivers/net/wireless/st/cw1200/fwio.h
diff --git a/drivers/net/wireless/cw1200/hwbus.h b/drivers/net/wireless/st/cw1200/hwbus.h
similarity index 100%
rename from drivers/net/wireless/cw1200/hwbus.h
rename to drivers/net/wireless/st/cw1200/hwbus.h
diff --git a/drivers/net/wireless/cw1200/hwio.c b/drivers/net/wireless/st/cw1200/hwio.c
similarity index 100%
rename from drivers/net/wireless/cw1200/hwio.c
rename to drivers/net/wireless/st/cw1200/hwio.c
diff --git a/drivers/net/wireless/cw1200/hwio.h b/drivers/net/wireless/st/cw1200/hwio.h
similarity index 100%
rename from drivers/net/wireless/cw1200/hwio.h
rename to drivers/net/wireless/st/cw1200/hwio.h
diff --git a/drivers/net/wireless/cw1200/main.c b/drivers/net/wireless/st/cw1200/main.c
similarity index 100%
rename from drivers/net/wireless/cw1200/main.c
rename to drivers/net/wireless/st/cw1200/main.c
diff --git a/drivers/net/wireless/cw1200/pm.c b/drivers/net/wireless/st/cw1200/pm.c
similarity index 100%
rename from drivers/net/wireless/cw1200/pm.c
rename to drivers/net/wireless/st/cw1200/pm.c
diff --git a/drivers/net/wireless/cw1200/pm.h b/drivers/net/wireless/st/cw1200/pm.h
similarity index 100%
rename from drivers/net/wireless/cw1200/pm.h
rename to drivers/net/wireless/st/cw1200/pm.h
diff --git a/drivers/net/wireless/cw1200/queue.c b/drivers/net/wireless/st/cw1200/queue.c
similarity index 100%
rename from drivers/net/wireless/cw1200/queue.c
rename to drivers/net/wireless/st/cw1200/queue.c
diff --git a/drivers/net/wireless/cw1200/queue.h b/drivers/net/wireless/st/cw1200/queue.h
similarity index 100%
rename from drivers/net/wireless/cw1200/queue.h
rename to drivers/net/wireless/st/cw1200/queue.h
diff --git a/drivers/net/wireless/cw1200/scan.c b/drivers/net/wireless/st/cw1200/scan.c
similarity index 100%
rename from drivers/net/wireless/cw1200/scan.c
rename to drivers/net/wireless/st/cw1200/scan.c
diff --git a/drivers/net/wireless/cw1200/scan.h b/drivers/net/wireless/st/cw1200/scan.h
similarity index 100%
rename from drivers/net/wireless/cw1200/scan.h
rename to drivers/net/wireless/st/cw1200/scan.h
diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/st/cw1200/sta.c
similarity index 100%
rename from drivers/net/wireless/cw1200/sta.c
rename to drivers/net/wireless/st/cw1200/sta.c
diff --git a/drivers/net/wireless/cw1200/sta.h b/drivers/net/wireless/st/cw1200/sta.h
similarity index 100%
rename from drivers/net/wireless/cw1200/sta.h
rename to drivers/net/wireless/st/cw1200/sta.h
diff --git a/drivers/net/wireless/cw1200/txrx.c b/drivers/net/wireless/st/cw1200/txrx.c
similarity index 100%
rename from drivers/net/wireless/cw1200/txrx.c
rename to drivers/net/wireless/st/cw1200/txrx.c
diff --git a/drivers/net/wireless/cw1200/txrx.h b/drivers/net/wireless/st/cw1200/txrx.h
similarity index 100%
rename from drivers/net/wireless/cw1200/txrx.h
rename to drivers/net/wireless/st/cw1200/txrx.h
diff --git a/drivers/net/wireless/cw1200/wsm.c b/drivers/net/wireless/st/cw1200/wsm.c
similarity index 100%
rename from drivers/net/wireless/cw1200/wsm.c
rename to drivers/net/wireless/st/cw1200/wsm.c
diff --git a/drivers/net/wireless/cw1200/wsm.h b/drivers/net/wireless/st/cw1200/wsm.h
similarity index 100%
rename from drivers/net/wireless/cw1200/wsm.h
rename to drivers/net/wireless/st/cw1200/wsm.h
-- 
1.7.9.5
