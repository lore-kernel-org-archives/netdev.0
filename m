From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 2/6] bnx2x: remove redundant commands during
 error handling
Date: Mon, 18 Oct 2010 11:05:09 +0200
Message-ID: <1287392709.11597.28.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1312 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761Ab0JRJMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 05:12:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index ddf90e1..3f0540c 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1288,8 +1288,6 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
 		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP, 0);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 		goto load_error2;
 	}
 
-- 
1.7.1




