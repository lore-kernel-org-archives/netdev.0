From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/6] cxgb4: Avoid dumping Write-only registers in register dump
Date: Tue, 12 Aug 2014 11:09:12 +0530
Message-ID: <1407821953-8711-6-git-send-email-hariprasad@chelsio.com>
References: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43203
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752423AbaHLFdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 01:33:44 -0400
In-Reply-To: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f1ff11b..684ada0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1763,7 +1763,8 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0xd004, 0xd03c,
 		0xdfc0, 0xdfe0,
 		0xe000, 0xea7c,
-		0xf000, 0x11190,
+		0xf000, 0x11110,
+		0x11118, 0x11190,
 		0x19040, 0x1906c,
 		0x19078, 0x19080,
 		0x1908c, 0x19124,
@@ -1970,7 +1971,8 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0xd004, 0xd03c,
 		0xdfc0, 0xdfe0,
 		0xe000, 0x11088,
-		0x1109c, 0x1117c,
+		0x1109c, 0x11110,
+		0x11118, 0x1117c,
 		0x11190, 0x11204,
 		0x19040, 0x1906c,
 		0x19078, 0x19080,
-- 
1.7.1
