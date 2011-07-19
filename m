From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 02/10] bnx2x: add missing command in error handling flow
Date: Tue, 19 Jul 2011 14:38:53 +0300
Message-ID: <1311075533.30287.3.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1412 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab1GSLuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 150147a..5854a6c 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1828,6 +1828,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_func_start(bp);
 	if (rc) {
 		BNX2X_ERR("Function start failed!\n");
+		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
 		LOAD_ERROR_EXIT(bp, load_error3);
 	}
 
-- 
1.7.2.2




