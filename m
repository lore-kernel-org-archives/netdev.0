From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/24] e1000e: PCIe link speed in GT/s, not GB/s
Date: Wed, 13 Apr 2011 18:02:02 -0700
Message-ID: <1302742940-22141-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52716 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757978Ab1DNBCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:30 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Correct the log message when driver loads.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 909c8de..99c8c7c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5714,7 +5714,7 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	u8 pba_str[E1000_PBANUM_LENGTH];
 
 	/* print bus type/speed/width info */
-	e_info("(PCI Express:2.5GB/s:%s) %pM\n",
+	e_info("(PCI Express:2.5GT/s:%s) %pM\n",
 	       /* bus width */
 	       ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
 	        "Width x1"),
-- 
1.7.4.2

