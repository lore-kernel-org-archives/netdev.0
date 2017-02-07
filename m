From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next] net: phy: Allow splitting MDIO bus/device support
 from PHYs
Date: Tue, 7 Feb 2017 01:08:12 +0100
Message-ID: <20170207000812.GA30169@lunn.ch>
References: <20170131032931.1494-1-f.fainelli@gmail.com>
 <34f35da1-086a-0809-b962-7d0dbcf9df8d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        rmk+kernel@armlinux.org.uk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57751 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751789AbdBGAIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 19:08:16 -0500
Content-Disposition: inline
In-Reply-To: <34f35da1-086a-0809-b962-7d0dbcf9df8d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Introduce a new configuration symbol: MDIO_DEVICE which allows building
> > the MDIO devices and bus code, without pulling in the entire Ethernet
> > PHY library and devices code.
> > 
> > PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
> > updated to reflect that.
> > 
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Andrew, Russell, does that seem sensible to you, shall I re-submit this
> as a proper patch?

Hi Florian

It does make sense, given that we have some MDIO busses not used for
networking.

	Andrew
