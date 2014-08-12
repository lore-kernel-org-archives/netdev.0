From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] e1000e: delete excessive space character in debug message
Date: Tue, 12 Aug 2014 01:38:27 -0700
Message-ID: <1407832707-26034-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13399 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbaHLIih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 04:38:37 -0400
In-Reply-To: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

There is an excessive space character between the word and the
period in the debug message. So delete it.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/manage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index e156664d..06edfca 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -78,7 +78,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 	}
 
 	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
-		e_dbg("Previous command timeout failed .\n");
+		e_dbg("Previous command timeout failed.\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 
-- 
1.9.3
