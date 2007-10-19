From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] NAPI: kconfig prompt and deleted doc file
Date: Thu, 18 Oct 2007 17:16:20 -0700
Message-ID: <20071018171620.dd30b173.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45863 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262AbXJSARG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 20:17:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

- make the kconfig NAPI option prompt consistent across all net drivers
  (other than EXPERIMENTAL; can it now be removed also, or is the new
  napi_struct implementation now EXPERIMENTAL ?)
- remove comment about the now-deleted NAPI_HOWTO.txt file
- clean up typos in Tulip NAPI & Interrupt Mitigation

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig       |   37 +++++--------------------------------
 drivers/net/tulip/Kconfig |   14 ++++++--------
 2 files changed, 11 insertions(+), 40 deletions(-)

--- linux-2.6.23-git13.orig/drivers/net/Kconfig
+++ linux-2.6.23-git13/drivers/net/Kconfig
@@ -1293,9 +1293,6 @@ config PCNET32_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config AMD8111_ETH
@@ -1313,7 +1310,7 @@ config AMD8111_ETH
 	  will be called amd8111e.
 
 config AMD8111E_NAPI
-	bool "Enable NAPI support"
+	bool "Use RX polling (NAPI)"
 	depends on AMD8111_ETH
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -1324,9 +1321,6 @@ config AMD8111E_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config ADAPTEC_STARFIRE
@@ -1355,9 +1349,6 @@ config ADAPTEC_STARFIRE_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config AC3200
@@ -1431,7 +1422,7 @@ config FORCEDETH
 	  called forcedeth.
 
 config FORCEDETH_NAPI
-	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
 	depends on FORCEDETH && EXPERIMENTAL
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -1442,9 +1433,6 @@ config FORCEDETH_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config CS89x0
@@ -1756,9 +1744,6 @@ config VIA_RHINE_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 config LAN_SAA9730
 	bool "Philips SAA9730 Ethernet support"
 	depends on NET_PCI && PCI && MIPS_ATLAS
@@ -2003,9 +1988,6 @@ config E1000_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config E1000_DISABLE_PACKET_SPLIT
@@ -2099,7 +2081,7 @@ config R8169
 	  will be called r8169.  This is recommended.
 
 config R8169_NAPI
-	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
 	depends on R8169 && EXPERIMENTAL
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -2110,9 +2092,6 @@ config R8169_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config R8169_VLAN
@@ -2364,7 +2343,7 @@ config GIANFAR
 	  and MPC86xx family of chips, and the FEC on the 8540.
 
 config GFAR_NAPI
-	bool "NAPI Support"
+	bool "Use Rx Polling (NAPI)"
 	depends on GIANFAR
 
 config UCC_GETH
@@ -2376,7 +2355,7 @@ config UCC_GETH
 	  which is available on some Freescale SOCs.
 
 config UGETH_NAPI
-	bool "NAPI Support"
+	bool "Use Rx Polling (NAPI)"
 	depends on UCC_GETH
 
 config UGETH_MAGIC_PACKET
@@ -2559,9 +2538,6 @@ config IXGB_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config S2IO
@@ -2584,9 +2560,6 @@ config S2IO_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config MYRI10GE
--- linux-2.6.23-git13.orig/drivers/net/tulip/Kconfig
+++ linux-2.6.23-git13/drivers/net/tulip/Kconfig
@@ -67,7 +67,7 @@ config TULIP_MMIO
 	  If in doubt, say N.
 
 config TULIP_NAPI
-	bool "Use NAPI RX polling "
+	bool "Use RX polling (NAPI)"
 	depends on TULIP
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -78,18 +78,16 @@ config TULIP_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config TULIP_NAPI_HW_MITIGATION
-	bool "Use Interrupt Mitigation "
+	bool "Use Interrupt Mitigation"
 	depends on TULIP_NAPI
 	---help---
-	  Use HW to reduce RX interrupts. Not strict necessary since NAPI reduces
-	  RX interrupts but itself. Although this reduces RX interrupts even at
-	  low levels traffic at the cost of a small latency.
+	  Use HW to reduce RX interrupts. Not strictly necessary since NAPI
+	  reduces RX interrupts by itself. Interrupt mitigation reduces RX
+	  interrupts even at low levels of traffic at the cost of a small
+	  latency.
 
 	  If in doubt, say Y.
 
