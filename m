From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] Kconfig: remove redundant NETDEVICES depends
Date: Wed, 1 Nov 2006 21:18:58 -0800
Message-ID: <20061101211858.3ce36fca.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:4753 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1752655AbWKBFYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 00:24:43 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

drivers/net/Kconfig says:
# All the following symbols are dependent on NETDEVICES - do not repeat
# that for each of the symbols.

so remove duplicate 'depends' uses of NETDEVICES.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2619-rc4g2.orig/drivers/net/Kconfig
+++ linux-2619-rc4g2/drivers/net/Kconfig
@@ -476,7 +476,7 @@ config SGI_IOC3_ETH_HW_TX_CSUM
 
 config MIPS_SIM_NET
 	tristate "MIPS simulator Network device (EXPERIMENTAL)"
-	depends on NETDEVICES && MIPS_SIM && EXPERIMENTAL
+	depends on MIPS_SIM && EXPERIMENTAL
 	help
 	  The MIPSNET device is a simple Ethernet network device which is
 	  emulated by the MIPS Simulator.
@@ -2466,7 +2466,7 @@ config ISERIES_VETH
 
 config RIONET
 	tristate "RapidIO Ethernet over messaging driver support"
-	depends on NETDEVICES && RAPIDIO
+	depends on RAPIDIO
 
 config RIONET_TX_SIZE
 	int "Number of outbound queue entries"


---
