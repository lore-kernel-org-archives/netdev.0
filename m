From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] igb: remove LRO Kconfig option
Date: Wed, 18 Feb 2009 01:23:27 -0800
Message-ID: <20090218092323.21256.81827.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:58645
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbZBRJXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:23:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To match ixgbe GRO functionality, we remove the LRO (which is now GRO) Kconfig option which enables GRO by default.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig        |    8 --------
 drivers/net/igb/igb_main.c |    2 --
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3fed334..683a5ac 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2019,14 +2019,6 @@ config IGB
          To compile this driver as a module, choose M here. The module
          will be called igb.
 
-config IGB_LRO 
-	bool "Use software LRO"
-	depends on IGB && INET
-	---help---
-	  Say Y here if you want to use large receive offload. 
-
-	  If in doubt, say N.
-
 config IGB_DCA
 	bool "Direct Cache Access (DCA) Support"
 	default y
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 43f489a..457f12e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1248,9 +1248,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 
-#ifdef CONFIG_IGB_LRO
 	netdev->features |= NETIF_F_GRO;
-#endif
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;

