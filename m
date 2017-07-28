From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 04/18] net: mvpp2: move the mii configuration in
 the ndo_open path
Date: Thu, 27 Jul 2017 18:44:21 -0700
Message-ID: <20170728014421.GB24728@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-5-antoine.tenart@free-electrons.com>
 <20170726161111.GG12049@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="SkvwRMAIpAhPCcCJ"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:33098 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdG1BoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 21:44:25 -0400
Content-Disposition: inline
In-Reply-To: <20170726161111.GG12049@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, Jul 26, 2017 at 06:11:11PM +0200, Andrew Lunn wrote:
> On Mon, Jul 24, 2017 at 03:48:34PM +0200, Antoine Tenart wrote:
> > This moves the mii configuration in the ndo_open path, to allow handling
> > different mii configurations later and to switch between these
> > configurations at runtime.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> > ---
> >  drivers/net/ethernet/marvell/mvpp2.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/etherne=
t/marvell/mvpp2.c
> > index 6ffff929b22a..9d204ffb9b89 100644
> > --- a/drivers/net/ethernet/marvell/mvpp2.c
> > +++ b/drivers/net/ethernet/marvell/mvpp2.c
> > @@ -5862,6 +5862,7 @@ static void mvpp2_start_dev(struct mvpp2_port *po=
rt)
> >  	/* Enable interrupts on all CPUs */
> >  	mvpp2_interrupts_enable(port);
> > =20
> > +	mvpp2_port_mii_set(port);
>=20
> You probably should take a look at mvpp2_port_mii_set() and have it
> handle all PHY_INTERFACE_MODE_RGMII variants.

I'll have a look at these variants (and update the whole series).

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--SkvwRMAIpAhPCcCJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll6lvUACgkQXE2LyK3b
vNhZ3w//b+RC7P6ecMvrhZa68sLQ30GvIXrh+nWw/07FJqJNaVDeFiKbuhNSgyJ6
/QYxQoWNtVPoxM70ohyuQWu+pjOdHYdTXKRydym9PQ+97MXHN7MtTSAQPBZoQFJ2
foSrptJ3prvxvvdJePhr80laTHA6gwNCH0yeT/aS7IGRKiUfYxb0/qPu+el1rlTR
loKqIVzdyQ1xRS1PJawIfBKZvrXSEEbz6aLwzlPpvaBVaGpz0elyoCxqbvMROV7T
64BwEJQroe4Vjx3h6RF0q8nucBLIUEnM/7gzFGmfuvh3l6DIIGKs3p82iIZKQUJy
rtT8gANfqFA57gm4lUb278868sAYZahRajlqaCz+whwGchB3vRXY81kpUnBVeDHV
5XUwu+DdwOI8VGHyLTwYpif8X4bBoKtm5H2PCsXg8yuBuzRQwNgbTz+cXaE6zAqg
YT6/zWy+6VQF0eafx3gn1n7aC6EvRoa9PUhUaENOstzmLEr7+Y3f+1zZfzwQMiXI
lMc7cbW0r4tduTi6CgYHFiW1Bvo5z1WkFG0VUHEcZLhDZkOnxanOEV4GOAKlpdLb
tGpIxdzmzY5Wg/Zhteh1nvg+nog2vBgBNPA6dmgmyZSd1Sb6nGz766tRTDfpoHYZ
DLAX+LGXB54XV/74QHiwhz+pBPweBQIWvCHPwRFhIFq2Whg1gMo=
=R/4p
-----END PGP SIGNATURE-----

--SkvwRMAIpAhPCcCJ--
