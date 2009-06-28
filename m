From: Joe Perches <joe@perches.com>
Subject: [PATCH 33/62] drivers/net/sky2.c: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:38 -0700
Message-ID: <932cc95f8a6d7d97a91d7a6bbaa026439d7c47b6.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1133 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756759AbZF1Q1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:47 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7681d28..c4281b5 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -749,7 +749,7 @@ static void sky2_wol_init(struct sky2_port *sky2)
 	if (sky2->wol & WAKE_MAGIC)
 		ctrl |= WOL_CTL_ENA_PME_ON_MAGIC_PKT|WOL_CTL_ENA_MAGIC_PKT_UNIT;
 	else
-		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;;
+		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;
 
 	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN|WOL_CTL_DIS_PATTERN_UNIT;
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
-- 
1.6.3.1.10.g659a0.dirty

