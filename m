From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Fri, 20 May 2005 18:15:39 +0400
Message-ID: <1116598539.21310.195.camel@uganda>
References: <20050518222729.007887b8.akpm@osdl.org>
	 <1116484313.21310.78.camel@uganda> <20050518234552.4aef6d02.akpm@osdl.org>
	 <20050519.114425.18307286.davem@davemloft.net>
	 <1116571178.21310.124.camel@uganda>
	 <1116589367.6308.36.camel@localhost.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-i2Fx1frPqQmvuSu7WD7T"
Cc: "David S. Miller" <davem@davemloft.net>, akpm@osdl.org,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1116589367.6308.36.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-i2Fx1frPqQmvuSu7WD7T
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-05-20 at 07:42 -0400, jamal wrote:
> On Fri, 2005-20-05 at 10:39 +0400, Evgeniy Polyakov wrote:
>=20
> > I just want to note, that if you want message bus, you require
> > at least oppsite direction, and thus input callback, and
> > either several socket number for each user [kobject, audit, iscsi,=20
> > xfrm - all they implement what connector already does] or
> > some header and thus parser in input callback, and thus
> > some registration mechanism.=20
>=20
>=20
> But if you are given your own ID, there should no issues, correct?

Yes.

> i.e it will be no different than say rtnetlink. Users would still have
> to subscribe to topics etc, but thats something you already handle.
> IOW, Iam hoping you are not resorting to a single socket with some user
> space mux to do filtering.

Not following, sorry.
Userspace should use the same socket as kernel - my application
previously
obtained it from dmesg and later used ULOG.

> cheers,
> jamal
>=20
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-i2Fx1frPqQmvuSu7WD7T
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjfELIKTPhE+8wY0RAnJ7AKCExzSpBRYLKXojEcJseiXPPvymmwCdHq5c
hH5c9iIcedpGNiJEJ5ZqUCU=
=39jJ
-----END PGP SIGNATURE-----

--=-i2Fx1frPqQmvuSu7WD7T--
