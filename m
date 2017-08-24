From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [EXT] Re: [PATCH net-next 09/13] net: mvpp2: dynamic
 reconfiguration of the PHY mode
Date: Thu, 24 Aug 2017 19:14:18 +0200
Message-ID: <20170824171418.GI28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch>
 <20170824161945.GG28443@kwain>
 <de67e234a7ff43b49346be5cea2466eb@IL-EXCH01.marvell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="0XMZdl/q8hSSmFeD"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kishon@ti.com" <kishon@ti.com>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "miquel.raynal@free-electrons.com" <miquel.raynal@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Chulski <stefanc@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <de67e234a7ff43b49346be5cea2466eb@IL-EXCH01.marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0XMZdl/q8hSSmFeD
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 24, 2017 at 05:08:29PM +0000, Stefan Chulski wrote:
> > > Imagine phylib is using the copper Ethernet PHY, but the MAC is using
> > > the SFP port. Somebody pulls out the copper cable, phylib says the
> > > link is down, turns the carrier off and calls the callback. Not good,
> > > since your SFP cable is still plugged in...  Ethtool is
> > > returning/setting stuff in the Copper Ethernet PHY, when in fact you
> > > intend to be setting SFP settings.
> >=20
> > I see what could be the issue but I do not understand one aspect though:
> > how could we switch from one PHY to another, as there's only one output
> > between the SoC (and so a given GoP#) and the board. So if a given PHY =
can
> > handle multiple modes I see, but in the other case a muxing somewhere w=
ould
> > be needed? Or did I miss something?
>=20
> I think PHY name and PHY mode struct that describe here both MAC to
> PHY and PHY to PHY connection create confusion...  Serdes IP lane
> doesn't care if connector is SFP, RJ45 or direct attached cable.
> mvpp22_comphy_init only configures MAC to PHY
> connection. SFI for 10G(KR in mainline), SGMII for 1G and HS_SGMII for
> 2.5G.

So maybe one confusion was to name them PHY_MODE_10GKR and
PHY_MODE_SGMII. It could be PHY_MODE_10G and PHY_MODE_1G instead.

Does that sound right?

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--0XMZdl/q8hSSmFeD
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmfCWoACgkQXE2LyK3b
vNiCbQ/+PTXnQ01f58PYDYlE7WkTrrt8KH+Tk+R6xCgmIuaQ7CwYAPo8ETUjOtQ9
Z/o6ttChcUXjEgEGFJRKE0J2frf7C9W/0hwznGw4t3UGzaTk3kwCabo0dwetlgHH
HjaF+CQ4YblvpxH/8zW78bBgTE/sxRh6fq2zAKib62V62a9NmlY8GUq3SnHUz687
3IrMnOxJFLyPfkz+/i6PEzNSGiIcELIHwtRv1P+27bYVE6UitRHgSnGn+hw0a70I
9spzbDDVKuYS/tYTEB59juD+4WqCuLAelWdUB4d9KKG8LgPTXudNkMh/BdyFh0QH
S+AK9ND85W7aH7vdOZbDnxW0nYMRaOukHKi0GTvDj+4dGCarVFG4tfz62umeLnNo
YrMTotDCIMXs2gVQHwJebikjEfdMAfakwpANA8YiMIZj4D0KoWWhQxZ/OM4TV6if
V7pCcf4622c+VmswlBoBeD7OLEuxqqx45QlJJLHCIYB4mirTO0dUWc7s0H8VTWdt
artoduV6EHCqYmu7UCYFhp4/XcrMMVpCC0USlskbFdX783TkTddx1h+p7uuJByi3
Y4zJ3S67lIm6ki23uc1dTJtYp1Ph1v/7qPbLCVcizegwUhTxhOzVpHIpxBC0EcI3
K6ICEvdur33EUU+iXgdlbN38aAIBworqc49Y5nDOH6vNwrqYEBM=
=1Gnc
-----END PGP SIGNATURE-----

--0XMZdl/q8hSSmFeD--
