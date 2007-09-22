From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH -mm] mv643xx_eth: Remove redundant multiple initialization
Date: Sat, 22 Sep 2007 13:24:08 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709221322360.22517@enigma.security.iitk.ac.in>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54989 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbXIVHvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 03:51:21 -0400
In-Reply-To: <20070918011841.2381bd93.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Of ethtool_ops->get_stats_count and ethtool_ops->get_ethtool_stats.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/net/mv643xx_eth.c |    2 --
 1 file changed, 2 deletions(-)

diff -ruNp a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c	2007-09-22 06:26:39.000000000 +0530
+++ b/drivers/net/mv643xx_eth.c	2007-09-22 13:15:41.000000000 +0530
@@ -2740,8 +2740,6 @@ static const struct ethtool_ops mv643xx_
 	.get_stats_count        = mv643xx_get_stats_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.get_strings            = mv643xx_get_strings,
-	.get_stats_count        = mv643xx_get_stats_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.nway_reset		= mv643xx_eth_nway_restart,
 };
 
