From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] net: sched: introduce helper to identify gact pass action
Date: Mon, 25 Sep 2017 10:58:21 +0200
Message-ID: <20170925085822.1358-3-jiri@resnulli.us>
References: <20170925085822.1358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33064 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932437AbdIYI60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:58:26 -0400
Received: by mail-wm0-f68.google.com with SMTP id m127so6566610wmm.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:58:25 -0700 (PDT)
In-Reply-To: <20170925085822.1358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce a helper called is_tcf_gact_pass which could be used to
tell if the action is gact pass or not.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/tc_act/tc_gact.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 41afe1c..d979a0d 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -33,6 +33,11 @@ static inline bool __is_tcf_gact_act(const struct tc_action *a, int act,
 	return false;
 }
 
+static inline bool is_tcf_gact_ok(const struct tc_action *a)
+{
+	return __is_tcf_gact_act(a, TC_ACT_OK, false);
+}
+
 static inline bool is_tcf_gact_shot(const struct tc_action *a)
 {
 	return __is_tcf_gact_act(a, TC_ACT_SHOT, false);
-- 
2.9.5
