From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell
 PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 16:41:18 +0200
Message-ID: <20140923144118.GF18924@kwain>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
 <51745791.Wuu5QiQB2e@wuerfel>
 <20140923140113.GC18924@kwain>
 <3708177.kEGF9Dk44n@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3708177.kEGF9Dk44n@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 23, 2014 at 04:33:48PM +0200, Arnd Bergmann wrote:
> On Tuesday 23 September 2014 16:01:13 Antoine Tenart wrote:
> >=20
> > On Tue, Sep 23, 2014 at 02:38:39PM +0200, Arnd Bergmann wrote:
> > > On Tuesday 23 September 2014 14:15:30 Antoine Tenart wrote:
> > > > +Optional properties:
> > > > +- port-id: should be '0','1' or '2'.
> > > > +- phy-addr: MDIO address of the PHY.
> > > > +- local-mac-address: see ethernet.txt file in the same directo=
ry.
> > > > +
> > > >=20
> > >=20
> > > I believe new bindings should not use "phy-addr" properties, but
> > > instead use a phy-handle property pointing to a phy device instea=
d.
> >=20
> > That's the MDIO address of the PHY. It's a bit difficult to use a p=
hy
> > device as the driver uses the libphy. And that would break the plat=
form
> > using it.
> >=20
> > Or maybe you have something in mind?
>=20
> I don't understand what you mean. Doesn't libphy imply using a phy_de=
vice?
> What I meant was that you should be able to just call the standard
> of_phy_connect() and other interfaces to deal with phylib.
>=20

Yes sure, I read again my answer and... well I should have had a better
look on the matter.

Anyway, as the proposed binding seems to be OK with you, I'll update th=
e
series accordingly.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
