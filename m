From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH 2/3] [2.6.26] ehea: Add dependency to Kconfig
Date: Wed, 7 May 2008 14:43:20 +0200
Message-ID: <200805071443.20192.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:9449 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759101AbYEGMnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 08:43:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new ehea memory hot plug implementation depends on MEMORY_HOTPLUG.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f90a86b..181cd86 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2440,7 +2440,7 @@ config CHELSIO_T3
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM
+	depends on IBMEBUS && INET && SPARSEMEM && MEMORY_HOTPLUG
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
-- 
1.5.5.1
