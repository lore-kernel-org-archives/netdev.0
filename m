From: Rodney Cummings <rodney.cummings@ni.com>
Subject: RE: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Mon, 16 Oct 2017 16:52:57 +0000
Message-ID: <CY1PR0401MB153605AD6262F8E25A41F913924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
 <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
 <20171016160941.GA13339@lunn.ch>
 <CY1PR0401MB1536097366C596C42A8B225B924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
 <20171016164737.GD13339@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016164737.GD13339@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PAUSE is only one higher layer entity. The source MAC address may not matte=
r there, but it definitely matters for other higher layer entities (like IE=
EE Std 1588).

The Marvell switch can run more than just PAUSE as a higher layer protocol.

How do you guarantee that this MAC address is used for PAUSE, and only for =
PAUSE?

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Monday, October 16, 2017 11:48 AM
> To: Rodney Cummings <rodney.cummings@ni.com>
> Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> kernel@savoirfairelinux.com; David S. Miller <davem@davemloft.net>;
> Florian Fainelli <f.fainelli@gmail.com>; David Laight
> <David.Laight@ACULAB.COM>
> Subject: Re: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
>=20
> On Mon, Oct 16, 2017 at 04:28:04PM +0000, Rodney Cummings wrote:
> > Hi Andrew,
> >
> > I may have misunderstood.
> >
> > If this MAC address is the destination
>=20
> Nope. This is the source address, for Pause frames.
>=20
> > My concern is that for a source MAC address, a local random MAC
> > address is not safe in all networks, because it has the potential
> > for duplication. That topic has been discussed quite a bit in IEEE
> > 802.
>=20
> Duplications don't matter, for pause frames. The source address
> appears to be unused. And these frames don't get passed the direct
> peers MAC layer.
>=20
> 	Andrew
