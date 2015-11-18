From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 04/27] b43: move under broadcom vendor directory
Date: Wed, 18 Nov 2015 16:45:43 +0200
Message-ID: <1447857966-19560-5-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/broadcom/Kconfig              |   16 ++++++++++++++++
 drivers/net/wireless/broadcom/Makefile             |    1 +
 drivers/net/wireless/{ => broadcom}/b43/Kconfig    |    0
 drivers/net/wireless/{ => broadcom}/b43/Makefile   |    0
 drivers/net/wireless/{ => broadcom}/b43/b43.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/bus.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/bus.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/debugfs.c  |    0
 drivers/net/wireless/{ => broadcom}/b43/debugfs.h  |    0
 drivers/net/wireless/{ => broadcom}/b43/dma.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/dma.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/leds.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/leds.h     |    0
 drivers/net/wireless/{ => broadcom}/b43/lo.c       |    0
 drivers/net/wireless/{ => broadcom}/b43/lo.h       |    0
 drivers/net/wireless/{ => broadcom}/b43/main.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/main.h     |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_a.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_a.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ac.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ac.h   |    0
 .../net/wireless/{ => broadcom}/b43/phy_common.c   |    0
 .../net/wireless/{ => broadcom}/b43/phy_common.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_g.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_g.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ht.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ht.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lcn.c  |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lcn.h  |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lp.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lp.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_n.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_n.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/pio.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/pio.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/ppr.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/ppr.h      |    0
 .../net/wireless/{ => broadcom}/b43/radio_2055.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2055.h   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2056.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2056.h   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2057.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2057.h   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2059.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2059.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/rfkill.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/rfkill.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/sdio.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/sdio.h     |    0
 drivers/net/wireless/{ => broadcom}/b43/sysfs.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/sysfs.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/tables.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/tables.h   |    0
 .../net/wireless/{ => broadcom}/b43/tables_lpphy.c |    0
 .../net/wireless/{ => broadcom}/b43/tables_lpphy.h |    0
 .../net/wireless/{ => broadcom}/b43/tables_nphy.c  |    0
 .../net/wireless/{ => broadcom}/b43/tables_nphy.h  |    0
 .../wireless/{ => broadcom}/b43/tables_phy_ht.c    |    0
 .../wireless/{ => broadcom}/b43/tables_phy_ht.h    |    0
 .../wireless/{ => broadcom}/b43/tables_phy_lcn.c   |    0
 .../wireless/{ => broadcom}/b43/tables_phy_lcn.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/wa.c       |    0
 drivers/net/wireless/{ => broadcom}/b43/wa.h       |    0
 drivers/net/wireless/{ => broadcom}/b43/xmit.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/xmit.h     |    0
 68 files changed, 20 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/wireless/broadcom/Kconfig
 create mode 100644 drivers/net/wireless/broadcom/Makefile
 rename drivers/net/wireless/{ => broadcom}/b43/Kconfig (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/Makefile (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/b43.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/bus.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/bus.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/debugfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/debugfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/dma.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/dma.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/leds.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/leds.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/lo.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/lo.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/main.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/main.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_a.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_a.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ac.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ac.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_common.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_common.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_g.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_g.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ht.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ht.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lp.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lp.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_n.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_n.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/pio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/pio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/ppr.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/ppr.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2055.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2055.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2056.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2056.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2057.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2057.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2059.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2059.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/rfkill.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/rfkill.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sdio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sdio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sysfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sysfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_lpphy.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_lpphy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_nphy.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_nphy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_ht.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_ht.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/wa.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/wa.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/xmit.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/xmit.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2f3ea01c101c..68793777fdb5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2081,7 +2081,7 @@ L:	linux-wireless@vger.kernel.org
 L:	b43-dev@lists.infradead.org
 W:	http://wireless.kernel.org/en/users/Drivers/b43
 S:	Odd Fixes
-F:	drivers/net/wireless/b43/
+F:	drivers/net/wireless/broadcom/b43/
 
 B43LEGACY WIRELESS DRIVER
 M:	Larry Finger <Larry.Finger@lwfinger.net>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 275b6ed93f15..0c47f2ca2207 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -19,6 +19,7 @@ if WLAN
 
 source "drivers/net/wireless/admtek/Kconfig"
 source "drivers/net/wireless/atmel/Kconfig"
+source "drivers/net/wireless/broadcom/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
 
 config PCMCIA_RAYCS
@@ -158,7 +159,6 @@ config MWL8K
 	  will be called mwl8k.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/b43/Kconfig"
 source "drivers/net/wireless/b43legacy/Kconfig"
 source "drivers/net/wireless/brcm80211/Kconfig"
 source "drivers/net/wireless/hostap/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 87eb6b2f3227..7907674ad5b4 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
 obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
+obj-$(CONFIG_WLAN_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 
 obj-$(CONFIG_IPW2100) += ipw2x00/
@@ -14,7 +15,6 @@ obj-$(CONFIG_HERMES)		+= orinoco/
 obj-$(CONFIG_PRISM54)		+= prism54/
 
 obj-$(CONFIG_HOSTAP)		+= hostap/
-obj-$(CONFIG_B43)		+= b43/
 obj-$(CONFIG_B43LEGACY)		+= b43legacy/
 obj-$(CONFIG_ZD1211RW)		+= zd1211rw/
 obj-$(CONFIG_WLAN)		+= realtek/
diff --git a/drivers/net/wireless/broadcom/Kconfig b/drivers/net/wireless/broadcom/Kconfig
new file mode 100644
index 000000000000..0ba8119d2cf2
--- /dev/null
+++ b/drivers/net/wireless/broadcom/Kconfig
@@ -0,0 +1,16 @@
+config WLAN_VENDOR_BROADCOM
+	bool "Broadcom devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_BROADCOM
+
+source "drivers/net/wireless/broadcom/b43/Kconfig"
+
+endif # WLAN_VENDOR_BROADCOM
diff --git a/drivers/net/wireless/broadcom/Makefile b/drivers/net/wireless/broadcom/Makefile
new file mode 100644
index 000000000000..0140a810107c
--- /dev/null
+++ b/drivers/net/wireless/broadcom/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_B43)		+= b43/
diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/broadcom/b43/Kconfig
similarity index 100%
rename from drivers/net/wireless/b43/Kconfig
rename to drivers/net/wireless/broadcom/b43/Kconfig
diff --git a/drivers/net/wireless/b43/Makefile b/drivers/net/wireless/broadcom/b43/Makefile
similarity index 100%
rename from drivers/net/wireless/b43/Makefile
rename to drivers/net/wireless/broadcom/b43/Makefile
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/broadcom/b43/b43.h
similarity index 100%
rename from drivers/net/wireless/b43/b43.h
rename to drivers/net/wireless/broadcom/b43/b43.h
diff --git a/drivers/net/wireless/b43/bus.c b/drivers/net/wireless/broadcom/b43/bus.c
similarity index 100%
rename from drivers/net/wireless/b43/bus.c
rename to drivers/net/wireless/broadcom/b43/bus.c
diff --git a/drivers/net/wireless/b43/bus.h b/drivers/net/wireless/broadcom/b43/bus.h
similarity index 100%
rename from drivers/net/wireless/b43/bus.h
rename to drivers/net/wireless/broadcom/b43/bus.h
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/broadcom/b43/debugfs.c
similarity index 100%
rename from drivers/net/wireless/b43/debugfs.c
rename to drivers/net/wireless/broadcom/b43/debugfs.c
diff --git a/drivers/net/wireless/b43/debugfs.h b/drivers/net/wireless/broadcom/b43/debugfs.h
similarity index 100%
rename from drivers/net/wireless/b43/debugfs.h
rename to drivers/net/wireless/broadcom/b43/debugfs.h
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/broadcom/b43/dma.c
similarity index 100%
rename from drivers/net/wireless/b43/dma.c
rename to drivers/net/wireless/broadcom/b43/dma.c
diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/broadcom/b43/dma.h
similarity index 100%
rename from drivers/net/wireless/b43/dma.h
rename to drivers/net/wireless/broadcom/b43/dma.h
diff --git a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/broadcom/b43/leds.c
similarity index 100%
rename from drivers/net/wireless/b43/leds.c
rename to drivers/net/wireless/broadcom/b43/leds.c
diff --git a/drivers/net/wireless/b43/leds.h b/drivers/net/wireless/broadcom/b43/leds.h
similarity index 100%
rename from drivers/net/wireless/b43/leds.h
rename to drivers/net/wireless/broadcom/b43/leds.h
diff --git a/drivers/net/wireless/b43/lo.c b/drivers/net/wireless/broadcom/b43/lo.c
similarity index 100%
rename from drivers/net/wireless/b43/lo.c
rename to drivers/net/wireless/broadcom/b43/lo.c
diff --git a/drivers/net/wireless/b43/lo.h b/drivers/net/wireless/broadcom/b43/lo.h
similarity index 100%
rename from drivers/net/wireless/b43/lo.h
rename to drivers/net/wireless/broadcom/b43/lo.h
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/broadcom/b43/main.c
similarity index 100%
rename from drivers/net/wireless/b43/main.c
rename to drivers/net/wireless/broadcom/b43/main.c
diff --git a/drivers/net/wireless/b43/main.h b/drivers/net/wireless/broadcom/b43/main.h
similarity index 100%
rename from drivers/net/wireless/b43/main.h
rename to drivers/net/wireless/broadcom/b43/main.h
diff --git a/drivers/net/wireless/b43/phy_a.c b/drivers/net/wireless/broadcom/b43/phy_a.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_a.c
rename to drivers/net/wireless/broadcom/b43/phy_a.c
diff --git a/drivers/net/wireless/b43/phy_a.h b/drivers/net/wireless/broadcom/b43/phy_a.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_a.h
rename to drivers/net/wireless/broadcom/b43/phy_a.h
diff --git a/drivers/net/wireless/b43/phy_ac.c b/drivers/net/wireless/broadcom/b43/phy_ac.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_ac.c
rename to drivers/net/wireless/broadcom/b43/phy_ac.c
diff --git a/drivers/net/wireless/b43/phy_ac.h b/drivers/net/wireless/broadcom/b43/phy_ac.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_ac.h
rename to drivers/net/wireless/broadcom/b43/phy_ac.h
diff --git a/drivers/net/wireless/b43/phy_common.c b/drivers/net/wireless/broadcom/b43/phy_common.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_common.c
rename to drivers/net/wireless/broadcom/b43/phy_common.c
diff --git a/drivers/net/wireless/b43/phy_common.h b/drivers/net/wireless/broadcom/b43/phy_common.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_common.h
rename to drivers/net/wireless/broadcom/b43/phy_common.h
diff --git a/drivers/net/wireless/b43/phy_g.c b/drivers/net/wireless/broadcom/b43/phy_g.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_g.c
rename to drivers/net/wireless/broadcom/b43/phy_g.c
diff --git a/drivers/net/wireless/b43/phy_g.h b/drivers/net/wireless/broadcom/b43/phy_g.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_g.h
rename to drivers/net/wireless/broadcom/b43/phy_g.h
diff --git a/drivers/net/wireless/b43/phy_ht.c b/drivers/net/wireless/broadcom/b43/phy_ht.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_ht.c
rename to drivers/net/wireless/broadcom/b43/phy_ht.c
diff --git a/drivers/net/wireless/b43/phy_ht.h b/drivers/net/wireless/broadcom/b43/phy_ht.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_ht.h
rename to drivers/net/wireless/broadcom/b43/phy_ht.h
diff --git a/drivers/net/wireless/b43/phy_lcn.c b/drivers/net/wireless/broadcom/b43/phy_lcn.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_lcn.c
rename to drivers/net/wireless/broadcom/b43/phy_lcn.c
diff --git a/drivers/net/wireless/b43/phy_lcn.h b/drivers/net/wireless/broadcom/b43/phy_lcn.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_lcn.h
rename to drivers/net/wireless/broadcom/b43/phy_lcn.h
diff --git a/drivers/net/wireless/b43/phy_lp.c b/drivers/net/wireless/broadcom/b43/phy_lp.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_lp.c
rename to drivers/net/wireless/broadcom/b43/phy_lp.c
diff --git a/drivers/net/wireless/b43/phy_lp.h b/drivers/net/wireless/broadcom/b43/phy_lp.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_lp.h
rename to drivers/net/wireless/broadcom/b43/phy_lp.h
diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/broadcom/b43/phy_n.c
similarity index 100%
rename from drivers/net/wireless/b43/phy_n.c
rename to drivers/net/wireless/broadcom/b43/phy_n.c
diff --git a/drivers/net/wireless/b43/phy_n.h b/drivers/net/wireless/broadcom/b43/phy_n.h
similarity index 100%
rename from drivers/net/wireless/b43/phy_n.h
rename to drivers/net/wireless/broadcom/b43/phy_n.h
diff --git a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/broadcom/b43/pio.c
similarity index 100%
rename from drivers/net/wireless/b43/pio.c
rename to drivers/net/wireless/broadcom/b43/pio.c
diff --git a/drivers/net/wireless/b43/pio.h b/drivers/net/wireless/broadcom/b43/pio.h
similarity index 100%
rename from drivers/net/wireless/b43/pio.h
rename to drivers/net/wireless/broadcom/b43/pio.h
diff --git a/drivers/net/wireless/b43/ppr.c b/drivers/net/wireless/broadcom/b43/ppr.c
similarity index 100%
rename from drivers/net/wireless/b43/ppr.c
rename to drivers/net/wireless/broadcom/b43/ppr.c
diff --git a/drivers/net/wireless/b43/ppr.h b/drivers/net/wireless/broadcom/b43/ppr.h
similarity index 100%
rename from drivers/net/wireless/b43/ppr.h
rename to drivers/net/wireless/broadcom/b43/ppr.h
diff --git a/drivers/net/wireless/b43/radio_2055.c b/drivers/net/wireless/broadcom/b43/radio_2055.c
similarity index 100%
rename from drivers/net/wireless/b43/radio_2055.c
rename to drivers/net/wireless/broadcom/b43/radio_2055.c
diff --git a/drivers/net/wireless/b43/radio_2055.h b/drivers/net/wireless/broadcom/b43/radio_2055.h
similarity index 100%
rename from drivers/net/wireless/b43/radio_2055.h
rename to drivers/net/wireless/broadcom/b43/radio_2055.h
diff --git a/drivers/net/wireless/b43/radio_2056.c b/drivers/net/wireless/broadcom/b43/radio_2056.c
similarity index 100%
rename from drivers/net/wireless/b43/radio_2056.c
rename to drivers/net/wireless/broadcom/b43/radio_2056.c
diff --git a/drivers/net/wireless/b43/radio_2056.h b/drivers/net/wireless/broadcom/b43/radio_2056.h
similarity index 100%
rename from drivers/net/wireless/b43/radio_2056.h
rename to drivers/net/wireless/broadcom/b43/radio_2056.h
diff --git a/drivers/net/wireless/b43/radio_2057.c b/drivers/net/wireless/broadcom/b43/radio_2057.c
similarity index 100%
rename from drivers/net/wireless/b43/radio_2057.c
rename to drivers/net/wireless/broadcom/b43/radio_2057.c
diff --git a/drivers/net/wireless/b43/radio_2057.h b/drivers/net/wireless/broadcom/b43/radio_2057.h
similarity index 100%
rename from drivers/net/wireless/b43/radio_2057.h
rename to drivers/net/wireless/broadcom/b43/radio_2057.h
diff --git a/drivers/net/wireless/b43/radio_2059.c b/drivers/net/wireless/broadcom/b43/radio_2059.c
similarity index 100%
rename from drivers/net/wireless/b43/radio_2059.c
rename to drivers/net/wireless/broadcom/b43/radio_2059.c
diff --git a/drivers/net/wireless/b43/radio_2059.h b/drivers/net/wireless/broadcom/b43/radio_2059.h
similarity index 100%
rename from drivers/net/wireless/b43/radio_2059.h
rename to drivers/net/wireless/broadcom/b43/radio_2059.h
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/broadcom/b43/rfkill.c
similarity index 100%
rename from drivers/net/wireless/b43/rfkill.c
rename to drivers/net/wireless/broadcom/b43/rfkill.c
diff --git a/drivers/net/wireless/b43/rfkill.h b/drivers/net/wireless/broadcom/b43/rfkill.h
similarity index 100%
rename from drivers/net/wireless/b43/rfkill.h
rename to drivers/net/wireless/broadcom/b43/rfkill.h
diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/broadcom/b43/sdio.c
similarity index 100%
rename from drivers/net/wireless/b43/sdio.c
rename to drivers/net/wireless/broadcom/b43/sdio.c
diff --git a/drivers/net/wireless/b43/sdio.h b/drivers/net/wireless/broadcom/b43/sdio.h
similarity index 100%
rename from drivers/net/wireless/b43/sdio.h
rename to drivers/net/wireless/broadcom/b43/sdio.h
diff --git a/drivers/net/wireless/b43/sysfs.c b/drivers/net/wireless/broadcom/b43/sysfs.c
similarity index 100%
rename from drivers/net/wireless/b43/sysfs.c
rename to drivers/net/wireless/broadcom/b43/sysfs.c
diff --git a/drivers/net/wireless/b43/sysfs.h b/drivers/net/wireless/broadcom/b43/sysfs.h
similarity index 100%
rename from drivers/net/wireless/b43/sysfs.h
rename to drivers/net/wireless/broadcom/b43/sysfs.h
diff --git a/drivers/net/wireless/b43/tables.c b/drivers/net/wireless/broadcom/b43/tables.c
similarity index 100%
rename from drivers/net/wireless/b43/tables.c
rename to drivers/net/wireless/broadcom/b43/tables.c
diff --git a/drivers/net/wireless/b43/tables.h b/drivers/net/wireless/broadcom/b43/tables.h
similarity index 100%
rename from drivers/net/wireless/b43/tables.h
rename to drivers/net/wireless/broadcom/b43/tables.h
diff --git a/drivers/net/wireless/b43/tables_lpphy.c b/drivers/net/wireless/broadcom/b43/tables_lpphy.c
similarity index 100%
rename from drivers/net/wireless/b43/tables_lpphy.c
rename to drivers/net/wireless/broadcom/b43/tables_lpphy.c
diff --git a/drivers/net/wireless/b43/tables_lpphy.h b/drivers/net/wireless/broadcom/b43/tables_lpphy.h
similarity index 100%
rename from drivers/net/wireless/b43/tables_lpphy.h
rename to drivers/net/wireless/broadcom/b43/tables_lpphy.h
diff --git a/drivers/net/wireless/b43/tables_nphy.c b/drivers/net/wireless/broadcom/b43/tables_nphy.c
similarity index 100%
rename from drivers/net/wireless/b43/tables_nphy.c
rename to drivers/net/wireless/broadcom/b43/tables_nphy.c
diff --git a/drivers/net/wireless/b43/tables_nphy.h b/drivers/net/wireless/broadcom/b43/tables_nphy.h
similarity index 100%
rename from drivers/net/wireless/b43/tables_nphy.h
rename to drivers/net/wireless/broadcom/b43/tables_nphy.h
diff --git a/drivers/net/wireless/b43/tables_phy_ht.c b/drivers/net/wireless/broadcom/b43/tables_phy_ht.c
similarity index 100%
rename from drivers/net/wireless/b43/tables_phy_ht.c
rename to drivers/net/wireless/broadcom/b43/tables_phy_ht.c
diff --git a/drivers/net/wireless/b43/tables_phy_ht.h b/drivers/net/wireless/broadcom/b43/tables_phy_ht.h
similarity index 100%
rename from drivers/net/wireless/b43/tables_phy_ht.h
rename to drivers/net/wireless/broadcom/b43/tables_phy_ht.h
diff --git a/drivers/net/wireless/b43/tables_phy_lcn.c b/drivers/net/wireless/broadcom/b43/tables_phy_lcn.c
similarity index 100%
rename from drivers/net/wireless/b43/tables_phy_lcn.c
rename to drivers/net/wireless/broadcom/b43/tables_phy_lcn.c
diff --git a/drivers/net/wireless/b43/tables_phy_lcn.h b/drivers/net/wireless/broadcom/b43/tables_phy_lcn.h
similarity index 100%
rename from drivers/net/wireless/b43/tables_phy_lcn.h
rename to drivers/net/wireless/broadcom/b43/tables_phy_lcn.h
diff --git a/drivers/net/wireless/b43/wa.c b/drivers/net/wireless/broadcom/b43/wa.c
similarity index 100%
rename from drivers/net/wireless/b43/wa.c
rename to drivers/net/wireless/broadcom/b43/wa.c
diff --git a/drivers/net/wireless/b43/wa.h b/drivers/net/wireless/broadcom/b43/wa.h
similarity index 100%
rename from drivers/net/wireless/b43/wa.h
rename to drivers/net/wireless/broadcom/b43/wa.h
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/broadcom/b43/xmit.c
similarity index 100%
rename from drivers/net/wireless/b43/xmit.c
rename to drivers/net/wireless/broadcom/b43/xmit.c
diff --git a/drivers/net/wireless/b43/xmit.h b/drivers/net/wireless/broadcom/b43/xmit.h
similarity index 100%
rename from drivers/net/wireless/b43/xmit.h
rename to drivers/net/wireless/broadcom/b43/xmit.h
-- 
1.7.9.5
