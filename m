From: Gabriel C <crazy@pimpmylinux.org>
Subject: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 22:18:50 +0200
Message-ID: <469E75AA.7040109@pimpmylinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760878AbXGRUUZ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Everything 'depends on' EXPERIMENTAL should be marked as such, visible in the menus.


Signed-off-by: Gabriel Craciunescu <crazy@pimpmylinux.org>

---

 drivers/net/irda/Kconfig              |   14 +++++++-------
 drivers/net/usb/Kconfig               |    4 ++--
 drivers/net/wireless/Kconfig          |    8 ++++----
 drivers/net/wireless/bcm43xx/Kconfig  |    2 +-
 drivers/net/wireless/zd1211rw/Kconfig |    2 +-
 net/9p/Kconfig                        |    2 +-
 net/Kconfig                           |    2 +-
 net/decnet/netfilter/Kconfig          |    2 +-
 net/ieee80211/softmac/Kconfig         |    2 +-
 net/ipv4/Kconfig                      |   16 ++++++++--------
 net/ipv6/Kconfig                      |    2 +-
 net/ipv6/netfilter/Kconfig            |    2 +-
 net/mac80211/Kconfig                  |    2 +-
 net/rxrpc/Kconfig                     |    2 +-
 net/wanrouter/Kconfig                 |    2 +-
 15 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 829da9a..87285a1 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -84,7 +84,7 @@ config LITELINK_DONGLE
 	  "irattach -d litelink".
 
 config MA600_DONGLE
-	tristate "Mobile Action MA600 dongle"
+	tristate "Mobile Action MA600 dongle (EXPERIMENTAL)"
 	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Mobile Action MA600
@@ -97,7 +97,7 @@ config MA600_DONGLE
 	  "irattach -d ma600".
 
 config GIRBIL_DONGLE
-	tristate "Greenwich GIrBIL dongle"
+	tristate "Greenwich GIrBIL dongle (EXPERIMENTAL)"
 	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Greenwich GIrBIL
@@ -108,7 +108,7 @@ config GIRBIL_DONGLE
 	  like this: "irattach -d girbil".
 
 config MCP2120_DONGLE
-	tristate "Microchip MCP2120"
+	tristate "Microchip MCP2120 (EXPERIMENTAL)"
 	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Microchip MCP2120
@@ -122,7 +122,7 @@ config MCP2120_DONGLE
 	  <http://www.eyetap.org/~tangf/irda_sir_linux.html>
 
 config OLD_BELKIN_DONGLE
-	tristate "Old Belkin dongle"
+	tristate "Old Belkin dongle (EXPERIMENTAL)"
 	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the Adaptec Airport 1000
@@ -131,7 +131,7 @@ config OLD_BELKIN_DONGLE
 	  at the top of <file:drivers/net/irda/old_belkin.c>.
 
 config ACT200L_DONGLE
-	tristate "ACTiSYS IR-200L dongle"
+	tristate "ACTiSYS IR-200L dongle (EXPERIMENTAL)"
 	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
 	help
 	  Say Y here if you want to build support for the ACTiSYS IR-200L
@@ -142,7 +142,7 @@ config ACT200L_DONGLE
 	  start irattach like this: "irattach -d act200l".
 
 config KINGSUN_DONGLE
-	tristate "KingSun/DonShine DS-620 IrDA-USB dongle"
+	tristate "KingSun/DonShine DS-620 IrDA-USB dongle (EXPERIMENTAL)"
 	depends on IRDA && USB && EXPERIMENTAL
 	help
 	  Say Y or M here if you want to build support for the KingSun/DonShine
@@ -433,7 +433,7 @@ config PXA_FICP
 	  another.
 
 config MCS_FIR
-	tristate "MosChip MCS7780 IrDA-USB dongle"
+	tristate "MosChip MCS7780 IrDA-USB dongle (EXPERIMENTAL)"
 	depends on IRDA && USB && EXPERIMENTAL
 	help
 	  Say Y or M here if you want to build support for the MosChip
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 8dc09a3..387ae30 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -214,7 +214,7 @@ config USB_NET_NET1080
 	  optionally with LEDs that indicate traffic
 
 config USB_NET_PLUSB
-	tristate "Prolific PL-2301/2302 based cables"
+	tristate "Prolific PL-2301/2302 based cables (EXPERIMENTAL)"
 	# if the handshake/init/reset problems, from original 'plusb',
 	# are ever resolved ... then remove "experimental"
 	depends on USB_USBNET && EXPERIMENTAL
@@ -310,7 +310,7 @@ config USB_EPSON2888
 	  by some sample firmware from Epson.
 
 config USB_KC2190
