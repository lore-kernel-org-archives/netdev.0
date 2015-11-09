From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 9 Nov 2015 18:08:49 +0100
Message-ID: <20151109170849.GC3388@lunn.ch>
References: <4225885.EYXTHjRPmX@wuerfel>
 <20151109164232.GB3388@lunn.ch>
 <6910088.dNmooXDTJR@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6910088.dNmooXDTJR@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I suppose it comes down to, are we allowed to optionally implement
> > part of the DT binding?
> 
> I'm not sure what you are asking. A lot of DT bindings have both
> optional and mandatory properties. For mvneta, the "phy" and "phy-mode"
> properties are listed as mandatory, so the driver can safely assume
> that they are always present. If there are reasons to leave them out,
> and for the driver to handle that case correctly, the binding
> should be updated to mark them as optional.

Hi Arnd

You are looking at it from the perspective of the driver. I was
meaning from the perspective of the DT blob. Can be blob assume the
driver implements all of the binding, all of the time?

You use fixed-phy when the MAC is connected to a switch, not a phy. Or
when the MAC is connected to an SFP module. The driver can currently
be built to not implement the fixed-phy party of the binding. Is that
O.K. from the perspective of the DT blob? Or should the driver always
implement all of the binding, in which these NOP stubs should be
removed and fixed phy always be enabled for the drivers that use it.

	Andrew
