From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] myri10ge: fix typo in parameter description
Date: Thu, 20 Oct 2016 17:01:56 +0000
Message-ID: <1476982916-28139-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Hyong-Youb Kim <hykim@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32839 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbcJTRCE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 13:02:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so6082391pfa.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:02:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix typo in parameter description.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 5ae3f17..e506ca8 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -289,7 +289,7 @@ static char *myri10ge_fw_names[MYRI10GE_MAX_BOARDS] =
     {[0 ... (MYRI10GE_MAX_BOARDS - 1)] = NULL };
 module_param_array_named(myri10ge_fw_names, myri10ge_fw_names, charp, NULL,
 			 0444);
-MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image names per board");
+MODULE_PARM_DESC(myri10ge_fw_names, "Firmware image names per board");
 
 static int myri10ge_ecrc_enable = 1;
 module_param(myri10ge_ecrc_enable, int, S_IRUGO);
