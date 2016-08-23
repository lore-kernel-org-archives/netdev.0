From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] cxgb4: Remove unused including <linux/version.h>
Date: Tue, 23 Aug 2016 15:09:49 +0000
Message-ID: <1471964989-912-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34962 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751055AbcHWPKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:10:31 -0400
Received: by mail-pf0-f194.google.com with SMTP id h186so8425925pfg.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:10:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index aac6e44..5d402ba 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -36,7 +36,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
