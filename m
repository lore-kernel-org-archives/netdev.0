From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 13/17 v2] can: EG20T PCH: Fix miss-setting status
 issue
Date: Wed, 24 Nov 2010 16:38:27 +0900
Message-ID: <4CECC0F3.3090409__42129.6179215007$1290584453$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11917 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752241Ab0KXHix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:38:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify miss-setting status issue at suspend.


Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 466f011..610cf3b 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1084,7 +1084,7 @@ static int pch_can_suspend(struct pci_dev *pdev,
pm_message_t state)
 	pch_can_set_run_mode(priv, PCH_CAN_STOP);
  	/* Indicate that we are aboutto/in suspend */
-	priv->can.state = CAN_STATE_SLEEPING;
+	priv->can.state = CAN_STATE_STOPPED;
  	/* Waiting for all transmission to complete. */
 	while (counter) {
-- 
1.6.0.6

