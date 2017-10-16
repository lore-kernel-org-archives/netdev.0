From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII
 bus
Date: Mon, 16 Oct 2017 15:39:43 +0200
Message-ID: <20171016133943.GA7802@lunn.ch>
References: <20171016104525.26810-1-mnhu@prevas.dk>
 <20171016123233.GD4255@lunn.ch>
 <02997de6-1c8a-d69b-d19b-3a811288e8ed@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Martin =?iso-8859-1?Q?Hundeb=F8ll?= <mnhu@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:46406 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751817AbdJPNjs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 09:39:48 -0400
Content-Disposition: inline
In-Reply-To: <02997de6-1c8a-d69b-d19b-3a811288e8ed@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 03:16:51PM +0200, Martin Hundebøll wrote:
> On 2017-10-16 14:32, Andrew Lunn wrote:
> >So this used to work. I have a 10G phy connected to the external MII
> >bus on a 6390. I wonder when this got broken? Supporting phy-handle is
> >old code, so when i added the external MII i don't think i needed to
> >change any generic code.
> 
> It could look like commit cd28a1a9baee7 ('net: dsa: fully divert PHY
> reads/writes if requested') changed the of-case to use the mdio bus
> associated with struct dsa_switch unconditionally.

Hi Martin

I think ds->phys_mii_mask is playing a role here. I need to add some
debug prints to my setup and see what is happening with my external
10G PHY.

This phy code is just too complex :-(

     Andrew
