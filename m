From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH net-next 3/3] ns83820: Use predefined autoneg constants
Date: Fri,  3 Sep 2010 20:05:41 +0000
Message-ID: <1283544341-18532-4-git-send-email-dkirjanov@hera.kernel.org>
References: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42792 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757438Ab0ICUFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 16:05:47 -0400
In-Reply-To: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ns83820.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 712422a..bfab215 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1298,7 +1298,8 @@ static int ns83820_get_settings(struct net_device *ndev,
 		cmd->speed = SPEED_10;
 		break;
 	}
-	cmd->autoneg = (tbicr & TBICR_MR_AN_ENABLE) ? 1: 0;
+	cmd->autoneg = (tbicr & TBICR_MR_AN_ENABLE)
+		? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	return 0;
 }
 
-- 
1.6.4.4

