From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/3] via-velocity : update receive packets statistics.
Date: Thu, 4 Aug 2011 14:37:55 +0200
Message-ID: <20110804123755.GA14858@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jon Nelson <jnelson@jamponi.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45259 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab1HDMyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 08:54:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=14076.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jon Nelson <jnelson@jamponi.net>
---

 drivers/net/via-velocity.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index deb1eca..ae66696 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2092,6 +2092,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	netif_rx(skb);
 
 	stats->rx_bytes += pkt_len;
+	stats->rx_packets++;
 
 	return 0;
 }
-- 
1.7.4.4

