From: akpm@linux-foundation.org
Subject: [patch for 2.6.25? 2/3] ehea: fix IPv6 support
Date: Thu, 27 Mar 2008 00:45:13 -0700
Message-ID: <200803270745.m2R7jDkC024163@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	osstklei@de.ibm.com, davem@davemloft.net, hering2@de.ibm.com,
	raisch@de.ibm.com, stable@kernel.org, stefan.roscher@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbYC0Hpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 03:45:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Klein <osstklei@de.ibm.com>

Indicate that EHEA calculates IPv4 checksums only

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Christoph Raisch <raisch@de.ibm.com>
Cc: "Jan-Bernd Themann" <themann@de.ibm.com>
Cc: Stefan Roscher <stefan.roscher@de.ibm.com>
Cc: Hannes Hering <hering2@de.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ehea/ehea.h~ehea-fix-ipv6-support drivers/net/ehea/ehea.h
--- a/drivers/net/ehea/ehea.h~ehea-fix-ipv6-support
+++ a/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0087"
+#define DRV_VERSION	"EHEA_0089"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -puN drivers/net/ehea/ehea_main.c~ehea-fix-ipv6-support drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~ehea-fix-ipv6-support
+++ a/drivers/net/ehea/ehea_main.c
@@ -3110,7 +3110,7 @@ struct ehea_port *ehea_setup_single_port
 	dev->vlan_rx_add_vid = ehea_vlan_rx_add_vid;
 	dev->vlan_rx_kill_vid = ehea_vlan_rx_kill_vid;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
-		      | NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX
+		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_LLTX;
 	dev->tx_timeout = &ehea_tx_watchdog;
_
