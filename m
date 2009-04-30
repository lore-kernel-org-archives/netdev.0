From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] MDIO and ethtool enhancements
Date: Wed, 29 Apr 2009 17:31:28 -0700 (PDT)
Message-ID: <20090429.173128.241115147.davem@davemloft.net>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761635AbZD3Abf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:31:35 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 29 Apr 2009 19:01:26 +0100

> The first part of this series introduce counterparts to <linux/mii.h>
> and the mii module for use with MDIO clause 45 devices and controllers
> that support both clause 22 and clause 45, and change several 10G
> Ethernet drivers to use them.
> 
> The remaining patches are a bit miscellaneous:
> - Extend generic flow control/pause frame support and change the sfc
> driver to use it
> - Add fields to the ethtool_cmd structure to report the supported MDIO
> mode(s) and link partner advertising flags, and implement these in the
> mdio and mii modules
> - Add support for backplane (1000BASE-KR and 10GBASE-KR/KX4) modes to
> ethtool and the mdio module

I like these changes, I'll add them to net-next-2.6 and we can
further refine them as-needed.

> I have a few questions to be resolved:
> - Is the naming of functions and constants in <linux/mdio.h> reasonable,
> or is more qualification required?

I think those are fine.

> - Is it reasonable to carry on using the MII ioctl interface with flags?

I don't know, I'm a little disappointed it's still around but
I suppose someone finds it useful.

> - Are there more drivers that could use these generic definitions (I
> haven't looked at the Broadcom drivers yet)?

No idea.

> - Does the backplane code work at all (I don't have any suitable
> hardware yet)?

The code will be there so someone can play around and test it.
