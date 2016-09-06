From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] vmxnet3: mark vmxnet3_rq_destroy_all_rxdataring() static
Date: Tue,  6 Sep 2016 16:11:59 +0800
Message-ID: <1473149519-25993-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: skhare@vmware.com, pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35471 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932810AbcIFIMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 04:12:16 -0400
Received: by mail-pa0-f42.google.com with SMTP id b2so84350pat.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 01:12:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 1 warning when building kernel with W=1:
drivers/net/vmxnet3/vmxnet3_drv.c:1643:1: warning: no previous prototype for 'vmxnet3_rq_destroy_all_rxdataring' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index c68fe49..fc68dd4 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1639,7 +1639,7 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 	}
 }
 
-void
+static void
 vmxnet3_rq_destroy_all_rxdataring(struct vmxnet3_adapter *adapter)
 {
 	int i;
-- 
2.7.4
