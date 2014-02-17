From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] gianfar: Replace sysfs stubs with module
 params (fix)
Date: Sun, 16 Feb 2014 23:48:43 -0500 (EST)
Message-ID: <20140216.234843.10302057405564080.davem@davemloft.net>
References: <1392379445-28358-1-git-send-email-claudiu.manoil@freescale.com>
	<1392379445-28358-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaBQEsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 23:48:45 -0500
In-Reply-To: <1392379445-28358-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 14 Feb 2014 14:04:01 +0200

> Removing the sysfs stubs for the Tx FIFOCFG and ATTRELI
> (stashing) config registers, as these registers may only
> be configured after a MAC reset, with the controller stopped
> (i.e. during hw init, at probe() time). The current sysfs
> stubs allow on-the-fly updates of these registers (the locking
> measures are useless and only add unecessary code).
> 
> Changing these registers on-the-fly is strogly discouraged.
> In this regard, this patch may be seen as a security fix.
> 
> To address this issue and not lose entirely these config
> params, they are now accessible as driver module parameters,
> and their names and default values have been preserved.
> 
> Moreover, the stasing configuration options were effectively
> disabled (didn't get to the hw anyway if changed) because
> the stashing device_flags (HAS_BD_STASHING|HAS_BUF_STASHING)
> were "accidentally" cleared during probe(). The patch fixes
> this bug as well.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Sorry, no new module parameters.

And as you state these never actually reached the hardware so they
_never worked_.  Please just remove them.
