From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH] cxgb4: Update Kconfig to include Chelsio T5 adapter
Date: Fri, 25 Apr 2014 18:00:12 +0530
Message-ID: <1398429012-9067-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <leedom@chelsio.com>, <dm@chelsio.com>,
	<kumaras@chelsio.com>, <nirranjan@chelsio.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17361 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbaDYMbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 08:31:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index d40c994..570222c 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -67,13 +67,13 @@ config CHELSIO_T3
 	  will be called cxgb3.
 
 config CHELSIO_T4
-	tristate "Chelsio Communications T4 Ethernet support"
+	tristate "Chelsio Communications T4/T5 Ethernet support"
 	depends on PCI
 	select FW_LOADER
 	select MDIO
 	---help---
-	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
-	  adapters.
+	  This driver supports Chelsio T4 and T5 based gigabit, 10Gb Ethernet
+	  adapter and T5 based 40Gb Ethernet adapter.
 
 	  For general information about Chelsio and our products, visit
 	  our website at <http://www.chelsio.com>.
@@ -87,11 +87,12 @@ config CHELSIO_T4
 	  will be called cxgb4.
 
 config CHELSIO_T4VF
-	tristate "Chelsio Communications T4 Virtual Function Ethernet support"
+	tristate "Chelsio Communications T4/T5 Virtual Function Ethernet support"
 	depends on PCI
 	---help---
-	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
-	  adapters with PCI-E SR-IOV Virtual Functions.
+	  This driver supports Chelsio T4 and T5 based gigabit, 10Gb Ethernet
+	  adapters and T5 based 40Gb Ethernet adapters with PCI-E SR-IOV Virtual
+	  Functions.
 
 	  For general information about Chelsio and our products, visit
 	  our website at <http://www.chelsio.com>.
-- 
1.8.4
