From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: Do not clobber PHY link outside
 of state machine
Date: Tue, 7 Feb 2017 14:14:40 +0100
Message-ID: <20170207131440.GF31560@lunn.ch>
References: <20170206235523.23216-1-f.fainelli@gmail.com>
 <20170206235523.23216-5-f.fainelli@gmail.com>
 <20170207001132.GB30169@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DB027DB40@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "zefir.kurtisi@neratec.com" <zefir.kurtisi@neratec.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Jarod Wilson <jarod@redhat.com>,
        open list <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027DB40@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Related is that polling the phy status every second can be bad news for
> system latency.
> Typically it involves bit-bashing an interface with spin-delays to
> meet the slow timings (with extra delays to allow for posted writes).
> An alternative would be to do a very slow bit-bang on each timer tick,
> this would need to be sped up and finished before any other actions.

Or just use PHY interrupts. That completely stops the MDIO polling.

   Andrew
