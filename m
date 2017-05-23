From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: RE: [PATCH 1/2] net: phy: Update get_phy_c45_ids for Cortina PHYs
Date: Tue, 23 May 2017 16:32:07 +0000
Message-ID: <DB5PR04MB1240098B96F6EEF3730DF054EAF90@DB5PR04MB1240.eurprd04.prod.outlook.com>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495554799-23060-2-git-send-email-bogdan.purcareata@nxp.com>
 <20170523160353.GB21169@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523160353.GB21169@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, May 23, 2017 7:04 PM
> To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH 1/2] net: phy: Update get_phy_c45_ids for Cortina PHY=
s
>=20
> On Tue, May 23, 2017 at 03:53:18PM +0000, Bogdan Purcareata wrote:
> > Complete the work started by the following patches
> > 5f6c99e0 net: phy: fix a bug in get_phy_c45_ids
> > da1da284 net/phy: tune get_phy_c45_ids to support more c45 phy
> >
> > in order to properly get non-standard C45 10G PHY IDs (e.g. Cortina
> > CS4340).
>=20
> At a first look, this seems to be a hack to work around a broken phy.
>=20
> Instead of this, can you use the ethernet-phy-id property in device
> tree?

The patches mentioned in the commit message add _some_ support for the Cort=
ina PHYs - mainly checking for devices at additional locations. Once they a=
re found, the phy IDs must be read from custom locations. I followed the u-=
boot model [1].

I was aiming to patch the get_phy_c45_ids to fully handle the Cortina PHY s=
cenario (right now, the support is only partial).=20

[1] http://code.metager.de/source/xref/denx/u-boot/drivers/net/phy/cortina.=
c#288

Thank you!
Bogdan
