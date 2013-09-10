From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: bnx2x: Staticize local symbols
Date: Tue, 10 Sep 2013 13:12:40 +0530
Message-ID: <1378798960-6572-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, eilong@broadcom.com, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:55756 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab3IJIAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 04:00:45 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so7273277pbb.10
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 01:00:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Local symbols used only in this file are made static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2604b62..5ec30cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2802,7 +2802,7 @@ struct set_vf_state_cookie {
 	u8 state;
 };
 
-void bnx2x_set_vf_state(void *cookie)
+static void bnx2x_set_vf_state(void *cookie)
 {
 	struct set_vf_state_cookie *p = (struct set_vf_state_cookie *)cookie;
 
@@ -3222,7 +3222,8 @@ void bnx2x_disable_sriov(struct bnx2x *bp)
 	pci_disable_sriov(bp->pdev);
 }
 
-int bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx, struct bnx2x_virtf **vf,
+static int
+bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx, struct bnx2x_virtf **vf,
 			struct pf_vf_bulletin_content **bulletin)
 {
 	if (bp->state != BNX2X_STATE_OPEN) {
-- 
1.7.9.5
