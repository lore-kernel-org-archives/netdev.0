From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/8] cxgb4: Remove unused registers and add missing ones
Date: Tue, 18 Feb 2014 17:56:13 +0530
Message-ID: <1392726375-32001-7-git-send-email-hariprasad@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754917AbaBRNgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:06 -0500
In-Reply-To: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Remove unused registers for registers list, and add missing ones
Based on original work by Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0e3e98e..654ff3a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2064,7 +2064,7 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0x40200, 0x40298,
 		0x402ac, 0x4033c,
 		0x403f8, 0x403fc,
-		0x41300, 0x413c4,
+		0x41304, 0x413c4,
 		0x41400, 0x4141c,
 		0x41480, 0x414d0,
 		0x44000, 0x44078,
@@ -2092,7 +2092,7 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0x48200, 0x48298,
 		0x482ac, 0x4833c,
 		0x483f8, 0x483fc,
-		0x49300, 0x493c4,
+		0x49304, 0x493c4,
 		0x49400, 0x4941c,
 		0x49480, 0x494d0,
 		0x4c000, 0x4c078,
-- 
1.8.0
