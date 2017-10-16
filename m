From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Mon, 16 Oct 2017 18:44:03 +0200
Message-ID: <20171016164403.GC13339@lunn.ch>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
 <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
 <20171016160941.GA13339@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DD00980E8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rodney Cummings <rodney.cummings@ni.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00980E8@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 04:30:34PM +0000, David Laight wrote:
> From: Andrew Lunn
> > Sent: 16 October 2017 17:10
> ...
> > So, received Pause frames never leave the MAC. They don't get bridged,
> > nor do they get passed up for host processing. They are purely point
> > to point between two MAC peers. The destination is unambiguous. It is
> > simple the other MAC peer. The destination address makes it clear it
> > is a pause frame, the the source address seems to be unneeded.
> > 
> > In this context, a random MAC addresses are safe.
> 
> Is there any reason why a fixed value (say 00:00:00:00:00:00)
> can't be used?

I was going to suggest 42:42:42:42:42:42 :-)

  Andrew
