From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] via-velocity: enable perfect filtering for multicast
	packets
Date: Fri, 7 Nov 2008 23:36:17 +0100
Message-ID: <20081107223617.GA23082@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	=?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	HaraldWelte@viatech.com, JoeyZhuo@via.com.tw, AJJiang@via.com.tw,
	BruceChang@via.com.tw, WaltonLi@via.com.tw
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58754 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbYKGWgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 17:36:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joey Zhuo <joeyzhuo@via.com.tw>
Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3590ea5..11cb3e5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2296,7 +2296,7 @@ static void velocity_set_multi(struct net_device *dev)
 		}
 
 		mac_set_cam_mask(regs, vptr->mCAMmask);
-		rx_mode = (RCR_AM | RCR_AB);
+		rx_mode = RCR_AM | RCR_AB | RCR_AP;
 	}
 	if (dev->mtu > 1500)
 		rx_mode |= RCR_AL;
-- 
1.5.3.3

