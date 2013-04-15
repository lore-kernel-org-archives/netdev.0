From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Mon, 15 Apr 2013 04:07:14 +0100
Message-ID: <1365995234.3566.17.camel@deadeye.wl.decadent.org.uk>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
	 <20130411165303.GI28693@titan.lakedaemon.net>
	 <20130413172126.6cca0809@skate>
	 <20130413190037.GY28693@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6NDU4xR1TkIWMLJgzvxg"
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <florian@openwrt.org>, davem@davemloft.net,
	moinejf@free.fr, andrew@lunn.ch, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
	grant.likely@secretlab.ca, jogo@openwrt.org,
	buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47501 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934105Ab3DODHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 23:07:32 -0400
In-Reply-To: <20130413190037.GY28693@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6NDU4xR1TkIWMLJgzvxg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-04-13 at 15:00 -0400, Jason Cooper wrote:
> On Sat, Apr 13, 2013 at 05:21:26PM +0200, Thomas Petazzoni wrote:
> > Dear Jason Cooper,
> >=20
> > On Thu, 11 Apr 2013 12:53:03 -0400, Jason Cooper wrote:
> >=20
> > > With this and Thomas' pci series, we will have Kirkwood fully
> > > converted to devicetree, can begin removing board files, and finally
> > > begin migrating everything over to mach-mvebu/.  This will lead to
> > > the removal of five directories under arch/arm/ (plat-orion,
> > > mach-kirkwood, mach-orion5x, mach-dove, and mach-mv78xx0).
> >=20
> > No, we can't remove mach-orion5x and mach-mv78xx0 for now, they have
> > not been converted at all in terms of gpio/pinmux support. I've started
> > writing some pinmux code for orion5x but it's not ready.
[...]
> Also, I have a feeling that not all legacy boards will get converted
> over.  If there is no interest or no way to test, certains boards may
> get deprecated.

Debian supports many Kirkwood and Orion 5x systems.  A call for testing
on the debian-arm@lists.debian.org list might be worthwhile.

I would be very glad to see kirkwood, orion5x and mv78xx0 merged - we
build natively and this takes about 8 hours for each configuration.

Ben.

--=20
Ben Hutchings
The first rule of tautology club is the first rule of tautology club.

--=-6NDU4xR1TkIWMLJgzvxg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUWtu4ue/yOyVhhEJAQoDvw/+IGtHDqlsc21Jwrd/xDsIMew/Ie13LdLl
+9ZxrigtCBJW4yqbouqcC2lq+WEVW8kjA0mj+oKnl/WJ5umckx63fThH6EcapFLb
VurNa9OCZOu7ODXoVa+BfN82NcMPdokP6rLGAOYzeoxXMu0VVKObjNx+neA2preW
PSoO5fffNMQ6ImfRuI26+ju6/R62Xuwa9G3366q2aALqzF/dTnxK9vHwbbMbCnQA
sptDrVnpdYXgL2LNj6M9GZ0aBtP+pnOMnFR92EAQ2t/87BEv8Aydx/K+DEumpbE0
CWJpf1qrz4Z18vbZYxGaRNcxEx6LqIbqeLmRnEbLdI9uOEQ4AJQ2S2R1N9uWVzO5
IpSwcjoRqYrF00n/pLCtwNTfTSWyNgHILWwPlkoQGjA6jb9LNmrT5XGZqaMqItHU
SdVV/M5pTJ2/Rvv9s2PTgPS7CaYYiQSTfcdftj9vCBAviBXxEFCe0QtBkDTKLC8W
bs8wATqPF3dRPxIYm0qPs9LO6wns7nhJq0dRMcQD5jB7eiFYJxcONQ9squvCwRjR
G5K3EmHexJaCE5x0usKrdn95HSbKC/1ZQt7hsa4SZROlCjiNqiokg4GEFhGLz5Oj
LYFuSc/mN8v6so0amKFueXiGvm2fvJ7FtI56MOMm2S3LuT4yEUW14dLjo835QT0y
CfBHqd+sN44=
=kgFk
-----END PGP SIGNATURE-----

--=-6NDU4xR1TkIWMLJgzvxg--
