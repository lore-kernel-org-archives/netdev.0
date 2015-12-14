From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v4 5/5] i40e: Call geneve_get_rx_port to get the existing Geneve ports
Date: Mon, 14 Dec 2015 11:58:00 -0800
Message-ID: <1450123080-206406-6-git-send-email-anjali.singhai@intel.com>
References: <1450123080-206406-1-git-send-email-anjali.singhai@intel.com>
Cc: jeffrey.t.kirsher@intel.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17819 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031AbbLNTlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 14:41:19 -0500
In-Reply-To: <1450123080-206406-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a call to geneve_get_rx_port in i40e so that when it
comes up it can learn about the existing geneve tunnels.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 81a6693..11059be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5339,6 +5339,9 @@ int i40e_open(struct net_device *netdev)
 #ifdef CONFIG_I40E_VXLAN
 	vxlan_get_rx_port(netdev);
 #endif
+#ifdef CONFIG_I40E_GENEVE
+	geneve_get_rx_port(netdev);
+#endif
 
 	return 0;
 }
-- 
1.8.1.4
