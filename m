From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 9/9] cxgb4: minor cleanup
Date: Fri, 18 Jun 2010 13:05:35 -0700
Message-ID: <1276891535-13967-10-git-send-email-dm@chelsio.com>
References: <1276891535-13967-1-git-send-email-dm@chelsio.com>
 <1276891535-13967-2-git-send-email-dm@chelsio.com>
 <1276891535-13967-3-git-send-email-dm@chelsio.com>
 <1276891535-13967-4-git-send-email-dm@chelsio.com>
 <1276891535-13967-5-git-send-email-dm@chelsio.com>
 <1276891535-13967-6-git-send-email-dm@chelsio.com>
 <1276891535-13967-7-git-send-email-dm@chelsio.com>
 <1276891535-13967-8-git-send-email-dm@chelsio.com>
 <1276891535-13967-9-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13949 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933439Ab0FRUMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 16:12:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5IKCJQU018644
	for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 13:12:21 -0700
In-Reply-To: <1276891535-13967-9-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove an unused flag and replace couple constants with enums.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 -
 drivers/net/cxgb4/cxgb4_main.c |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 5e37c1e..62804bb 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -309,7 +309,6 @@ enum {                                 /* adapter flags */
 	FULL_INIT_DONE     = (1 << 0),
 	USING_MSI          = (1 << 1),
 	USING_MSIX         = (1 << 2),
-	QUEUES_BOUND       = (1 << 3),
 	FW_OK              = (1 << 4),
 };
 
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 352c770..27f65b5 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2758,8 +2758,8 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	if (ret < 0)
 		return ret;
 
-	ret = t4_cfg_pfvf(adap, 0, 0, 0, 64, 64, 64, 0, 0, 4, 0xf, 0xf, 16,
-			  FW_CMD_CAP_PF, FW_CMD_CAP_PF);
+	ret = t4_cfg_pfvf(adap, 0, 0, 0, MAX_EGRQ, 64, MAX_INGQ, 0, 0, 4,
+			  0xf, 0xf, 16, FW_CMD_CAP_PF, FW_CMD_CAP_PF);
 	if (ret < 0)
 		return ret;
 
-- 
1.5.4

