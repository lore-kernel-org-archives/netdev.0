From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 01/15] i40e: spelling error
Date: Thu, 13 Feb 2014 03:48:39 -0800
Message-ID: <1392292133-32120-2-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56830 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754212AbaBMLvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:12 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Fix a spelling error, s/extention/extension/.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d4bb482..19af4ce 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -892,7 +892,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	      rx_status & (1 << I40E_RX_DESC_STATUS_L3L4P_SHIFT)))
 		return;
 
-	/* likely incorrect csum if alternate IP extention headers found */
+	/* likely incorrect csum if alternate IP extension headers found */
 	if (rx_status & (1 << I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT))
 		return;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index ffdb01d..3bb7558 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -722,7 +722,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	      rx_status & (1 << I40E_RX_DESC_STATUS_L3L4P_SHIFT)))
 		return;
 
-	/* likely incorrect csum if alternate IP extention headers found */
+	/* likely incorrect csum if alternate IP extension headers found */
 	if (rx_status & (1 << I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT))
 		return;
 
-- 
1.8.5.GIT
