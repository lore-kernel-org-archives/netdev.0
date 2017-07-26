From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 08/18] net: mvpp2: make the phy optional
Date: Wed, 26 Jul 2017 18:20:00 +0200
Message-ID: <20170726162000.GJ12049@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-9-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41005 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751653AbdGZQUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:20:07 -0400
Content-Disposition: inline
In-Reply-To: <20170724134848.19330-9-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 03:48:38PM +0200, Antoine Tenart wrote:
> SFP ports do not necessarily need to have an Ethernet PHY between the
> SoC and the actual physical port. However, the driver currently makes
> the "phy" property mandatory, contrary to what is stated in the Device
> Tree binding.
> 
> To allow handling the PPv2 controller on those boards, this patch makes
> the PHY optional, and aligns the PPv2 driver on its device tree
> documentation.

It is an architectural question...

but with the boards i have with an SFF port, i actually use a
fixed-phy to represent the SFF. Then nothing special is needed.

Also, Russell King posted his phylink patches. Once accepted, you are
going to want to re-write some of this to make use of that code.

      Andrew
