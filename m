From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH v2 2/3] net: bnx2x: Staticize local symbols
Date: Wed, 18 Sep 2013 09:00:00 +0530
Message-ID: <1379475001-24505-2-git-send-email-sachin.kamat@linaro.org>
References: <1379475001-24505-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:56474 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab3IRDs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 23:48:26 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so6437976pbb.41
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 20:48:26 -0700 (PDT)
In-Reply-To: <1379475001-24505-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Local symbols used only in this file are made static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Ariel Elior <ariele@broadcom.com>
---
Changes since v1:
Changed the coding style as suggested by Ariel Elior.
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2604b62..7991f10 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2802,7 +2802,7 @@ struct set_vf_state_cookie {
 	u8 state;
 };
 
-void bnx2x_set_vf_state(void *cookie)
+static void bnx2x_set_vf_state(void *cookie)
 {
 	struct set_vf_state_cookie *p = (struct set_vf_state_cookie *)cookie;
 
@@ -3222,8 +3222,9 @@ void bnx2x_disable_sriov(struct bnx2x *bp)
 	pci_disable_sriov(bp->pdev);
 }
 
-int bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx, struct bnx2x_virtf **vf,
-			struct pf_vf_bulletin_content **bulletin)
+static int bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx,
+			     struct bnx2x_virtf **vf,
+			     struct pf_vf_bulletin_content **bulletin)
 {
 	if (bp->state != BNX2X_STATE_OPEN) {
 		BNX2X_ERR("vf ndo called though PF is down\n");
-- 
1.7.9.5
