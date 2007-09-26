From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH] mv643xx_eth: duplicate methods in initializer
Date: Wed, 26 Sep 2007 01:53:52 +0100
Message-ID: <E1IaLA0-00084w-8g@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46699 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbXIZAyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 20:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/mv643xx_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 6a117e9..456d1e1 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2768,8 +2768,6 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 	.get_stats_count        = mv643xx_get_stats_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.get_strings            = mv643xx_get_strings,
-	.get_stats_count        = mv643xx_get_stats_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.nway_reset		= mv643xx_eth_nway_restart,
 };
 
-- 
1.5.3.GIT


