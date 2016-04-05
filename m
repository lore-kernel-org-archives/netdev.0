From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next] cxgb4/cxgb4vf:  Deprecate module parameter dflt_msg_enable
Date: Tue,  5 Apr 2016 09:52:21 +0530
Message-ID: <1459830141-27224-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:51657 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750719AbcDEESq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:18:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Message level can be set through ethtool, so deprecate module parameter
which is used to set the same.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---

V2: Fix grammar in module param description, based on review comment by
    Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 3 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d1e3f0997d6b..a1e329ec24cd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -168,7 +168,8 @@ MODULE_PARM_DESC(force_init, "Forcibly become Master PF and initialize adapter,"
 static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
 module_param(dflt_msg_enable, int, 0644);
-MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T4 default message enable bitmap");
+MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T4 default message enable bitmap, "
+		 "deprecated parameter");
 
 /*
  * The driver uses the best interrupt scheme available on a platform in the
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 1cc8a7a69457..730fec73d5a6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -74,7 +74,8 @@ static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
 module_param(dflt_msg_enable, int, 0644);
 MODULE_PARM_DESC(dflt_msg_enable,
-		 "default adapter ethtool message level bitmap");
+		 "default adapter ethtool message level bitmap, "
+		 "deprecated parameter");
 
 /*
  * The driver uses the best interrupt scheme available on a platform in the
-- 
2.3.4
