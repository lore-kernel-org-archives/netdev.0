From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH net-next 1/3] ns83820: Remove unused have_optical variable.
Date: Fri,  3 Sep 2010 20:05:39 +0000
Message-ID: <1283544341-18532-2-git-send-email-dkirjanov@hera.kernel.org>
References: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42786 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757342Ab0ICUFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 16:05:46 -0400
In-Reply-To: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ns83820.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 447c2c4..3347125 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1246,7 +1246,6 @@ static int ns83820_get_settings(struct net_device *ndev,
 {
 	struct ns83820 *dev = PRIV(ndev);
 	u32 cfg, tanar, tbicr;
-	int have_optical = 0;
 	int fullduplex   = 0;
 
 	/*
@@ -1267,15 +1266,7 @@ static int ns83820_get_settings(struct net_device *ndev,
 	tanar = readl(dev->base + TANAR);
 	tbicr = readl(dev->base + TBICR);
 
-	if (dev->CFG_cache & CFG_TBI_EN) {
-		/* we have an optical interface */
-		have_optical = 1;
-		fullduplex = (cfg & CFG_DUPSTS) ? 1 : 0;
-
-	} else {
-		/* We have copper */
-		fullduplex = (cfg & CFG_DUPSTS) ? 1 : 0;
-        }
+	fullduplex = (cfg & CFG_DUPSTS) ? 1 : 0;
 
 	cmd->supported = SUPPORTED_Autoneg;
 
-- 
1.6.4.4

