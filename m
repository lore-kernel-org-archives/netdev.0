From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH] cxgb4: fix coccinelle warnings
Date: Tue, 10 Mar 2015 17:44:52 +0530
Message-ID: <1425989692-22391-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3533 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751343AbbCJMJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 08:09:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 16e47624e76b43db ("cxgb4: Add new scheme to update T4/T5 firmware")
introduced below coccinelle warning.

>> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:994:2-8: Replace memcpy with
   struct assignment

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 1498d07..afbe168 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1120,7 +1120,7 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 		}
 
 		/* Installed successfully, update the cached header too. */
-		memcpy(card_fw, fs_fw, sizeof(*card_fw));
+		*card_fw = *fs_fw;
 		card_fw_usable = 1;
 		*reset = 0;	/* already reset as part of load_fw */
 	}
-- 
1.7.1
