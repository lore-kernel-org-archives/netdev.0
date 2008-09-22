From: akpm@linux-foundation.org
Subject: [patch 12/21] netdev: drop CONFIG_PPC_MERGE from Kconfig
Date: Mon, 22 Sep 2008 14:52:19 -0700
Message-ID: <200809222152.m8MLqJsW031972@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	galak@kernel.crashing.org, benh@kernel.crashing.org,
	david@gibson.dropbear.id.au, jwboyer@linux.vnet.ibm.com,
	paulus@samba.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57975 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754215AbYIVV7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:59:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>

Now that arch/ppc is dead CONFIG_PPC_MERGE is always defined for all
powerpc platforms so we don't need to depend on it.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Cc: David Gibson <david@gibson.dropbear.id.au>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig             |    2 +-
 drivers/net/ibm_newemac/Kconfig |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/Kconfig~netdev-drop-config_ppc_merge-from-kconfig drivers/net/Kconfig
--- a/drivers/net/Kconfig~netdev-drop-config_ppc_merge-from-kconfig
+++ a/drivers/net/Kconfig
@@ -1800,7 +1800,7 @@ config FEC2
 
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
-	depends on PPC_MERGE && PPC_MPC52xx && PPC_BESTCOMM_FEC
+	depends on PPC_MPC52xx && PPC_BESTCOMM_FEC
 	select CRC32
 	select PHYLIB
 	---help---
diff -puN drivers/net/ibm_newemac/Kconfig~netdev-drop-config_ppc_merge-from-kconfig drivers/net/ibm_newemac/Kconfig
--- a/drivers/net/ibm_newemac/Kconfig~netdev-drop-config_ppc_merge-from-kconfig
+++ a/drivers/net/ibm_newemac/Kconfig
@@ -1,6 +1,6 @@
 config IBM_NEW_EMAC
 	tristate "IBM EMAC Ethernet support"
-	depends on PPC_DCR && PPC_MERGE
+	depends on PPC_DCR
 	select CRC32
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
_
