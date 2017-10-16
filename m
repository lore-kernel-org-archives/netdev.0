From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Mon, 16 Oct 2017 18:47:37 +0200
Message-ID: <20171016164737.GD13339@lunn.ch>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
 <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
 <20171016160941.GA13339@lunn.ch>
 <CY1PR0401MB1536097366C596C42A8B225B924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: Rodney Cummings <rodney.cummings@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CY1PR0401MB1536097366C596C42A8B225B924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 04:28:04PM +0000, Rodney Cummings wrote:
> Hi Andrew,
> 
> I may have misunderstood.
> 
> If this MAC address is the destination

Nope. This is the source address, for Pause frames.

> My concern is that for a source MAC address, a local random MAC
> address is not safe in all networks, because it has the potential
> for duplication. That topic has been discussed quite a bit in IEEE
> 802.

Duplications don't matter, for pause frames. The source address
appears to be unused. And these frames don't get passed the direct
peers MAC layer.

	Andrew
