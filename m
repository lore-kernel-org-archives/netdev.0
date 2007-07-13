From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/3] From: Jennifer Hunt <jenhunt@us.ibm.com>
Date: Fri, 13 Jul 2007 10:50:54 +0200
Message-ID: <20070713085244.950062000@linux.vnet.ibm.com>
References: <20070713085053.530802000@linux.vnet.ibm.com>
Cc: Jennifer Hunt <jenhunt@us.ibm.com>,
	Frank Pavlic <fpavlic@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:18653 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934829AbXGMIxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 04:53:10 -0400
Content-Disposition: inline; filename=200-iucv-kconfig.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] s390: iucv Kconfig.

Improve description of IUCV and AFIUCV configuration options.

Signed-off-by: Jennifer Hunt <jenhunt@us.ibm.com>
Signed-off-by: Ursula Braun >braunu@de.ibm.com>
Acked-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 net/iucv/Kconfig |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

Index: net-2.6-uschi/net/iucv/Kconfig
===================================================================
--- net-2.6-uschi.orig/net/iucv/Kconfig
+++ net-2.6-uschi/net/iucv/Kconfig
@@ -1,13 +1,13 @@
 config IUCV
-	tristate "IUCV support (VM only)"
+	tristate "IUCV support (S390 - z/VM only)"
 	depends on S390
 	help
-	  Select this option if you want to use inter-user communication under
-	  VM or VIF sockets. If you run on z/VM, say "Y" to enable a fast
+	  Select this option if you want to use inter-user communication
+	  under VM or VIF. If you run on z/VM, say "Y" to enable a fast
 	  communication link between VM guests.
 
 config AFIUCV
-	tristate "AF_IUCV support (VM only)"
+	tristate "AF_IUCV support (S390 - z/VM only)"
 	depends on IUCV
 	help
 	  Select this option if you want to use inter-user communication under

-- 
