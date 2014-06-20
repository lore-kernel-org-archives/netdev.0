From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: debugfs fix to dump remote LLDPDU
Date: Fri, 20 Jun 2014 00:49:41 -0700
Message-ID: <1403250588-14356-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62071 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbaFTHt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:56 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Fix the debugfs command "lldp get remote" that dumped the local
LLDPDU instead of peer's LLDPDU.

Change-ID: I0702eacdafd54478c18f20cab3a7fa5dc1b3182d
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index cffdfc2..910b01b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1830,7 +1830,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 			ret = i40e_aq_get_lldp_mib(&pf->hw,
 					I40E_AQ_LLDP_BRIDGE_TYPE_NEAREST_BRIDGE,
-					I40E_AQ_LLDP_MIB_LOCAL,
+					I40E_AQ_LLDP_MIB_REMOTE,
 					buff, I40E_LLDPDU_SIZE,
 					&llen, &rlen, NULL);
 			if (ret) {
-- 
1.9.3
