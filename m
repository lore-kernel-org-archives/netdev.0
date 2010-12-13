From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v9 14/20] pch_can: Fix miss-setting status issue
Date: Mon, 13 Dec 2010 15:24:20 +0900
Message-ID: <1292221467-8039-14-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-5-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-6-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-7-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-8-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-9-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-10-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-11-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-12-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-13-git-send-email-tomoya-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: wg@grandegger.com, w.sang@pengutronix.de, chripell@fsfe.org,
	21cnbao@gmail.com, sameo@linux.intel.com,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kerne
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292221467-8039-13-git-send-email-tomoya-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify miss-setting status issue at suspend.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 5a6a0df..c500b6d 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1073,7 +1073,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	pch_can_set_run_mode(priv, PCH_CAN_STOP);
 
 	/* Indicate that we are aboutto/in suspend */
-	priv->can.state = CAN_STATE_SLEEPING;
+	priv->can.state = CAN_STATE_STOPPED;
 
 	/* Waiting for all transmission to complete. */
 	while (counter) {
-- 
1.6.0.6
