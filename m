From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 13/19 v5] can: EG20T PCH: Fix miss-setting status
 issue
Date: Fri, 26 Nov 2010 11:20:52 +0900
Message-ID: <4CEF1984.4070908__20819.7172651582$1290738108$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:47053 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753499Ab0KZCVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 21:21:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix miss-setting status issue
 Modify miss-setting status issue at suspend.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index b1fde7d..ff57a67 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1078,7 +1078,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	pch_can_set_run_mode(priv, PCH_CAN_STOP);
 
 	/* Indicate that we are aboutto/in suspend */
-	priv->can.state = CAN_STATE_SLEEPING;
+	priv->can.state = CAN_STATE_STOPPED;
 
 	/* Waiting for all transmission to complete. */
 	while (counter) {
-- 
1.6.0.6
