From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/5] bnx2x: Remove unneccessary EXPORT_SYMBOL
Date: Tue, 16 Feb 2016 18:07:57 +0200
Message-ID: <1455638881-2527-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39875 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbcBPQIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:08:43 -0500
In-Reply-To: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_schedule_sp_rtnl is exported by bnx2x, although no other module
uses it.

Reported-by: Benjamin Poirier <bpoirier@suse.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9695a4c..9e42bca 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -5086,4 +5086,3 @@ void bnx2x_schedule_sp_rtnl(struct bnx2x *bp, enum sp_rtnl_flag flag,
 	   flag);
 	schedule_delayed_work(&bp->sp_rtnl_task, 0);
 }
-EXPORT_SYMBOL(bnx2x_schedule_sp_rtnl);
-- 
1.9.3
