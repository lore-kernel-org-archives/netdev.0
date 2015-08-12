From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net] net: dsa: Do not override PHY interface if already
 configured
Date: Wed, 12 Aug 2015 14:35:24 -0700
Message-ID: <20150812213524.GA30114@roeck-us.net>
References: <1439063937-16316-1-git-send-email-f.fainelli@gmail.com>
 <20150812.143035.511637354777280164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37910 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbHLVfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:35:30 -0400
Content-Disposition: inline
In-Reply-To: <20150812.143035.511637354777280164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 02:30:35PM -0700, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sat,  8 Aug 2015 12:58:57 -0700
> 
> > In case we need to divert reads/writes using the slave MII bus, we may have
> > already fetched a valid PHY interface property from Device Tree, and that
> > mode is used by the PHY driver to make configuration decisions.
> > 
> > If we could not fetch the "phy-mode" property, we will assign p->phy_interface
> > to PHY_INTERFACE_MODE_NA, such that we can actually check for that condition as
> > to whether or not we should override the interface value.
> > 
> > Fixes: 19334920eaf7 ("net: dsa: Set valid phy interface type")
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> > ---
> > Hi Guenter,
> > 
> > Could you verify this does not break what you were trying to fix with your change?
> > I am fairly confident this will not because for "PHYs" built-into the switch port
> > we will not be able to fetch a "phy-mode" property from DT, so we will use
> > PHY_INTERFACE_MODE_NA, but here, we will re-assign them to PHY_INTERFACE_MODE_GMII
> > as before.
> 
> I was trying to wait for Guenter's testing before applying this, but it's been some
> time already and it makes no sense to wait any longer.
> 
No problem. I am overloaded, and my test system is currently down, so it will
take a while. If I find a problem I'll discuss with Florian and send a follow-up
patch if needed.

Guenter
