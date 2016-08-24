From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH v2] vmxnet3: fix non static symbol warning
Date: Wed, 24 Aug 2016 15:07:26 +0000
Message-ID: <1472051246-15097-1-git-send-email-weiyj.lk@gmail.com>
References: <1471964718-32543-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33924 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbcHXPHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:07:54 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so1355480pac.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 08:07:53 -0700 (PDT)
In-Reply-To: <1471964718-32543-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/vmxnet3/vmxnet3_drv.c:1645:1: warning:
 symbol 'vmxnet3_rq_destroy_all_rxdataring' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
v1 -> v2: rebase on netdev tree
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 4244b9d..2fd93b4 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1641,7 +1641,7 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 	}
 }
 
-void
+static void
 vmxnet3_rq_destroy_all_rxdataring(struct vmxnet3_adapter *adapter)
 {
 	int i;
