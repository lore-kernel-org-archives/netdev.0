From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 11/20] drivers/net/wireless: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:35 -0800
Message-ID: <1358879444-25834-12-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

CC: "John W. Linville" <linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/Kconfig |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 28aa05f..f8f0156 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -138,7 +138,7 @@ config AIRO_CS
 
 config PCMCIA_WL3501
 	tristate "Planet WL3501 PCMCIA cards"
-	depends on EXPERIMENTAL && PCMCIA
+	depends on PCMCIA
 	select WIRELESS_EXT
 	select WEXT_SPY
 	help
@@ -148,7 +148,7 @@ config PCMCIA_WL3501
 
 config PRISM54
 	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus (DEPRECATED)'
-	depends on PCI && EXPERIMENTAL
+	depends on PCI
 	select WIRELESS_EXT
 	select WEXT_SPY
 	select WEXT_PRIV
@@ -187,7 +187,7 @@ config USB_ZD1201
 
 config USB_NET_RNDIS_WLAN
 	tristate "Wireless RNDIS USB support"
-	depends on USB && EXPERIMENTAL
+	depends on USB
 	depends on CFG80211
 	select USB_USBNET
 	select USB_NET_CDCETHER
@@ -217,7 +217,7 @@ source "drivers/net/wireless/rtl818x/Kconfig"
 
 config ADM8211
 	tristate "ADMtek ADM8211 support"
-	depends on MAC80211 && PCI && EXPERIMENTAL
+	depends on MAC80211 && PCI
 	select CRC32
 	select EEPROM_93CX6
 	---help---
@@ -257,7 +257,7 @@ config MAC80211_HWSIM
 
 config MWL8K
 	tristate "Marvell 88W8xxx PCI/PCIe Wireless support"
-	depends on MAC80211 && PCI && EXPERIMENTAL
+	depends on MAC80211 && PCI
 	---help---
 	  This driver supports Marvell TOPDOG 802.11 wireless cards.
 
-- 
1.7.9.5
