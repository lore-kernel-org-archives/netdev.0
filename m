From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] ixgbe: fix compile failure in ixgbe_init_mbx_params_pf
Date: Tue,  8 Mar 2011 17:24:07 -0500
Message-ID: <1299623047-25656-1-git-send-email-andy@greyhouse.net>
To: netdev@vger.kernel.org, davem@davemeloft.net,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab1CHWXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 17:23:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit:

    commit d7c8a29fc8bd20ba45ec2f52577ed04a988a9500
    Author: Emil Tantilov <emil.s.tantilov@intel.com>
    Date:   Thu Mar 3 09:25:02 2011 +0000

        ixgbe: improve logic in ixgbe_init_mbx_params_pf

incorrectly added a line that accessed mbx->udelay.  I'm sure the intent
was mbx->usec_delay.  This patch fixes the compilation error.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/ixgbe/ixgbe_mbx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index 3cf8aec..c7ed82e 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -453,7 +453,7 @@ void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
 		return;
 
 	mbx->timeout = 0;
-	mbx->udelay = 0;
+	mbx->usec_delay = 0;
 
 	mbx->stats.msgs_tx = 0;
 	mbx->stats.msgs_rx = 0;
