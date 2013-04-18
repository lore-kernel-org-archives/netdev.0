From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 7/8] net: sh-eth: Remove ifdef for sh_eth_select_mii
Date: Thu, 18 Apr 2013 16:01:49 +0900
Message-ID: <1366268510-8121-7-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:33865 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab3DRHCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 03:02:19 -0400
Received: by mail-da0-f50.google.com with SMTP id g9so206727dad.37
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 00:02:19 -0700 (PDT)
In-Reply-To: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a4e337f..eb428d4 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -313,9 +313,6 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TSU_ADRL31]	= 0x01fc,
 };
 
-#if defined(CONFIG_CPU_SUBTYPE_SH7734) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_ARCH_R8A7740)
 static void sh_eth_select_mii(struct net_device *ndev)
 {
 	u32 value = 0x0;
@@ -339,7 +336,6 @@ static void sh_eth_select_mii(struct net_device *ndev)
 
 	sh_eth_write(ndev, value, RMII_MII);
 }
-#endif
 
 #if defined(CONFIG_CPU_SUBTYPE_SH7619) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7710) || \
-- 
1.7.10.4
