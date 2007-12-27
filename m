From: Emil Medve <Emilian.Medve@freescale.com>
Subject: [PATCH] [NET] Fixed a small typo in the loopback driver
Date: Thu, 27 Dec 2007 08:17:22 -0600
Message-ID: <1198765042-30349-1-git-send-email-Emilian.Medve@Freescale.com>
Cc: Emil Medve <Emilian.Medve@freescale.com>
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36445 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbXL0TBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 14:01:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is probably a result of the changes from commit
854d836 - [NET]: Dynamically allocate the loopback device, part 2

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---

linux-2.6> scripts/checkpatch.pl 0001-NET-Fixed-a-small-typo-in-the-loopback-driver.patch 
total: 0 errors, 0 warnings, 8 lines checked

Your patch has no obvious style problems and is ready for submission.


 drivers/net/loopback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 662b8d1..fa147cd 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -242,7 +242,7 @@ static void loopback_setup(struct net_device *dev)
 		| NETIF_F_NO_CSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
-		| NETIF_F_NETNS_LOCAL,
+		| NETIF_F_NETNS_LOCAL;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->init = loopback_dev_init;
-- 
1.5.4-rc1.GIT
