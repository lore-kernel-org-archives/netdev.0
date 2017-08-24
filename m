From: Stefan Chulski <stefanc@marvell.com>
Subject: RE: [EXT] Re: [PATCH net-next 09/13] net: mvpp2: dynamic
 reconfiguration of the PHY mode
Date: Thu, 24 Aug 2017 17:25:47 +0000
Message-ID: <496efc37792147bb9ab137aae4d69a8e@IL-EXCH01.marvell.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch> <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch> <20170824161945.GG28443@kwain>
 <20170824165743.GB18700@lunn.ch>
 <20170824170401.GA20805@n2100.armlinux.org.uk> <20170824171301.GH28443@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kishon@ti.com" <kishon@ti.com>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "miquel.raynal@free-electrons.com" <miquel.raynal@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        "Russell King - ARM Linux" <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824171301.GH28443@kwain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >                      .------- RJ45
> > MVPP2 ----- 88x3310 PHY
> >                      `------- SFP+
> 
> And the "MVPP2" part can be expended to:
> 
>         .-- GoP #0 --.
> MVPP2 ----- GoP #1 ---- Comphy lane #X -- 88x3310
>         `-- GoP #2 --'
> 
> Thanks!
> Antoine

One more point, Alaska 3310 PHY SoC and Marvell Embedded Processor SoC(A8K) are different SoC's.
Comphy driver configures Serdes IP in Marvell Embedded Processor SoC and media(SFP or RJ45) autodetect is done in Alaska 3310 PHY SoC(mostly by firmware).

Regards,
Stefan
