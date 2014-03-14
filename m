From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] igb: Fix code comment
Date: Fri, 14 Mar 2014 02:47:13 -0700
Message-ID: <1394790446-31591-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43772 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543AbaCNJr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:47:29 -0400
In-Reply-To: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently added code comment was missing a space that is needed.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 340a344..ea8b9c4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1978,7 +1978,7 @@ void igb_reset(struct igb_adapter *adapter)
 		}
 	}
 #endif
-	/*Re-establish EEE setting */
+	/* Re-establish EEE setting */
 	if (hw->phy.media_type == e1000_media_type_copper) {
 		switch (mac->type) {
 		case e1000_i350:
-- 
1.8.3.1
