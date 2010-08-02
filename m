From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 7/9] cxgb4: fix wrong shift direction
Date: Mon,  2 Aug 2010 16:19:22 -0700
Message-ID: <1280791164-14181-8-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
 <1280791164-14181-4-git-send-email-dm@chelsio.com>
 <1280791164-14181-5-git-send-email-dm@chelsio.com>
 <1280791164-14181-6-git-send-email-dm@chelsio.com>
 <1280791164-14181-7-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26055 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597Ab0HBXT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:26 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJPVC025641
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:25 -0700
In-Reply-To: <1280791164-14181-7-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/cxgb4/t4_hw.h
index e875d09..10a0555 100644
--- a/drivers/net/cxgb4/t4_hw.h
+++ b/drivers/net/cxgb4/t4_hw.h
@@ -135,5 +135,5 @@ struct rsp_ctrl {
 
 #define QINTR_CNT_EN       0x1
 #define QINTR_TIMER_IDX(x) ((x) << 1)
-#define QINTR_TIMER_IDX_GET(x) (((x) << 1) & 0x7)
+#define QINTR_TIMER_IDX_GET(x) (((x) >> 1) & 0x7)
 #endif /* __T4_HW_H */
-- 
1.5.4

