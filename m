From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 11:27:19 +0400
Message-ID: <1116487639.21310.88.camel@uganda>
References: <20050518202458.55a63d37.akpm@osdl.org>
	 <E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
	 <20050518222729.007887b8.akpm@osdl.org> <1116484313.21310.78.camel@uganda>
	 <20050518234552.4aef6d02.akpm@osdl.org> <1116486385.21310.82.camel@uganda>
	 <20050519000809.2fca25c5.akpm@osdl.org>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CV9ty3Lp1Q6YbSHBcdSO"
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050519000809.2fca25c5.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-CV9ty3Lp1Q6YbSHBcdSO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2005-05-19 at 00:08 -0700, Andrew Morton wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >
> >  > Is there any reason for being able to do that?
> >=20
> >  It was created to be able to load several different connector devices=20
> >  from different modules [basically it was module1.ko unit=3D10, module2=
.ko
> >  unit=3D11 and so on].
>=20
> Loading multiple instances of the same module so that we get multiple
> instances of its data structures?   That's fairly ghastly.

It was not the same module.
it was quite different module which implemented similar functionality
and used different connector device for different purposes.

> We should remove the feature.  If there is demonstrated need for multiple
> instances then it should be done by more conventional means - syscall,
> allocation of a device major then use the minor as a selector or whatever=
.

It is easy to use feature which prevents problems
with situation when the same socket number is used, for example,=20
in 2.6 kernel while connector uses it in -mm tree.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-CV9ty3Lp1Q6YbSHBcdSO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjD/XIKTPhE+8wY0RAh4XAJ90TtaLiPqeGxRP9Ws07iFCjdelOgCfXc1I
lFNcqe0utj+bAkrNZ9QAEvU=
=qYwd
-----END PGP SIGNATURE-----

--=-CV9ty3Lp1Q6YbSHBcdSO--
