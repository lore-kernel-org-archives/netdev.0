From: Alexander Aring <aar@pengutronix.de>
Subject: [PATCHv4 net-next 03/12] 6lowpan: remove ipv6 module request
Date: Wed, 15 Jun 2016 21:20:18 +0200
Message-ID: <20160615192027.4064-4-aar@pengutronix.de>
References: <20160615192027.4064-1-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:35786 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932951AbcFOTVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:21:13 -0400
In-Reply-To: <20160615192027.4064-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we use exported function from ipv6 kernel module we don't need to
request the module anymore to have ipv6 functionality.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 net/6lowpan/core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index 801404c..1c7a42b 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -158,8 +158,6 @@ static int __init lowpan_module_init(void)
 		return ret;
 	}
 
-	request_module_nowait("ipv6");
-
 	request_module_nowait("nhc_dest");
 	request_module_nowait("nhc_fragment");
 	request_module_nowait("nhc_hop");
-- 
2.8.3
