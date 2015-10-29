From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work
 for polling
Date: Thu, 29 Oct 2015 10:52:34 -0400
Message-ID: <20151029145234.GB21131@ketchup.mtl.sfl>
References: <56321DA1.4060304@baylibre.com>
 <20151029135156.GQ2307@lunn.ch>
 <563228C3.6010501@baylibre.com>
 <20151029144012.GT2307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56780 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757426AbbJ2PCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:02:25 -0400
Content-Disposition: inline
In-Reply-To: <20151029144012.GT2307@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Thursday 29 (44) 03:40 PM, Andrew Lunn wrote:
> > Thanks for the hint, I will test this, but while reviewing the datasheet,
> > the port 5 has no PHY, so must only be used as cpu port.
> 
> Not necessarily. All that is needed is an external phy. Linux does not
> care what MDIO bus that phy hangs off. It could be the same MDIO bus
> as the switch, or some other MDIO bus. It is likely that port 5 is the
> CPU port, but it does not have to be.

Indeed in my setup with a single 88E6352, we will soon add an external
PHY there (or on port 6, doesn't matter) to make it a 6-port switch.

> > I also have another patchset which fixes 2 setup registers writes and
> > adds a shiny new mv88e6060.h based on mv88e6xxx.h.
> 
> Great. I hope that will help determine if we can merge 6060 into 6xxx.

Is 6060 supported by the 6352 family? It doesn't share any mv88e6xxx
code...

Thanks,
-v
