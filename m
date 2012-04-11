From: Jim Cromie <jim.cromie@gmail.com>
Subject: [PATCH 07/11] ethernet: replace open-coded ARRAY_SIZE with macro
Date: Tue, 10 Apr 2012 18:56:22 -0600
Message-ID: <1334105782-9286-1-git-send-email-jim.cromie@gmail.com>
Cc: trivial@vger.kernel.org, Jim Cromie <jim.cromie@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, joe@perches.com, florian@openwrt.org,
	netdev@pradeepdalvi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:38294 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab2DKA40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:56:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jim Cromie <jim.cromie@gmail.com>
---
 drivers/net/ethernet/s6gmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 1895605..8e9fda0 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -937,7 +937,7 @@ static struct net_device_stats *s6gmac_stats(struct net_device *dev)
 	do {
 		unsigned long flags;
 		spin_lock_irqsave(&pd->lock, flags);
-		for (i = 0; i < sizeof(pd->stats) / sizeof(unsigned long); i++)
+		for (i = 0; i < ARRAY_SIZE(pd->stats); i++)
 			pd->stats[i] =
 				pd->carry[i] << (S6_GMAC_STAT_SIZE_MIN - 1);
 		s6gmac_stats_collect(pd, &statinf[0][0]);
-- 
1.7.8.1
