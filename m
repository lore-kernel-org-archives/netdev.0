From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] e1000e: fix trivial kernel doc typos
Date: Tue, 12 Aug 2014 01:38:26 -0700
Message-ID: <1407832707-26034-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13399 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363AbaHLIig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 04:38:36 -0400
In-Reply-To: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The macro E1000_success is meant to be E1000_SUCCESS. As the return
statement in the function is good as is, let's simply correct the
comment for this trivial matter.

Additionally E1000_ERR_HOST_INTERFACE_COMMAND is supposed to be
-E1000_ERR_HOST_INTERFACE_COMMAND.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/manage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 5885603..e156664d 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -47,7 +47,7 @@ static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
  *  e1000_mng_enable_host_if - Checks host interface is enabled
  *  @hw: pointer to the HW structure
  *
- *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
+ *  Returns 0 upon success, else -E1000_ERR_HOST_INTERFACE_COMMAND
  *
  *  This function checks whether the HOST IF is enabled for command operation
  *  and also checks whether the previous command is completed.  It busy waits
-- 
1.9.3
