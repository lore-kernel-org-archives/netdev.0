From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 2/3] be2net: Fix a typo in be_cmds.h
Date: Mon, 5 Oct 2009 17:52:05 +0530
Message-ID: <20091005122154.GA22954@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:62196 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752702AbZJEMWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:22:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MCC_STATUS_NOT_SUPPORTED should be decimal 66 not hex 66.
This patch fixes this typo. Patch against net-2.6 tree.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 8b4c2cb..a86f917 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -62,7 +62,7 @@ enum {
 	MCC_STATUS_QUEUE_FLUSHING = 0x4,
 /* The command is completing with a DMA error */
 	MCC_STATUS_DMA_FAILED = 0x5,
-	MCC_STATUS_NOT_SUPPORTED = 0x66
+	MCC_STATUS_NOT_SUPPORTED = 66
 };
 
 #define CQE_STATUS_COMPL_MASK		0xFFFF
-- 
1.6.0.4

