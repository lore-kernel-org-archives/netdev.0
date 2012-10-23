From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] ixgbe: using is_zero_ether_addr() to simplify the code
Date: Mon, 22 Oct 2012 21:26:21 -0700
Message-ID: <1350966385-19020-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33410 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157Ab2JWE0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 00:26:31 -0400
In-Reply-To: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index dbf37e4..a2a9bcc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1778,8 +1778,7 @@ s32 ixgbe_validate_mac_addr(u8 *mac_addr)
 	else if (IXGBE_IS_BROADCAST(mac_addr))
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 	/* Reject the zero address */
-	else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
-	         mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
+	else if (is_zero_ether_addr(mac_addr))
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 
 	return status;
-- 
1.7.11.7
