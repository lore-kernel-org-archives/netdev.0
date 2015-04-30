From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 3/8] net: phy: Allow PHY devices to identify
 themselves as Ethernet switches
Date: Thu, 30 Apr 2015 20:19:46 +0200
Message-ID: <20150430181946.GD1476@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <1430359064-23454-4-git-send-email-f.fainelli@gmail.com>
 <20150430125658.GB22831@lunn.ch>
 <55425AB3.2040908@gmail.com>
 <20150430171630.GE18874@lunn.ch>
 <55426868.8020606@gmail.com>
 <20150430174837.GB1476@lunn.ch>
 <55426E91.5000101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44931 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbbD3SYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 14:24:24 -0400
Content-Disposition: inline
In-Reply-To: <55426E91.5000101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Are you suggesting this phy driver sat in the middle effectively
> > performs auto negotiation in both directions? It sees what both sides
> > offer and then gives back the highest common setting?
> 
> Yes, that's what I would be tempted to do.

O.K, i need to think about that for a while.
 
> So right now, for any port you can utilize standard PHY-related or
> fixed-PHY related properties, for instance this is what I use on a
> BCM7445 which has the following setup:
> 
> - Port 0 has an internal gigabit PHY on dsa,mii-bus
> - Port 1 is connected to an external BCM53125 switch
> - Port 7 is connected to an internal MoCA PHY, whose link comes from a
> special interrupt
> - Port 8 is CPU
> 
> So today, the only thing we are missing is giving the CPU port some link
> information, but we could probably utilize a 'fixed-link' property for
> that maybe?

The Marvell drivers don't look at this phy information. But i should
have good examples from the SF2 driver i can use :-)

I also think the core DSA code does not allow for a phy on CPU and DSA
ports. But that should not be too big a problem.

       Andrew
