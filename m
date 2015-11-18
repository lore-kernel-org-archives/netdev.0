From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 13/27] mwifiex: move under marvell vendor directory
Date: Wed, 18 Nov 2015 16:45:52 +0200
Message-ID: <1447857966-19560-14-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Makefile                      |    2 --
 drivers/net/wireless/marvell/Kconfig               |    1 +
 drivers/net/wireless/marvell/Makefile              |    1 +
 drivers/net/wireless/{ => marvell}/mwifiex/11ac.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11ac.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11h.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11n.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11n.h   |    0
 .../net/wireless/{ => marvell}/mwifiex/11n_aggr.c  |    0
 .../net/wireless/{ => marvell}/mwifiex/11n_aggr.h  |    0
 .../wireless/{ => marvell}/mwifiex/11n_rxreorder.c |    0
 .../wireless/{ => marvell}/mwifiex/11n_rxreorder.h |    0
 drivers/net/wireless/{ => marvell}/mwifiex/Kconfig |    0
 .../net/wireless/{ => marvell}/mwifiex/Makefile    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/README  |    0
 .../net/wireless/{ => marvell}/mwifiex/cfg80211.c  |    0
 .../net/wireless/{ => marvell}/mwifiex/cfg80211.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/cfp.c   |    0
 .../net/wireless/{ => marvell}/mwifiex/cmdevt.c    |    0
 .../net/wireless/{ => marvell}/mwifiex/debugfs.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/decl.h  |    0
 .../net/wireless/{ => marvell}/mwifiex/ethtool.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/fw.h    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/ie.c    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/init.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/ioctl.h |    0
 drivers/net/wireless/{ => marvell}/mwifiex/join.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/main.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/main.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/pcie.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/pcie.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/scan.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/sdio.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/sdio.h  |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_cmd.c   |    0
 .../wireless/{ => marvell}/mwifiex/sta_cmdresp.c   |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_event.c |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_ioctl.c |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_rx.c    |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_tx.c    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/tdls.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/txrx.c  |    0
 .../net/wireless/{ => marvell}/mwifiex/uap_cmd.c   |    0
 .../net/wireless/{ => marvell}/mwifiex/uap_event.c |    0
 .../net/wireless/{ => marvell}/mwifiex/uap_txrx.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/usb.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/usb.h   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/util.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/util.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/wmm.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/wmm.h   |    0
 53 files changed, 3 insertions(+), 4 deletions(-)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11ac.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11ac.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11h.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_aggr.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_aggr.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_rxreorder.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_rxreorder.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/Kconfig (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/Makefile (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/README (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cfg80211.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cfg80211.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cfp.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cmdevt.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/debugfs.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/decl.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/ethtool.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/fw.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/ie.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/init.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/ioctl.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/join.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/main.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/main.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/pcie.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/pcie.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/scan.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sdio.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sdio.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_cmdresp.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_event.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_ioctl.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_rx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_tx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/tdls.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/txrx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/uap_cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/uap_event.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/uap_txrx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/usb.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/usb.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/util.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/util.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/wmm.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/wmm.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 75ff7434db0e..5b889f6972c0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6728,7 +6728,7 @@ M:	Amitkumar Karwar <akarwar@marvell.com>
 M:	Nishant Sarmukadam <nishants@marvell.com>
 L:	linux-wireless@vger.kernel.org
 S:	Maintained
-F:	drivers/net/wireless/mwifiex/
+F:	drivers/net/wireless/marvell/mwifiex/
 
 MARVELL MWL8K WIRELESS DRIVER
 M:	Lennert Buytenhek <buytenh@wantstofly.org>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 25f52b32d725..465665237308 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -152,7 +152,6 @@ source "drivers/net/wireless/realtek/rtlwifi/Kconfig"
 source "drivers/net/wireless/realtek/rtl8xxxu/Kconfig"
 source "drivers/net/wireless/ti/Kconfig"
 source "drivers/net/wireless/zd1211rw/Kconfig"
-source "drivers/net/wireless/mwifiex/Kconfig"
 source "drivers/net/wireless/rsi/Kconfig"
 
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 72b167742ac7..7a95b58a5c76 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -40,6 +40,4 @@ obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
 
 obj-$(CONFIG_WL_TI)	+= ti/
 
-obj-$(CONFIG_MWIFIEX)	+= mwifiex/
-
 obj-$(CONFIG_RSI_91X)	+= rsi/
diff --git a/drivers/net/wireless/marvell/Kconfig b/drivers/net/wireless/marvell/Kconfig
index 97ec8f35745e..bbdbac9a2a45 100644
--- a/drivers/net/wireless/marvell/Kconfig
+++ b/drivers/net/wireless/marvell/Kconfig
@@ -13,5 +13,6 @@ if WLAN_VENDOR_MARVELL
 
 source "drivers/net/wireless/marvell/libertas/Kconfig"
 source "drivers/net/wireless/marvell/libertas_tf/Kconfig"
+source "drivers/net/wireless/marvell/mwifiex/Kconfig"
 
 endif # WLAN_VENDOR_MARVELL
diff --git a/drivers/net/wireless/marvell/Makefile b/drivers/net/wireless/marvell/Makefile
index 8f5eb423b71a..f4ab48aaff3c 100644
--- a/drivers/net/wireless/marvell/Makefile
+++ b/drivers/net/wireless/marvell/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_LIBERTAS)		+= libertas/
 
 obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
+obj-$(CONFIG_MWIFIEX)	+= mwifiex/
diff --git a/drivers/net/wireless/mwifiex/11ac.c b/drivers/net/wireless/marvell/mwifiex/11ac.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/11ac.c
rename to drivers/net/wireless/marvell/mwifiex/11ac.c
diff --git a/drivers/net/wireless/mwifiex/11ac.h b/drivers/net/wireless/marvell/mwifiex/11ac.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/11ac.h
rename to drivers/net/wireless/marvell/mwifiex/11ac.h
diff --git a/drivers/net/wireless/mwifiex/11h.c b/drivers/net/wireless/marvell/mwifiex/11h.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/11h.c
rename to drivers/net/wireless/marvell/mwifiex/11h.c
diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/marvell/mwifiex/11n.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/11n.c
rename to drivers/net/wireless/marvell/mwifiex/11n.c
diff --git a/drivers/net/wireless/mwifiex/11n.h b/drivers/net/wireless/marvell/mwifiex/11n.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/11n.h
rename to drivers/net/wireless/marvell/mwifiex/11n.h
diff --git a/drivers/net/wireless/mwifiex/11n_aggr.c b/drivers/net/wireless/marvell/mwifiex/11n_aggr.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/11n_aggr.c
rename to drivers/net/wireless/marvell/mwifiex/11n_aggr.c
diff --git a/drivers/net/wireless/mwifiex/11n_aggr.h b/drivers/net/wireless/marvell/mwifiex/11n_aggr.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/11n_aggr.h
rename to drivers/net/wireless/marvell/mwifiex/11n_aggr.h
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/11n_rxreorder.c
rename to drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.h b/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/11n_rxreorder.h
rename to drivers/net/wireless/marvell/mwifiex/11n_rxreorder.h
diff --git a/drivers/net/wireless/mwifiex/Kconfig b/drivers/net/wireless/marvell/mwifiex/Kconfig
similarity index 100%
rename from drivers/net/wireless/mwifiex/Kconfig
rename to drivers/net/wireless/marvell/mwifiex/Kconfig
diff --git a/drivers/net/wireless/mwifiex/Makefile b/drivers/net/wireless/marvell/mwifiex/Makefile
similarity index 100%
rename from drivers/net/wireless/mwifiex/Makefile
rename to drivers/net/wireless/marvell/mwifiex/Makefile
diff --git a/drivers/net/wireless/mwifiex/README b/drivers/net/wireless/marvell/mwifiex/README
similarity index 100%
rename from drivers/net/wireless/mwifiex/README
rename to drivers/net/wireless/marvell/mwifiex/README
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/cfg80211.c
rename to drivers/net/wireless/marvell/mwifiex/cfg80211.c
diff --git a/drivers/net/wireless/mwifiex/cfg80211.h b/drivers/net/wireless/marvell/mwifiex/cfg80211.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/cfg80211.h
rename to drivers/net/wireless/marvell/mwifiex/cfg80211.h
diff --git a/drivers/net/wireless/mwifiex/cfp.c b/drivers/net/wireless/marvell/mwifiex/cfp.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/cfp.c
rename to drivers/net/wireless/marvell/mwifiex/cfp.c
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/cmdevt.c
rename to drivers/net/wireless/marvell/mwifiex/cmdevt.c
diff --git a/drivers/net/wireless/mwifiex/debugfs.c b/drivers/net/wireless/marvell/mwifiex/debugfs.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/debugfs.c
rename to drivers/net/wireless/marvell/mwifiex/debugfs.c
diff --git a/drivers/net/wireless/mwifiex/decl.h b/drivers/net/wireless/marvell/mwifiex/decl.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/decl.h
rename to drivers/net/wireless/marvell/mwifiex/decl.h
diff --git a/drivers/net/wireless/mwifiex/ethtool.c b/drivers/net/wireless/marvell/mwifiex/ethtool.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/ethtool.c
rename to drivers/net/wireless/marvell/mwifiex/ethtool.c
diff --git a/drivers/net/wireless/mwifiex/fw.h b/drivers/net/wireless/marvell/mwifiex/fw.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/fw.h
rename to drivers/net/wireless/marvell/mwifiex/fw.h
diff --git a/drivers/net/wireless/mwifiex/ie.c b/drivers/net/wireless/marvell/mwifiex/ie.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/ie.c
rename to drivers/net/wireless/marvell/mwifiex/ie.c
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/marvell/mwifiex/init.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/init.c
rename to drivers/net/wireless/marvell/mwifiex/init.c
diff --git a/drivers/net/wireless/mwifiex/ioctl.h b/drivers/net/wireless/marvell/mwifiex/ioctl.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/ioctl.h
rename to drivers/net/wireless/marvell/mwifiex/ioctl.h
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/marvell/mwifiex/join.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/join.c
rename to drivers/net/wireless/marvell/mwifiex/join.c
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/main.c
rename to drivers/net/wireless/marvell/mwifiex/main.c
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/marvell/mwifiex/main.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/main.h
rename to drivers/net/wireless/marvell/mwifiex/main.h
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/pcie.c
rename to drivers/net/wireless/marvell/mwifiex/pcie.c
diff --git a/drivers/net/wireless/mwifiex/pcie.h b/drivers/net/wireless/marvell/mwifiex/pcie.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/pcie.h
rename to drivers/net/wireless/marvell/mwifiex/pcie.h
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/marvell/mwifiex/scan.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/scan.c
rename to drivers/net/wireless/marvell/mwifiex/scan.c
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sdio.c
rename to drivers/net/wireless/marvell/mwifiex/sdio.c
diff --git a/drivers/net/wireless/mwifiex/sdio.h b/drivers/net/wireless/marvell/mwifiex/sdio.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/sdio.h
rename to drivers/net/wireless/marvell/mwifiex/sdio.h
diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sta_cmd.c
rename to drivers/net/wireless/marvell/mwifiex/sta_cmd.c
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sta_cmdresp.c
rename to drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
diff --git a/drivers/net/wireless/mwifiex/sta_event.c b/drivers/net/wireless/marvell/mwifiex/sta_event.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sta_event.c
rename to drivers/net/wireless/marvell/mwifiex/sta_event.c
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sta_ioctl.c
rename to drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
diff --git a/drivers/net/wireless/mwifiex/sta_rx.c b/drivers/net/wireless/marvell/mwifiex/sta_rx.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sta_rx.c
rename to drivers/net/wireless/marvell/mwifiex/sta_rx.c
diff --git a/drivers/net/wireless/mwifiex/sta_tx.c b/drivers/net/wireless/marvell/mwifiex/sta_tx.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/sta_tx.c
rename to drivers/net/wireless/marvell/mwifiex/sta_tx.c
diff --git a/drivers/net/wireless/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/tdls.c
rename to drivers/net/wireless/marvell/mwifiex/tdls.c
diff --git a/drivers/net/wireless/mwifiex/txrx.c b/drivers/net/wireless/marvell/mwifiex/txrx.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/txrx.c
rename to drivers/net/wireless/marvell/mwifiex/txrx.c
diff --git a/drivers/net/wireless/mwifiex/uap_cmd.c b/drivers/net/wireless/marvell/mwifiex/uap_cmd.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/uap_cmd.c
rename to drivers/net/wireless/marvell/mwifiex/uap_cmd.c
diff --git a/drivers/net/wireless/mwifiex/uap_event.c b/drivers/net/wireless/marvell/mwifiex/uap_event.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/uap_event.c
rename to drivers/net/wireless/marvell/mwifiex/uap_event.c
diff --git a/drivers/net/wireless/mwifiex/uap_txrx.c b/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/uap_txrx.c
rename to drivers/net/wireless/marvell/mwifiex/uap_txrx.c
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/marvell/mwifiex/usb.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/usb.c
rename to drivers/net/wireless/marvell/mwifiex/usb.c
diff --git a/drivers/net/wireless/mwifiex/usb.h b/drivers/net/wireless/marvell/mwifiex/usb.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/usb.h
rename to drivers/net/wireless/marvell/mwifiex/usb.h
diff --git a/drivers/net/wireless/mwifiex/util.c b/drivers/net/wireless/marvell/mwifiex/util.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/util.c
rename to drivers/net/wireless/marvell/mwifiex/util.c
diff --git a/drivers/net/wireless/mwifiex/util.h b/drivers/net/wireless/marvell/mwifiex/util.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/util.h
rename to drivers/net/wireless/marvell/mwifiex/util.h
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/marvell/mwifiex/wmm.c
similarity index 100%
rename from drivers/net/wireless/mwifiex/wmm.c
rename to drivers/net/wireless/marvell/mwifiex/wmm.c
diff --git a/drivers/net/wireless/mwifiex/wmm.h b/drivers/net/wireless/marvell/mwifiex/wmm.h
similarity index 100%
rename from drivers/net/wireless/mwifiex/wmm.h
rename to drivers/net/wireless/marvell/mwifiex/wmm.h
-- 
1.7.9.5
