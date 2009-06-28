From: Joe Perches <joe@perches.com>
Subject: [PATCH 32/62] drivers/net/skge.c: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:37 -0700
Message-ID: <27672422f37515d342756be31e7595bb0dd08d87.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1131 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbZF1Q1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:46 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 60d502e..0202471 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -215,7 +215,7 @@ static void skge_wol_init(struct skge_port *skge)
 	if (skge->wol & WAKE_MAGIC)
 		ctrl |= WOL_CTL_ENA_PME_ON_MAGIC_PKT|WOL_CTL_ENA_MAGIC_PKT_UNIT;
 	else
-		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;;
+		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;
 
 	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN|WOL_CTL_DIS_PATTERN_UNIT;
 	skge_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
-- 
1.6.3.1.10.g659a0.dirty

