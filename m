From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 18:19:45 +0200
Message-ID: <20170824161945.GG28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="HB4mHL4PVvkpZAgW"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824160124.GA18700@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HB4mHL4PVvkpZAgW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 24, 2017 at 06:01:24PM +0200, Andrew Lunn wrote:
> On Thu, Aug 24, 2017 at 05:52:41PM +0200, Antoine Tenart wrote:
> > On Thu, Aug 24, 2017 at 04:56:09PM +0200, Andrew Lunn wrote:
> > > On Thu, Aug 24, 2017 at 10:38:19AM +0200, Antoine Tenart wrote:
> > > > This patch adds logic to reconfigure the comphy/gop when the link s=
tatus
> > > > change at runtime. This is very useful on boards such as the mcbin =
which
> > > > have SFP and Ethernet ports connected to the same MAC port: dependi=
ng on
> > > > what the user connects the driver will automatically reconfigure the
> > > > link mode.
> > >=20
> > > I would expect each of these external Ethernet ports to have its own
> > > Ethernet PHY. Don't you need to disconnect from one Ethernet phy and
> > > connect to the other Ethernet PHY when you change external Ethernet
> > > port?
> >=20
> > That's the other way around. The engines outputs (say GoP#) are
> > connected to the comphy inputs. In the SoC. Then there's a single output
> > of this comphy lane to the board. So when switching modes, you do not
> > have to connect to a different Ethernet PHY, it's the same.
>=20
> I think there is a mixup here between generic PHY and Ethernet PHY.
>=20
> When you swap from the copper RJ45 to the fibre SFP, the phylib needs
> to swap from the Copper Ethernet PHY driving the RJ45, to the PHY
> driving the SFP module, which is probably a fixed-phy.

Or on the mcbin the Alaska X 88X3310 which can operate from 10G to 10M.
This PHY changes its interface mode depending on what speed is
negotiated.

> I actually think this is why you have the carrier_on/off calls in the
> link modify callback.

Well, I still do not know if these calls are *really* needed. At least
in our case.

> Imagine phylib is using the copper Ethernet PHY, but the MAC is using
> the SFP port. Somebody pulls out the copper cable, phylib says the
> link is down, turns the carrier off and calls the callback. Not good,
> since your SFP cable is still plugged in...  Ethtool is
> returning/setting stuff in the Copper Ethernet PHY, when in fact you
> intend to be setting SFP settings.

I see what could be the issue but I do not understand one aspect though:
how could we switch from one PHY to another, as there's only one output
between the SoC (and so a given GoP#) and the board. So if a given PHY
can handle multiple modes I see, but in the other case a muxing
somewhere would be needed? Or did I miss something?

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--HB4mHL4PVvkpZAgW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme/KEACgkQXE2LyK3b
vNi11g/9GCquOLPMarCURiQp8un5gscBdI1v7lEFwEgISjCOnw1izjftAFYIQg4j
MA3Pm3rrlT8DeL2cqq9pEOTlWghfYx9boi9Tn65QNTP/qxRH1eGn6v2QVdv6aIQN
5vK+xbnOiH2lDdQo50is1gpIxd6KwQkYQJ7+oXTebB65w2mvsn1IsK/zgEFojZ5y
LBMnIUaau4N0ngQ0Y24ZCfo0+TKnczD/R4XdWU/PL0BSjF8LMR57BYRbEKWsn2vK
edGX6wybdrbpP9AGb60CdBMn86oxN5mjQuC0MFoUqw5hji/pWcnZXmlS2sFLyHlu
PN5PiHVXgU9kgoUPA85883FRFbho35oFmOYXMPdyQRU4+KXJ7n+eFNz/T5d4uoRY
6lSUWa8TYf0V4rmT7Oz0Rmy+bQ78kzni/T0LyF/ANEgGeW04ch+AH04bUb5GUesM
VkzSkxlaBYvBxZxBma6cMY5dEAsbqgJ/dNXhxxNBHCWSGMluhir17lciLS3rQIoX
BY+UnqfOJTJZOeMsD8+o96s6+ovmR+ShZWOMNXnDF7FA28Z0z9773p1kDhvvX531
cMyiWpUeLornpViUSqc2k4EDBx9ohsHyGv6cvdhKhQOtrkISiCWOpk3MR/XkNm4P
GZpA/VAuTE9VIhFPMAEolF4ksoQcU8V3kp5EQtur9HE6/PiE7AM=
=TSex
-----END PGP SIGNATURE-----

--HB4mHL4PVvkpZAgW--
