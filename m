From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: remove duplicate shadowing reference to adapter->hw
Date: Wed, 08 Aug 2007 10:22:21 -0700
Message-ID: <20070808172221.12261.52785.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29120 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937462AbXHHRW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 13:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index dd4eca6..741965d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2981,7 +2981,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 		} else {
 			/* make sure the receive unit is started */
 			if (adapter->flags & FLAG_RX_NEEDS_RESTART) {
-				struct e1000_hw *hw = &adapter->hw;
 				u32 rctl = er32(RCTL);
 				ew32(RCTL, rctl |
 						E1000_RCTL_EN);
