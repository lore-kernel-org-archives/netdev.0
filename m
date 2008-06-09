From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/4] tg3: Fix a flags typo
Date: Mon, 9 Jun 2008 11:25:55 -0700
Message-ID: <1213046683.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2226 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbYFIVUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 17:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem where the TG3_FLAG_10_100_ONLY flag was
testing against the wrong flags variable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4c248d7..c129318 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8598,7 +8598,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		   (cmd->speed == SPEED_1000))
 		return -EINVAL;
 	else if ((cmd->speed == SPEED_1000) &&
-		 (tp->tg3_flags2 & TG3_FLAG_10_100_ONLY))
+		 (tp->tg3_flags & TG3_FLAG_10_100_ONLY))
 		return -EINVAL;
 
 	tg3_full_lock(tp, 0);
-- 
1.5.2.5



