From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next] dsa: slave: support phy devices on external MII bus
Date: Wed, 18 Oct 2017 21:09:05 +0200
Message-ID: <20171018190905.GH15371@lunn.ch>
References: <20171018162138.GA15371@lunn.ch>
 <ad992ed8-37b8-9c52-848c-78fa0368de8f@gmail.com>
 <8994adaa-6223-20f1-9221-49e9b644d03f@prevas.dk>
 <3b972ab8-3d3e-7666-5c26-f111f5cdd61a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin =?iso-8859-1?Q?Hundeb=F8ll?= <mnhu@prevas.dk>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:50285 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdJRTJH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 15:09:07 -0400
Content-Disposition: inline
In-Reply-To: <3b972ab8-3d3e-7666-5c26-f111f5cdd61a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, but with the caveat already covered today: there is a possible
> problem with having to divert MDIO accesses of a PHY pointed by
> phy-handle towards the internal switch bus because of specific problems
> such as those explained in drivers/net/bcm_sf2.c, I don't mind trying to
> do things smarter or in a different way, but that needs to be something
> possible.

Hi Florian

Are you referring to:

        /* Include the pseudo-PHY address to divert reads towards our
         * workaround. This is only required for 7445D0, since 7445E0
         * disconnects the internal switch pseudo-PHY such that we can use the
         * regular SWITCH_MDIO master controller instead.
         *
         * Here we flag the pseudo PHY as needing special treatment and would
         * otherwise make all other PHY read/writes go to the master MDIO bus
         * controller that comes with this switch backed by the "mdio-unimac"
         * driver.
         */
?

Do you have an example device tree fragment, just to make it clearer?

Thanks
	Andrew
