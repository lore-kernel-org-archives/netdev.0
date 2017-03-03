From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] strparser: destroy workqueue on module exit
Date: Fri,  3 Mar 2017 12:21:14 -0800
Message-ID: <1488572474-11779-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34915 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbdCCUvt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 15:51:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id 1so13685651pgz.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 12:51:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 43a0c6751a32 ("strparser: Stream parser for messages")
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/strparser/strparser.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index 41adf36..b5c279b 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -504,6 +504,7 @@ static int __init strp_mod_init(void)
 
 static void __exit strp_mod_exit(void)
 {
+	destroy_workqueue(strp_wq);
 }
 module_init(strp_mod_init);
 module_exit(strp_mod_exit);
-- 
2.5.5
