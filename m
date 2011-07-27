From: frank.blaschka@de.ibm.com
Subject: [patch 05/11] [PATCH] if_ether: add new Ethernet Protocol ID for af_iucv
Date: Wed, 27 Jul 2011 18:12:47 +0200
Message-ID: <20110727161338.880975467@de.ibm.com>
References: <20110727161242.018577444@de.ibm.com>
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:46686 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731Ab1G0QNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:13:54 -0400
Content-Disposition: inline; filename=net1117-af_iucv-new-protocol-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Add a new ethertype for af_iucv over s/390 HiperSockets transport. Since
HiperSockets is not a real ethernet hw this is not an officially registered ID.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 include/linux/if_ether.h |    1 +
 1 file changed, 1 insertion(+)

--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -88,6 +88,7 @@
 #define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
+#define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*
  *	Non DIX types. Won't clash for 1500 types.

