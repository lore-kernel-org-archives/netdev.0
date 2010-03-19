From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next PATCH 5/5] enic: Clean up: Change driver description;
	Fix tab space; Update MAINTAINERS
Date: Thu, 18 Mar 2010 19:20:04 -0700
Message-ID: <20100319022004.10527.77863.stgit@savbu-pc100.cisco.com>
References: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42826 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab0CSCUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 22:20:05 -0400
In-Reply-To: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

1) Change enic driver description to "Cisco VIC Ethernet NIC Driver"
2) Fix tab space
3) Update MAINTAINERS list

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 MAINTAINERS                  |    5 +++--
 drivers/net/Kconfig          |    4 ++--
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    2 +-
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 47cc449..34f09e4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1482,9 +1482,10 @@ M:	Andy Whitcroft <apw@canonical.com>
 S:	Supported
 F:	scripts/checkpatch.pl
 
-CISCO 10G ETHERNET DRIVER
+CISCO VIC ETHERNET NIC DRIVER
 M:	Scott Feldman <scofeldm@cisco.com>
-M:	Joe Eykholt <jeykholt@cisco.com>
+M:	Vasanthy Kolluri <vkolluri@cisco.com>
+M:	Roopa Prabhu <roprabhu@cisco.com>
 S:	Supported
 F:	drivers/net/enic/
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0ba5b8e..bf223fb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2593,11 +2593,11 @@ config EHEA
 	  will be called ehea.
 
 config ENIC
-	tristate "Cisco 10G Ethernet NIC support"
+	tristate "Cisco VIC Ethernet NIC Support"
 	depends on PCI && INET
 	select INET_LRO
 	help
-	  This enables the support for the Cisco 10G Ethernet card.
+	  This enables the support for the Cisco VIC Ethernet card.
 
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 9f5ed3e..5fa56f1 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -33,7 +33,7 @@
 #include "vnic_rss.h"
 
 #define DRV_NAME		"enic"
-#define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
+#define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
 #define DRV_VERSION		"1.3.1.1"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 18c043a..6d70c34 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -829,7 +829,7 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	int promisc = (netdev->flags & IFF_PROMISC) ? 1 : 0;
 	unsigned int mc_count = netdev_mc_count(netdev);
 	int allmulti = (netdev->flags & IFF_ALLMULTI) ||
-		       mc_count > ENIC_MULTICAST_PERFECT_FILTERS;
+		mc_count > ENIC_MULTICAST_PERFECT_FILTERS;
 	unsigned int flags = netdev->flags | (allmulti ? IFF_ALLMULTI : 0);
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
 	unsigned int i, j;

