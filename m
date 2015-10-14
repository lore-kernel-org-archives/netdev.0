From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/16] i40e/i40evf: Add new link status defines
Date: Tue, 13 Oct 2015 23:59:41 -0700
Message-ID: <1444805996-3877-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47517 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448AbbJNG76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 02:59:58 -0400
In-Reply-To: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new Port link status bit and rename the link status to function
link status.

Change-ID: I71289327ae62638ce967b6ad40114caf998b6dab
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 4 +++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 785b3db..02d5225 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1722,11 +1722,13 @@ struct i40e_aqc_get_link_status {
 	u8	phy_type;    /* i40e_aq_phy_type   */
 	u8	link_speed;  /* i40e_aq_link_speed */
 	u8	link_info;
-#define I40E_AQ_LINK_UP			0x01
+#define I40E_AQ_LINK_UP			0x01    /* obsolete */
+#define I40E_AQ_LINK_UP_FUNCTION	0x01
 #define I40E_AQ_LINK_FAULT		0x02
 #define I40E_AQ_LINK_FAULT_TX		0x04
 #define I40E_AQ_LINK_FAULT_RX		0x08
 #define I40E_AQ_LINK_FAULT_REMOTE	0x10
+#define I40E_AQ_LINK_UP_PORT		0x20
 #define I40E_AQ_MEDIA_AVAILABLE		0x40
 #define I40E_AQ_SIGNAL_DETECT		0x80
 	u8	an_info;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index c802209..fcb9ef3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1719,11 +1719,13 @@ struct i40e_aqc_get_link_status {
 	u8	phy_type;    /* i40e_aq_phy_type   */
 	u8	link_speed;  /* i40e_aq_link_speed */
 	u8	link_info;
-#define I40E_AQ_LINK_UP			0x01
+#define I40E_AQ_LINK_UP			0x01    /* obsolete */
+#define I40E_AQ_LINK_UP_FUNCTION	0x01
 #define I40E_AQ_LINK_FAULT		0x02
 #define I40E_AQ_LINK_FAULT_TX		0x04
 #define I40E_AQ_LINK_FAULT_RX		0x08
 #define I40E_AQ_LINK_FAULT_REMOTE	0x10
+#define I40E_AQ_LINK_UP_PORT		0x20
 #define I40E_AQ_MEDIA_AVAILABLE		0x40
 #define I40E_AQ_SIGNAL_DETECT		0x80
 	u8	an_info;
-- 
2.4.3
