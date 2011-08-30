From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 2/8] bnx2x: decrease print level to debug
Date: Tue, 30 Aug 2011 13:08:40 +0300
Message-ID: <1314698926-24525-3-git-send-email-dmitry@broadcom.com>
References: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4435 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab1H3KIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 06:08:46 -0400
In-Reply-To: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may happen every link toggle.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 771f680..f5d9b42 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -710,7 +710,8 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 		break;
 
 	case MAC_TYPE_NONE: /* unreached */
-		BNX2X_ERR("stats updated by DMAE but no MAC active\n");
+		DP(BNX2X_MSG_STATS,
+		   "stats updated by DMAE but no MAC active\n");
 		return -1;
 
 	default: /* unreached */
-- 
1.7.2.2
