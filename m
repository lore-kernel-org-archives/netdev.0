From: Hannes Hering <hannes.hering@gmx.de>
Subject: [PATCH 2/2] ehea: Enable DLPAR memory remove
Date: Fri, 5 Sep 2008 16:38:22 +0200
Message-ID: <200809051638.22160.hannes.hering@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:33298 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbYIEOi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 10:38:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the capability flag to the capability list for dynamic LPAR
memory remove to enable this feature.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---

diff -Nurp -X dontdiff linux-2.6.27-rc5/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.27-rc5/drivers/net/ehea/ehea.h	2008-08-29 00:52:02.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-09-05 15:33:12.000000000 +0200
@@ -40,13 +40,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0092"
+#define DRV_VERSION	"EHEA_0093"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
 #define DLPAR_MEM_ADD      2
 #define DLPAR_MEM_REM      4
-#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD)
+#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD | DLPAR_MEM_REM)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
