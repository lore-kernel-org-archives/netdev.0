From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac: Fix platform data handling and make
 usable for am3517
Date: Thu, 05 Dec 2013 20:39:55 -0500 (EST)
Message-ID: <20131205.203955.1282361417309480469.davem@davemloft.net>
References: <20131203231301.GN26766@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3LFBj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:39:57 -0500
In-Reply-To: <20131203231301.GN26766@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Lindgren <tony@atomide.com>
Date: Tue, 3 Dec 2013 15:13:02 -0800

> When booted with device tree, we may still have platform data passed
> as auxdata. For am3517 this is needed for passing the interrupt_enable
> and interrupt_disable callbacks that access the omap system control module
> registers. These callback functions will eventually go away when we have
> a separate system control module driver.
> 
> Some of the things that are currently passed as platform data we don't need
> to set up as device tree properties as they are always the same on am3517.
> So let's use a new compatible flag for those so we can get those from
> the device tree match data.
> 
> Also note that we need to fix setting of phy_dev to NULL instead of an empty
> string as the code later on uses that to find the first phy on the mdio bus.
> This seems to have been caused by 5d69e0076a72 (net: davinci_emac: switch to
> new mdio).
> 
> Signed-off-by: Tony Lindgren <tony@atomide.com>

Applied, thanks.
