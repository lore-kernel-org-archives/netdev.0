From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: b53: Remove unused including <linux/version.h>
Date: Thu, 15 Sep 2016 02:24:37 +0000
Message-ID: <1473906277-1828-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35244 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755693AbcIOCYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 22:24:44 -0400
Received: by mail-pa0-f65.google.com with SMTP id pp5so1473941pac.2
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 19:24:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/b53/b53_priv.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 76672da..f192a67 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -372,7 +372,6 @@ static inline void b53_arl_from_entry(u64 *mac_vid, u32 *fwd_entry,
 
 #ifdef CONFIG_BCM47XX
 
-#include <linux/version.h>
 #include <linux/bcm47xx_nvram.h>
 #include <bcm47xx_board.h>
 static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
