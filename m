From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work
 for polling
Date: Thu, 29 Oct 2015 15:40:12 +0100
Message-ID: <20151029144012.GT2307@lunn.ch>
References: <56321DA1.4060304@baylibre.com>
 <20151029135156.GQ2307@lunn.ch>
 <563228C3.6010501@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <563228C3.6010501@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Thanks for the hint, I will test this, but while reviewing the datasheet,
> the port 5 has no PHY, so must only be used as cpu port.

Not necessarily. All that is needed is an external phy. Linux does not
care what MDIO bus that phy hangs off. It could be the same MDIO bus
as the switch, or some other MDIO bus. It is likely that port 5 is the
CPU port, but it does not have to be.
 
> I also have another patchset which fixes 2 setup registers writes and
> adds a shiny new mv88e6060.h based on mv88e6xxx.h.

Great. I hope that will help determine if we can merge 6060 into 6xxx.

       Andrew
