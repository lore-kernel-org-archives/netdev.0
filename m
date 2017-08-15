From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH] net: Fix a typo in comment about sock flags.
Date: Tue, 15 Aug 2017 04:28:54 -0700
Message-ID: <1502796534-9101-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36149 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbdHOL3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 07:29:36 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so1110567pgy.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 04:29:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 include/linux/net.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index b5c15b3..d97d80d 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -37,7 +37,7 @@
 
 /* Historically, SOCKWQ_ASYNC_NOSPACE & SOCKWQ_ASYNC_WAITDATA were located
  * in sock->flags, but moved into sk->sk_wq->flags to be RCU protected.
- * Eventually all flags will be in sk->sk_wq_flags.
+ * Eventually all flags will be in sk->sk_wq->flags.
  */
 #define SOCKWQ_ASYNC_NOSPACE	0
 #define SOCKWQ_ASYNC_WAITDATA	1
-- 
1.8.3.1
