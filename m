From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/7] cxgb4/cxgb4vf: update Kconfig file to include T6 adapter
Date: Tue,  8 Dec 2015 10:09:12 +0530
Message-ID: <1449549557-16023-3-git-send-email-hariprasad@chelsio.com>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:18884 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753438AbbLHEiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:15 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index a79813a..4d187f2 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -65,13 +65,14 @@ config CHELSIO_T3
 	  will be called cxgb3.
 
 config CHELSIO_T4
-	tristate "Chelsio Communications T4/T5 Ethernet support"
+	tristate "Chelsio Communications T4/T5/T6 Ethernet support"
 	depends on PCI && (IPV6 || IPV6=n)
 	select FW_LOADER
 	select MDIO
 	---help---
-	  This driver supports Chelsio T4 and T5 based gigabit, 10Gb Ethernet
-	  adapter and T5 based 40Gb Ethernet adapter.
+	  This driver supports Chelsio T4, T5 & T6 based gigabit, 10Gb Ethernet
+	  adapter and T5/T6 based 40Gb and T6 based 25Gb, 50Gb and 100Gb
+	  Ethernet adapters.
 
 	  For general information about Chelsio and our products, visit
 	  our website at <http://www.chelsio.com>.
@@ -85,7 +86,7 @@ config CHELSIO_T4
 	  will be called cxgb4.
 
 config CHELSIO_T4_DCB
-	bool "Data Center Bridging (DCB) Support for Chelsio T4/T5 cards"
+	bool "Data Center Bridging (DCB) Support for Chelsio T4/T5/T6 cards"
 	default n
 	depends on CHELSIO_T4 && DCB
 	---help---
@@ -107,12 +108,12 @@ config CHELSIO_T4_FCOE
 	  If unsure, say N.
 
 config CHELSIO_T4VF
-	tristate "Chelsio Communications T4/T5 Virtual Function Ethernet support"
+	tristate "Chelsio Communications T4/T5/T6 Virtual Function Ethernet support"
 	depends on PCI
 	---help---
-	  This driver supports Chelsio T4 and T5 based gigabit, 10Gb Ethernet
-	  adapters and T5 based 40Gb Ethernet adapters with PCI-E SR-IOV Virtual
-	  Functions.
+	  This driver supports Chelsio T4, T5 & T6 based gigabit, 10Gb Ethernet
+	  adapters and T5/T6 based 40Gb and T6 based 25Gb, 50Gb and 100Gb
+	  Ethernet adapters with PCI-E SR-IOV Virtual Functions.
 
 	  For general information about Chelsio and our products, visit
 	  our website at <http://www.chelsio.com>.
-- 
2.3.4
