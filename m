From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/8] ftgmac100: Add ethtool n-way reset call
Date: Thu, 13 Apr 2017 10:59:40 +1000
Message-ID: <1492045180.7236.89.camel@kernel.crashing.org>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
         <20170412224443.17906-2-benh@kernel.crashing.org>
         <a08e926a-5d8b-cb02-a2dd-1256b255be27@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51976 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752134AbdDMA7r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 20:59:47 -0400
In-Reply-To: <a08e926a-5d8b-cb02-a2dd-1256b255be27@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 17:00 -0700, Florian Fainelli wrote:
> > -static int ftgmac100_nway_reset(struct net_device *ndev)
> > +static int ftgmac100_nway_reset(struct net_device *netdev)
> >   {
> > -     if (!ndev->phydev)
> > +     if (!netdev->phydev)
> >                return -ENXIO;
> > -     return phy_start_aneg(ndev->phydev);
> > +     return phy_start_aneg(netdev->phydev);
> 
> Can you use phy_ethtool_nway_reset() which does that (and also checks
> if phydev->drv is NULL which would be the case after an unbind).

Ah sure, I didn't notice that one, grepped the wrong driver :-)

I'll respin later today.

Thanks !

Cheers,
Ben.
