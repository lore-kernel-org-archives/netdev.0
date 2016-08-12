From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 3/5] net_sched: fix a typo in tc_for_each_action()
Date: Thu, 11 Aug 2016 17:41:41 -0700
Message-ID: <1470962503-19682-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Amir Vadai <amir@vadai.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34946 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbcHLAnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 20:43:55 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so555969pfg.2
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 17:43:55 -0700 (PDT)
In-Reply-To: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is harmless because all users pass 'a' to this macro.

Fixes: 00175aec941e ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
Cc: Amir Vadai <amir@vadai.me>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 41e6a24..f53ee9d 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -193,7 +193,7 @@ int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
 	(list_empty(&(_exts)->actions))
 
 #define tc_for_each_action(_a, _exts) \
-	list_for_each_entry(a, &(_exts)->actions, list)
+	list_for_each_entry(_a, &(_exts)->actions, list)
 
 #define tc_single_action(_exts) \
 	(list_is_singular(&(_exts)->actions))
-- 
1.8.4.5
