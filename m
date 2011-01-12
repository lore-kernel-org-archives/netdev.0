From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next-2.6] netdev: bfin_mac: Use is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 10:30:11 +0100
Message-ID: <1294824611-10483-1-git-send-email-tklauser@distanz.ch>
To: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:38508 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932238Ab1ALJaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 04:30:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 0b9fc51..fe75e7a 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1293,7 +1293,7 @@ static void bfin_mac_multicast_hash(struct net_device *dev)
 		addrs = ha->addr;
 
 		/* skip non-multicast addresses */
-		if (!(*addrs & 1))
+		if (!is_multicast_ether_addr(addrs))
 			continue;
 
 		crc = ether_crc(ETH_ALEN, addrs);
-- 
1.7.0.4

