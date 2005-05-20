From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Fri, 20 May 2005 10:27:54 +0400
Message-ID: <1116570474.21310.111.camel@uganda>
References: <1116484313.21310.78.camel@uganda>
	 <20050518234552.4aef6d02.akpm@osdl.org> <1116486385.21310.82.camel@uganda>
	 <20050519.114241.59656850.davem@davemloft.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-stMio8AyzMq4b+SiqS1d"
Cc: akpm@osdl.org, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.114241.59656850.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-stMio8AyzMq4b+SiqS1d
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2005-05-19 at 11:42 -0700, David S. Miller wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 19 May 2005 11:06:25 +0400
>=20
> > It was created to be able to load several different connector devices=20
> > from different modules [basically it was module1.ko unit=3D10, module2.=
ko
> > unit=3D11 and so on].
>=20
> That's bogus, each connector will need to allocate it's own
> specific define in the netlink header, and we're about to
> run out of numbers.
>=20
> Please redesign the connector so that it doesn't eat more than
> one netlink number, we're running out of them soon.

It does not require more than one socket number.
It just can use any other number provided.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-stMio8AyzMq4b+SiqS1d
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjYNqIKTPhE+8wY0RAqqUAJ0Zaq1bPV2Yhq+q8j+BGARTzkRGwgCfU3u6
w91/eJHszFrKga0UUxX8qHQ=
=+ghe
-----END PGP SIGNATURE-----

--=-stMio8AyzMq4b+SiqS1d--
