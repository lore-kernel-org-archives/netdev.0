From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 3/9] net: sh-eth: Set EDSR_ENALL instead of 0x03 is set to EDSR
Date: Tue,  7 May 2013 14:17:49 +0900
Message-ID: <1367903875-32606-3-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47986 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757213Ab3EGFSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:16 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so221224pad.36
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:15 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  no changes.
V2:
  no changes.
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 489be0e..334fa13 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -523,7 +523,7 @@ static int sh_eth_reset(struct net_device *ndev)
 	int ret = 0;
 
 	if (sh_eth_is_gether(mdp)) {
-		sh_eth_write(ndev, 0x03, EDSR);
+		sh_eth_write(ndev, EDSR_ENALL, EDSR);
 		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
 				EDMR);
 
-- 
1.7.10.4
