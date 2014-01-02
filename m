From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbe: Add Live Error Recovery configuration option
Date: Thu,  2 Jan 2014 01:33:38 -0800
Message-ID: <1388655221-25428-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49554 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbaABJdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 04:33:49 -0500
In-Reply-To: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

CONFIG_IXGBE_LER is added to control LER, Live Error Recovery
support to save a little CPU utilization in environments that
don't support LER. Thunderbolt environments also benefit from
having this enabled.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 94adb89..f1646e4 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -192,6 +192,17 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_LER
+	bool "Intel(R) 10GbE PCI Express LER support"
+	default y
+	depends on IXGBE
+	---help---
+	  Say N to disable Live Error Recovery (LER) checks to save a
+	  little CPU utilization. Thunderbolt environments also benefit
+	  from having this enabled. Non-LER environments only suffer a
+	  little increased CPU utilization by leaving this enabled. If
+	  in doubt, say Y.
+
 config IXGBE_HWMON
 	bool "Intel(R) 10GbE PCI Express adapters HWMON support"
 	default y
-- 
1.8.3.1
