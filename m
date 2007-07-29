From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.23 1/2] Make the iw_cxgb3 module parameters writable.
Date: Sun, 29 Jul 2007 15:12:26 -0500
Message-ID: <20070729201226.31659.85900.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:46274 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762261AbXG2UM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 16:12:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make the iw_cxgb3 module parameters writable.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 9574088..fa95dce 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -63,37 +63,37 @@ static char *states[] = {
 };
 
 static int ep_timeout_secs = 10;
-module_param(ep_timeout_secs, int, 0444);
+module_param(ep_timeout_secs, int, 0644);
 MODULE_PARM_DESC(ep_timeout_secs, "CM Endpoint operation timeout "
 				   "in seconds (default=10)");
 
 static int mpa_rev = 1;
-module_param(mpa_rev, int, 0444);
+module_param(mpa_rev, int, 0644);
 MODULE_PARM_DESC(mpa_rev, "MPA Revision, 0 supports amso1100, "
 		 "1 is spec compliant. (default=1)");
 
 static int markers_enabled = 0;
-module_param(markers_enabled, int, 0444);
+module_param(markers_enabled, int, 0644);
 MODULE_PARM_DESC(markers_enabled, "Enable MPA MARKERS (default(0)=disabled)");
 
 static int crc_enabled = 1;
-module_param(crc_enabled, int, 0444);
+module_param(crc_enabled, int, 0644);
 MODULE_PARM_DESC(crc_enabled, "Enable MPA CRC (default(1)=enabled)");
 
 static int rcv_win = 256 * 1024;
-module_param(rcv_win, int, 0444);
+module_param(rcv_win, int, 0644);
 MODULE_PARM_DESC(rcv_win, "TCP receive window in bytes (default=256)");
 
 static int snd_win = 32 * 1024;
-module_param(snd_win, int, 0444);
+module_param(snd_win, int, 0644);
 MODULE_PARM_DESC(snd_win, "TCP send window in bytes (default=32KB)");
 
 static unsigned int nocong = 0;
-module_param(nocong, uint, 0444);
+module_param(nocong, uint, 0644);
 MODULE_PARM_DESC(nocong, "Turn off congestion control (default=0)");
 
 static unsigned int cong_flavor = 1;
-module_param(cong_flavor, uint, 0444);
+module_param(cong_flavor, uint, 0644);
 MODULE_PARM_DESC(cong_flavor, "TCP Congestion control flavor (default=1)");
 
 static void process_work(struct work_struct *work);
