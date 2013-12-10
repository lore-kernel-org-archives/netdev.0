From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] ixgbevf: update Kconfig description
Date: Tue, 10 Dec 2013 02:22:35 -0800
Message-ID: <1386670961-20392-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21187 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752685Ab3LJKXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:11 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch updates the ixgbevf Kconfig description, as the VF driver supports
more than just the 82599 device. This patch renames the config menu item, as
well as updates the help description to make it more obvious that the driver
supports more than just a single device group.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 149ac85..41a2fa2 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -220,12 +220,12 @@ config IXGBE_DCB
 	  If unsure, say N.
 
 config IXGBEVF
-	tristate "Intel(R) 82599 Virtual Function Ethernet support"
+	tristate "Intel(R) 10GbE PCI Express Virtual Function Ethernet support"
 	depends on PCI_MSI
 	---help---
-	  This driver supports Intel(R) 82599 virtual functions.  For more
-	  information on how to identify your adapter, go to the Adapter &
-	  Driver ID Guide at:
+	  This driver supports Intel(R) PCI Express virtual functions for the
+	  Intel(R) ixgbe driver.  For more information on how to identify your
+	  adapter, go to the Adapter & Driver ID Guide at:
 
 	  <http://support.intel.com/support/network/sb/CS-008441.htm>
 
-- 
1.8.3.1