-	boolean "KT Technology KC2190 based cables (InstaNet)"
+	boolean "KT Technology KC2190 based cables (InstaNet) (EXPERIMENTAL)"
 	depends on USB_NET_CDC_SUBSET && EXPERIMENTAL
 	help
 	  Choose this option if you're using a host-to-host cable
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index ae27af0..636a370 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -250,7 +250,7 @@ config IPW2200_PROMISCUOUS
             % echo 1 > /sys/bus/pci/drivers/ipw2200/*/rtap_iface
 
 config IPW2200_QOS
-        bool "Enable QoS support"
+        bool "Enable QoS support (EXPERIMENTAL)"
         depends on IPW2200 && EXPERIMENTAL
 
 config IPW2200_DEBUG
@@ -473,7 +473,7 @@ config PCMCIA_ATMEL
 	  Atmel at76c502 and at76c504 chips.
 
 config PCMCIA_WL3501
-      tristate "Planet WL3501 PCMCIA cards"
+      tristate "Planet WL3501 PCMCIA cards (EXPERIMENTAL)"
       depends on EXPERIMENTAL && PCMCIA && WLAN_80211
       select WIRELESS_EXT
        ---help---
@@ -482,7 +482,7 @@ config PCMCIA_WL3501
 	 micro support for ethtool.
 
 config PRISM54
-	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus' 
+	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus (EXPERIMENTAL)' 
 	depends on PCI && EXPERIMENTAL && WLAN_80211
 	select WIRELESS_EXT
 	select FW_LOADER
@@ -547,7 +547,7 @@ config USB_ZD1201
 	  module will be called zd1201.
 
 config RTL8187
-	tristate "Realtek 8187 USB support"
+	tristate "Realtek 8187 USB support (EXPERIMENTAL)"
 	depends on MAC80211 && USB && WLAN_80211 && EXPERIMENTAL
 	select EEPROM_93CX6
 	---help---
diff --git a/drivers/net/wireless/bcm43xx/Kconfig b/drivers/net/wireless/bcm43xx/Kconfig
index ce397e4..057781d 100644
--- a/drivers/net/wireless/bcm43xx/Kconfig
+++ b/drivers/net/wireless/bcm43xx/Kconfig
@@ -1,5 +1,5 @@
 config BCM43XX
-	tristate "Broadcom BCM43xx wireless support"
+	tristate "Broadcom BCM43xx wireless support (EXPERIMENTAL)"
 	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && WLAN_80211 && EXPERIMENTAL
 	select WIRELESS_EXT
 	select FW_LOADER
diff --git a/drivers/net/wireless/zd1211rw/Kconfig b/drivers/net/wireless/zd1211rw/Kconfig
index d1ab24a..1e7231b 100644
--- a/drivers/net/wireless/zd1211rw/Kconfig
+++ b/drivers/net/wireless/zd1211rw/Kconfig
@@ -1,5 +1,5 @@
 config ZD1211RW
-	tristate "ZyDAS ZD1211/ZD1211B USB-wireless support"
+	tristate "ZyDAS ZD1211/ZD1211B USB-wireless support (EXPERIMENTAL)"
 	depends on USB && IEEE80211_SOFTMAC && WLAN_80211 && EXPERIMENTAL
 	select WIRELESS_EXT
 	select FW_LOADER
diff --git a/net/9p/Kconfig b/net/9p/Kconfig
index 66821cd..02d86cc 100644
--- a/net/9p/Kconfig
+++ b/net/9p/Kconfig
@@ -4,7 +4,7 @@
 
 menuconfig NET_9P
 	depends on NET && EXPERIMENTAL
-	tristate "Plan 9 Resource Sharing Support (9P2000) (Experimental)"
+	tristate "Plan 9 Resource Sharing Support (9P2000) (EXPERIMENTAL)"
 	help
 	  If you say Y here, you will get experimental support for
 	  Plan 9 resource sharing via the 9P2000 protocol.
diff --git a/net/Kconfig b/net/Kconfig
index cdba08c..13e3d3b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -191,7 +191,7 @@ config NET_PKTGEN
 	  module will be called pktgen.
 
 config NET_TCPPROBE
-	tristate "TCP connection probing"
+	tristate "TCP connection probing (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL && PROC_FS && KPROBES
 	---help---
 	This module allows for capturing the changes to TCP connection
diff --git a/net/decnet/netfilter/Kconfig b/net/decnet/netfilter/Kconfig
index ecdb3f9..1b53545 100644
--- a/net/decnet/netfilter/Kconfig
+++ b/net/decnet/netfilter/Kconfig
@@ -2,7 +2,7 @@
 # DECnet netfilter configuration
 #
 
-menu "DECnet: Netfilter Configuration"
+menu "DECnet: Netfilter Configuration (EXPERIMENTAL)"
 	depends on DECNET && NETFILTER && EXPERIMENTAL
 
 config DECNET_NF_GRABULATOR
diff --git a/net/ieee80211/softmac/Kconfig b/net/ieee80211/softmac/Kconfig
index 2811651..02f14e4 100644
--- a/net/ieee80211/softmac/Kconfig
+++ b/net/ieee80211/softmac/Kconfig
@@ -1,5 +1,5 @@
 config IEEE80211_SOFTMAC
-	tristate "Software MAC add-on to the IEEE 802.11 networking stack"
+	tristate "Software MAC add-on to the IEEE 802.11 networking stack (EXPERIMENTAL)"
 	depends on IEEE80211 && EXPERIMENTAL
 	select WIRELESS_EXT
 	select IEEE80211_CRYPT_WEP
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index fb79097..3771fc5 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -469,7 +469,7 @@ config TCP_CONG_HTCP
 	other Reno and H-TCP flows.
 
 config TCP_CONG_HSTCP
-	tristate "High Speed TCP"
+	tristate "High Speed TCP (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
@@ -480,7 +480,7 @@ config TCP_CONG_HSTCP
  	For more detail	see http://www.icir.org/floyd/hstcp.html
 
 config TCP_CONG_HYBLA
-	tristate "TCP-Hybla congestion control algorithm"
+	tristate "TCP-Hybla congestion control algorithm (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
@@ -490,7 +490,7 @@ config TCP_CONG_HYBLA
 	terrestrial connections.
 
 config TCP_CONG_VEGAS
-	tristate "TCP Vegas"
+	tristate "TCP Vegas (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
@@ -501,7 +501,7 @@ config TCP_CONG_VEGAS
 	not as aggressive as TCP Reno.
 
 config TCP_CONG_SCALABLE
-	tristate "Scalable TCP"
+	tristate "Scalable TCP (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
@@ -511,7 +511,7 @@ config TCP_CONG_SCALABLE
 	See http://www.deneholme.net/tom/scalable/
 
 config TCP_CONG_LP
-	tristate "TCP Low Priority"
+	tristate "TCP Low Priority (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
@@ -521,7 +521,7 @@ config TCP_CONG_LP
 	See http://www-ece.rice.edu/networks/TCP-LP/
 
 config TCP_CONG_VENO
-	tristate "TCP Veno"
+	tristate "TCP Veno (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
@@ -533,7 +533,7 @@ config TCP_CONG_VENO
 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
 
 config TCP_CONG_YEAH
-	tristate "YeAH TCP"
+	tristate "YeAH TCP (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	select TCP_CONG_VEGAS
 	default n
@@ -548,7 +548,7 @@ config TCP_CONG_YEAH
 	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
 
 config TCP_CONG_ILLINOIS
-	tristate "TCP Illinois"
+	tristate "TCP Illinois (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	default n
 	---help---
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index eb0b808..1c16638 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -187,7 +187,7 @@ config IPV6_TUNNEL
 	  If unsure, say N.
 
 config IPV6_MULTIPLE_TABLES
-	bool "IPv6: Multiple Routing Tables"
+	bool "IPv6: Multiple Routing Tables (EXPERIMENTAL)"
 	depends on IPV6 && EXPERIMENTAL
 	select FIB_RULES
 	---help---
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 838b8dd..15b81b6 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -41,7 +41,7 @@ config IP6_NF_QUEUE
 	  To compile it as a module, choose M here.  If unsure, say N.
 
 config IP6_NF_IPTABLES
-	tristate "IP6 tables support (required for filtering)"
+	tristate "IP6 tables support (required for filtering) (EXPERIMENTAL)"
 	depends on INET && IPV6 && EXPERIMENTAL
 	select NETFILTER_XTABLES
 	help
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 6fffb38..7b7709e 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -1,5 +1,5 @@
 config MAC80211
-	tristate "Generic IEEE 802.11 Networking Stack (mac80211)"
+	tristate "Generic IEEE 802.11 Networking Stack (mac80211) (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	select CRYPTO
 	select CRYPTO_ECB
diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index e662f1d..739c58b 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config AF_RXRPC
-	tristate "RxRPC session sockets"
+	tristate "RxRPC session sockets (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
 	select KEYS
 	help
diff --git a/net/wanrouter/Kconfig b/net/wanrouter/Kconfig
index 1debe1c..3fa44c9 100644
--- a/net/wanrouter/Kconfig
+++ b/net/wanrouter/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config WAN_ROUTER
-	tristate "WAN router"
+	tristate "WAN router (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	---help---
 	  Wide Area Networks (WANs), such as X.25, frame relay and leased
