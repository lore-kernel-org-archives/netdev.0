From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/14] Network devices ops (wave 4)
Date: Wed, 26 Nov 2008 01:53:32 -0800 (PST)
Message-ID: <20081126.015332.152884272.davem@davemloft.net>
References: <20081126011419.402319779@linux-foundation.org>
	<20081125.210658.179033377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbYKZJxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 04:53:33 -0500
In-Reply-To: <20081125.210658.179033377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 25 Nov 2008 21:06:58 -0800 (PST)

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 25 Nov 2008 17:14:19 -0800
> 
> > This fixes the build bug for 8390 library based drivers,
> > then updates a bunch more drivers.  Build tested all the network drivers
> > on x86.
> 
> All applied thanks Stephen.

Ummm, Stephen, I need to add the following build fix
to the net-next-2.6

Please be more careful next time.

smc-mca: Fix build failure due to typo.

ultra_netdev_ops --> ultramca_netdev_ops

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/smc-mca.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index ae5f38d..404b80e 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -183,7 +183,7 @@ static char *smc_mca_adapter_names[] __initdata = {
 static int ultra_found = 0;
 
 
-static const struct net_device_ops ultra_netdev_ops = {
+static const struct net_device_ops ultramca_netdev_ops = {
 	.ndo_open		= ultramca_open,
 	.ndo_stop		= ultramca_close_card,
 
-- 
1.5.6.5

