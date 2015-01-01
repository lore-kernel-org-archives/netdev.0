From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] igb: Remove unneeded FIXME
Date: Wed, 31 Dec 2014 16:04:14 -0800
Message-ID: <1420070655-28453-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbbAAAET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 19:04:19 -0500
In-Reply-To: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Remove a FIXME comment that was missed in a commit on 1/2007.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Reported-by: nick <xerofoify@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 051ea94..0f69ef8 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1125,7 +1125,7 @@ static s32 igb_acquire_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 	u32 swmask = mask;
 	u32 fwmask = mask << 16;
 	s32 ret_val = 0;
-	s32 i = 0, timeout = 200; /* FIXME: find real value to use here */
+	s32 i = 0, timeout = 200;
 
 	while (i < timeout) {
 		if (igb_get_hw_semaphore(hw)) {
-- 
1.9.3
