From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: qca8k: fix non static symbol warning
Date: Wed, 21 Sep 2016 15:04:43 +0000
Message-ID: <1474470283-31534-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35756 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934935AbcIUPEw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:04:52 -0400
Received: by mail-pa0-f67.google.com with SMTP id hi10so2399005pac.2
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:04:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/dsa/qca8k.c:259:22: warning:
 symbol 'qca8k_regmap_config' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/qca8k.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 7f3f178..280acb0 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -256,7 +256,7 @@ static struct regmap_access_table qca8k_readable_table = {
 	.n_yes_ranges = ARRAY_SIZE(qca8k_readable_ranges),
 };
 
-struct regmap_config qca8k_regmap_config = {
+static struct regmap_config qca8k_regmap_config = {
 	.reg_bits = 16,
 	.val_bits = 32,
 	.reg_stride = 4,
