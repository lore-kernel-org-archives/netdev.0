From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: Ensure clocks are enabled while using mdio bus
Date: Mon, 15 Jun 2015 05:15:33 +0200
Message-ID: <20150615031533.GA10886@lunn.ch>
References: <1434123545-13549-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB373E1D5EADCB4753C8D0F15F5B90@BLUPR03MB373.namprd03.prod.outlook.com>
 <20150614144118.GA7800@lunn.ch>
 <557DD698.3020300@gmail.com>
 <BLUPR03MB373121D2B0C2168C5193A2EF5B80@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55989 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329AbbFODVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jun 2015 23:21:21 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR03MB373121D2B0C2168C5193A2EF5B80@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy

> If so, it just need to enable ENET ipg clock for your cases, not all enet clocks.
> Ipg clock is for MDIO bus read/write, for ENET registers accessing. (fep->clk_ipg)

O.K, thanks. I will respin the patch with just the ipg clock.

> Which switch phy do you use ? I tried BCM54220 switch on the driver that works fine.

I'm using two mv88e6352 and a mv88e6185 in cascade.

    Andrew
