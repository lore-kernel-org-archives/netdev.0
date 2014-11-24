From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] tc_vlan: fix type of tcfv_push_vid
Date: Mon, 24 Nov 2014 11:30:26 +0100
Message-ID: <1416825026-4628-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:45260 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbaKXKad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 05:30:33 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so5215935wiw.9
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 02:30:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should be u16. So fix it to kill the sparse warning.

Fixes: c7e2b9689ef8136 "sched: introduce vlan action"
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/tc_act/tc_vlan.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index c809c1d..93b70ad 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -18,7 +18,7 @@
 struct tcf_vlan {
 	struct tcf_common	common;
 	int			tcfv_action;
-	__be16			tcfv_push_vid;
+	u16			tcfv_push_vid;
 	__be16			tcfv_push_proto;
 };
 #define to_vlan(a) \
-- 
1.9.3
