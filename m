From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Mon, 9 Jan 2017 17:00:19 +0100
Message-ID: <20170109160019.GF25588@lunn.ch>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
 <20170109073236.GA1862@nanopsycho>
 <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109151131.GC1862@nanopsycho>
 <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > No. That should be unique within one switch. In mlxsw we name it "p1",
> > "p2", ...
> >
> > The final netdev names are:
> > enp3s0np1, enp3s0np2, ...
> 

mlxsw are pci devices, so it follows this convention, i think:

 *   [P<domain>]p<bus>s<slot>[f<function>][n<phys_port_name>|d<dev_port>]
 *                                          PCI geographical location

Our devices are not on PCI. So they won't follow this. I've no idea
what they actually follow, since some are MDIO devices, some are SPI
devices, some are memory mapped.

I'm not against making the label option, but i do want to better
understand what we get as a result, just to make sure it is sensible.

Vivien, could you try a recent udev and see what happens?

	Thanks
		Andrew
