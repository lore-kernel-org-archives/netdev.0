From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ethtool, mdio, mii: Specify MDIO
 information fields in struct ethtool_cmd
Date: Thu, 01 Mar 2012 16:42:09 -0500 (EST)
Message-ID: <20120301.164209.604314658559846007.davem@davemloft.net>
References: <1330561407.5881.13.camel@bwh-desktop>
	<1330561582.5881.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965106Ab2CAVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 16:42:12 -0500
In-Reply-To: <1330561582.5881.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Mar 2012 00:26:22 +0000

> Add comments for ethtool_cmd::phy_address and
> ethtool_cmd::mdio_support, and definitions of the flags currently
> used in mdio_support.
> 
> In the mdio library, assert that its own flags continue to match those
> in the ethtool interface.
> 
> In the mii library, use the ethtool flag definition and stop
> including <linux/mdio.h>.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
