From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 6/6] mISDN: remove unused function
Date: Sat, 24 Sep 2016 13:28:02 +0800
Message-ID: <1474694882-25427-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34506 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbcIXF2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 01:28:14 -0400
Received: by mail-pf0-f180.google.com with SMTP id l25so213398pfb.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 22:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 1 warning when building kernel with W=1:
drivers/isdn/mISDN/layer2.c:463:1: warning: no previous declaration for 'IsRR' [-Wmissing-declarations]

In fact, this function is called by no one and not exported,
so this patch removes it.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/mISDN/layer2.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index f6ab6027..2519510 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -459,15 +459,6 @@ IsDISC(u_char *data)
 	return (data[0] & 0xef) == DISC;
 }
 
-inline int
-IsRR(u_char *data, struct layer2 *l2)
-{
-	if (test_bit(FLG_MOD128, &l2->flag))
-		return data[0] == RR;
-	else
-		return (data[0] & 0xf) == 1;
-}
-
 static inline int
 IsSFrame(u_char *data, struct layer2 *l2)
 {
-- 
2.7.4
