From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Generalise "auto-negotiation done" function, move
 generic PHY code to phy_device.c
Date: Mon, 17 Sep 2012 13:19:10 -0400 (EDT)
Message-ID: <20120917.131910.1238928585646354544.davem@davemloft.net>
References: <504DCF39.3000704@sysgo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com,
	alexander.sverdlin.ext@nsn.com
To: asv@sysgo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756246Ab2IQRTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 13:19:13 -0400
In-Reply-To: <504DCF39.3000704@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <asv@sysgo.com>
Date: Mon, 10 Sep 2012 13:30:01 +0200

> From: Alexander Sverdlin <alexander.sverdlin@sysgo.com>
> 
> Generalise "auto-negotiation done" function, move generic PHY code to phy_device.c 
> 
> Not all devices have "auto-negotiation done" bit at the place, as expected by
> phy_aneg_done() in phy.c. Example of such device is Marvell 88E61xx Ethernet 
> switch which could be controlled by Linux PHY layer, if struct phy_driver had
> abstraction for above function. So move hardware-dependent implementation details
> for "generic" PHY to phy_device.c, and modify all PHY drivers to use new field.
> Now phy.c contains only high-level state-machine functionality, leaving 
> hardware-layer to different drivers.
> 
> Signed-off-by: Alexander Sverdlin <alexander.sverdlin@sysgo.com>

You're adding this abstration, and even describe where it would be needed,
but you aren't providing the changes that make use of this new abstration
at all.

That's rather pointless, and we want to see the users of new interfaces
before we add them.

Resubmit this when you can also submit the patch which the Marvell driver
needs, which would actually make use of this.
