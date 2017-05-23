From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: RE: [PATCH 2/2] drivers: phy: Add Cortina CS4340 driver
Date: Tue, 23 May 2017 16:32:34 +0000
Message-ID: <DB5PR04MB12402841274D42B59CA9915DEAF90@DB5PR04MB1240.eurprd04.prod.outlook.com>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495554799-23060-3-git-send-email-bogdan.purcareata@nxp.com>
 <20170523155719.GA21169@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523155719.GA21169@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, May 23, 2017 6:57 PM
> To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH 2/2] drivers: phy: Add Cortina CS4340 driver
>=20
> On Tue, May 23, 2017 at 03:53:19PM +0000, Bogdan Purcareata wrote:
> > Add basic support for Cortina PHY drivers. Support only CS4340 for now.
> > The phys are not fully compatible with IEEE 802.3 clause 45 registers.
> > Implement proper read_status support, so that phy polling does not caus=
e
> > bus register access errors.
> >
> > Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> > ---
> >  drivers/net/phy/Kconfig        |  5 +++
> >  drivers/net/phy/Makefile       |  1 +
> >  drivers/net/phy/mdio-cortina.c | 90
> ++++++++++++++++++++++++++++++++++++++++++
>=20
> This is a phy driver, not a mdio bus driver. Please use the correct
> file name.

Will fix in v2, thanks!
Bogdan
