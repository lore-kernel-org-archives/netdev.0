From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net 2/3] llc2: Call llc_station_exit() on llc2_init()
 failure path
Date: Wed, 15 Aug 2012 05:06:33 +0100
Message-ID: <1345003593.824.212.camel@deadeye.wl.decadent.org.uk>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
	 <1344862243.824.141.camel@deadeye.wl.decadent.org.uk>
	 <20120814.165223.953955272458502981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UxLcgIHDzPIU8bgFPirW"
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55491 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058Ab2HOEGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 00:06:46 -0400
In-Reply-To: <20120814.165223.953955272458502981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UxLcgIHDzPIU8bgFPirW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-08-14 at 16:52 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 13 Aug 2012 13:50:43 +0100
>=20
> > Otherwise the station packet handler will remain registered even though
> > the module is unloaded.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> This will cause section mismatch errors, you'll need to remove
> the __exit tag from llc_station_exit() if you want to start
> invoking it from llc2_init() which is __init.
>=20
> I took care of this when applying this patch to 'net'.

Thanks, David.

llc_station.c turns out to be mostly dead code, and I have some more
radical changes to remove that which I'll send after you next merge net
into net-next.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-UxLcgIHDzPIU8bgFPirW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUCsgSee/yOyVhhEJAQrrVg/+MsGbwG4wx42KqG43T9F48GxxNUJgUwmp
skujK5kcyUyzglqN7+SG3AOPPBtJ1ExqE8Da5OlewWmz35L0+EgDMVfccDSMGe1G
/W1Rh4ax4jw/dLUOmiV10W4cRXADKL+QyYHx7VilXsGPHy1DMVaHaNI66zRQFtDu
Q+DdHi4uBhfLsy+ySceGU3DwkMZKuLQKBsKLuf2b5Mm7pH2MPY9Cd45i7WmBOizl
3TnfxOAVeLg++HVjYXnL6xX2ZHV4W+6O4xoPuDQtkgwWZIuNXCSbxWIFVO2GEfic
Y27sxOm1LyNR6uXWmHZfo9fnRJK3LytKxoYVK+iLoOZ3lW5+uGi1H6iwx0Hogugc
kgX4ec6IBcI2YnppsMs+zcAa1y6Y0UzvLb+MioTXiUrv4ydW3NGdUPrC1WX6/95h
nWugWLHqvhQUr+UalXF4SSYskxtkydBPAe7Su8Mvo2acg9pds+Rwij4XPAqknt+k
VL5ONqSQ1VazviBspq8hh6QqUfcM0SFOD7mk2KNuWmG7yJPUyEGS5IGgqC78eDCq
CYLUwUr81mJwmJJVLeYTnbPlXIY1Ufh3UihXi2uFY9T2a3b1zEqh7NcDAmEWnQkw
XlAKSF1o4zcpNuL05czz+dXxOI5zBwQ6lbFdGYazZlvAkeVYR9yJGAxVfuWO5tcr
yuFBSzAbcM8=
=rKVf
-----END PGP SIGNATURE-----

--=-UxLcgIHDzPIU8bgFPirW--
