From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.2] ipv6: don't set DST_NOCOUNT for remotely added
 routes
Date: Mon, 14 Apr 2014 00:49:38 +0100
Message-ID: <1397432978.10849.92.camel@deadeye.wl.decadent.org.uk>
References: <20140410.215420.576903689381200176.davem@davemloft.net>
	 <1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
	 <1397430142.10849.91.camel@deadeye.wl.decadent.org.uk>
	 <20140413.191948.1913975381773497028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1Dz3PvXhJke9WIpXGncJ"
Cc: stable@vger.kernel.org, sd@queasysnail.net,
	hannes@stressinduktion.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140413.191948.1913975381773497028.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1Dz3PvXhJke9WIpXGncJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-04-13 at 19:19 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 14 Apr 2014 00:02:22 +0100
>=20
> > From: Sabrina Dubroca <sd@queasysnail.net>
> >=20
> > commit c88507fbad8055297c1d1e21e599f46960cbee39 upstream.
> >=20
> > DST_NOCOUNT should only be used if an authorized user adds routes
> > locally. In case of routes which are added on behalf of router
> > advertisments this flag must not get used as it allows an unlimited
> > number of routes getting added remotely.
> >=20
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > [bwh: Backported to 3.2: adjust context]
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > ---
> > This is untested, but looks almost identical to what you sent for 3.4.
> > Please ack/nak.
>=20
> This looks good to me:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, I've queued this up now.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-1Dz3PvXhJke9WIpXGncJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU0sik+e/yOyVhhEJAQqRhw//aZ2MH+1xqEi7KSU+ZYMESl7AfSDrepUy
QYv8e7QEWiHUGcW7TI8Twd9+OkoZhW628VNjSruxSFpXv1VXMi/02rtiQJffIMy7
/vFYOosI95uXt9HobfxkPCxenGTdOftW92tV3BT1McTKfhHewuzkx/eQwtS3T3j7
Hqw9E/Eh8bSvLelMefpmmM2FsviNEtLaRMh3mJcnvbkCC84URWSER4B1e8EJU7x8
P86tcwHI4a9D1ZU3bra/EC0T7r2MmVYKsdkm6/ICZCC+Y+R3u18MKRnSCcsk3tka
SasTC3CNT4MZYV//3p2ZWqGIE9zeyMkJJuH36DtOpYU5EmNL0+/YJKrJrKH8YWML
tU2c0jum0T3svy5sh+ypaAOhJxsIAgAuWMgIzTkp1pZn4VEY6+kthyN1Dj/3qosJ
ldODBe7BCvfIYaAcYVNAo9brpBrp83td13k0L7zBYGGuTqQ9j0xUzbTAwJiSbTb4
5DFmgHzIHDRIoRsie5FcFmxdjdk5xP2ozUhp10pdTQX/c372xcyoAdXVBntlaTAO
Ns6KxeAkZxFRxE7+RBpV0qE7c9Z4WMSxLch3zJhqRin+C5eyHsNwgoyhN86HYfZ2
scQwFb2HFYdC8SWkJuDA5sLZED5B1+/zk18inANpDZtw8gu21QMR7pQj7ehpLU0I
LrtPc2kJqMw=
=c4FG
-----END PGP SIGNATURE-----

--=-1Dz3PvXhJke9WIpXGncJ--
