From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next] tc_act: Remove tcf_act macro
Date: Tue,  8 Nov 2016 17:24:03 +0200
Message-ID: <1478618643-37144-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: davem@davemloft.net, netdev@vger.kernel.org, mlxsw@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37449 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751786AbcKHPWJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 10:22:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tc_act macro addressed a non existing field, and was not used in the
kernel source.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 82f3c91..d8eae87 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -42,7 +42,6 @@ struct tc_action {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
 };
-#define tcf_act		common.tcfa_act
 #define tcf_head	common.tcfa_head
 #define tcf_index	common.tcfa_index
 #define tcf_refcnt	common.tcfa_refcnt
-- 
2.4.11
