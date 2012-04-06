From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/6] doc, net: Remove instruction to set
 net_device::trans_start
Date: Fri, 6 Apr 2012 01:40:06 +0100
Message-ID: <1333672806.2652.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28117 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756800Ab2DFAkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:40:09 -0400
In-Reply-To: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 08baf561083bc27a953aa087dd8a664bb2b88e8e ('net:
txq_trans_update() helper') made it unnecessary for most drivers to
set net_device::trans_start (or netdev_queue::trans_start).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Documentation/networking/driver.txt |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/driver.txt b/Documentation/networking/driver.txt
index 83ce060..2128e41 100644
--- a/Documentation/networking/driver.txt
+++ b/Documentation/networking/driver.txt
@@ -58,13 +58,10 @@ Transmit path guidelines:
             TX_BUFFS_AVAIL(dp) > 0)
 		netif_wake_queue(dp->dev);
 
-2) Do not forget to update netdev->trans_start to jiffies after
-   each new tx packet is given to the hardware.
-
-3) An ndo_start_xmit method must not modify the shared parts of a
+2) An ndo_start_xmit method must not modify the shared parts of a
    cloned SKB.
 
-4) Do not forget that once you return 0 from your ndo_start_xmit
+3) Do not forget that once you return 0 from your ndo_start_xmit
    method, it is your driver's responsibility to free up the SKB
    and in some finite amount of time.
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
