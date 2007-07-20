From: Sebastian Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] netdev: Network drivers should depend on Network
Date: Sat, 21 Jul 2007 00:58:04 +0200
Message-ID: <20070720225818.234649824@ayoka.breakpoint.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:37871 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758936AbXGTXc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 19:32:58 -0400
Received: id: bigeasy by Chamillionaire.breakpoint.cc authenticated by bigeasy with local
	(easymta 1.00 BETA 1)
	id 1IC1xx-0001G6-Qs
	for netdev@vger.kernel.org; Sat, 21 Jul 2007 01:32:57 +0200
Content-Disposition: inline; filename=net_devices_depend_on_network.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Got with randconfig:
XXX: undefined reference to `netif_carrier_on'
XXX: undefined reference to `dev_queue_xmit'
...

Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
Index: b/drivers/net/Kconfig
===================================================================
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -5,6 +5,7 @@
 
 menuconfig NETDEVICES
 	default y if UML
+	depends on NET
 	bool "Network device support"
 	---help---
 	  You can say N here if you don't intend to connect your Linux box to

-- 

