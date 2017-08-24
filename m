From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 18:57:43 +0200
Message-ID: <20170824165743.GB18700@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch>
 <20170824161945.GG28443@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824161945.GG28443@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I see what could be the issue but I do not understand one aspect though:
> how could we switch from one PHY to another, as there's only one output
> between the SoC (and so a given GoP#) and the board. So if a given PHY
> can handle multiple modes I see, but in the other case a muxing
> somewhere would be needed? Or did I miss something?

I think we need a hardware diagram...

How are the RJ45, copper PHY, SFP module connected to the SoC?

Somewhere there must be a mux, to select between copper and
fibre. Where is that mux?

    Andrew
