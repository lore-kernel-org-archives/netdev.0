From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qla3xxx: remove unused variable in ql_process_mac_tx_intr()
Date: Fri, 26 Oct 2012 23:30:31 +0800
Message-ID: <CAPgLHd-rHiLuMR45R7uDWx=BVNr01XpcG6XG0_uMwjbhUGyKEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:55416 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964782Ab2JZPad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 11:30:33 -0400
Received: by mail-qa0-f46.google.com with SMTP id c26so317008qad.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 08:30:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The variable retval is initialized but never used
otherwise, so remove the unused variable.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qla3xxx.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 6407d0d..dd4d864a 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -1920,7 +1920,6 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 {
 	struct ql_tx_buf_cb *tx_cb;
 	int i;
-	int retval = 0;
 
 	if (mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
 		netdev_warn(qdev->ndev,
@@ -1935,7 +1934,6 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 			   "Frame too short to be legal, frame not sent\n");
 
 		qdev->ndev->stats.tx_errors++;
-		retval = -EIO;
 		goto frame_not_sent;
 	}
 
@@ -1944,7 +1942,6 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 			   mac_rsp->transaction_id);
 
 		qdev->ndev->stats.tx_errors++;
-		retval = -EIO;
 		goto invalid_seg_count;
 	}
 
