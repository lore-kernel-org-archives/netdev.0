From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 10/13] powerpc/ps3: printing fixups for l64 to ll64
 convserion: drivers/net
Date: Wed, 14 Jan 2009 17:09:30 +1100
Message-ID: <20090114170930.51291bc6.sfr@canb.auug.org.au>
References: <20090114165450.ebbc11a7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, cbe-oss-dev@ozlabs.org,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org
To: Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:47582 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107AbZANGOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 01:14:36 -0500
In-Reply-To: <20090114165450.ebbc11a7.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ps3_gelic_wireless.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index ec23142..335da48 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2168,7 +2168,7 @@ static void gelic_wl_connected_event(struct gelic_wl_info *wl,
 		complete(&wl->assoc_done);
 		netif_carrier_on(port_to_netdev(wl_port(wl)));
 	} else
-		pr_debug("%s: event %#lx under wpa\n",
+		pr_debug("%s: event %#llx under wpa\n",
 				 __func__, event);
 }
 
-- 
1.6.0.5

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
