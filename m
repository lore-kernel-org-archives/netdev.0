From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] net: remove empty MDIO bus reset
 functions
Date: Thu, 27 Mar 2014 00:19:34 -0400 (EDT)
Message-ID: <20140327.001934.767098814214449066.davem@davemloft.net>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaC0ETi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 00:19:38 -0400
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 26 Mar 2014 18:07:12 -0700

> This patchset removes all empty MDIO bus reset functions that we have in the
> tree (hopefully all of them). This function is optional for the MDIO bus code in
> drivers/net/phy/mdio_bus.c::mdiobus_register, the documentation is updated to
> reflect that.
> 
> Having less call sites to update will allow us to implement a generic BMCR_RESET
> based PHY reset for MDIO buses that require to reset their PHYs before their
> PHY detection succeeds (e.g: HiSilicon hip04 current submission) and provide it
> as a helper.

Series applied, thanks.
