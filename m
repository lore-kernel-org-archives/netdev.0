From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 2/8] net: sh-eth: Set EDSR_ENALL instead of 0x03 is set to EDSR
Date: Thu, 18 Apr 2013 16:01:44 +0900
Message-ID: <1366268510-8121-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42191 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965991Ab3DRHCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 03:02:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id kx1so1391217pab.0
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 00:02:03 -0700 (PDT)
In-Reply-To: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d9458ae..313d6ef 100644
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
