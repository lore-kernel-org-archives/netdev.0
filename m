From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 10:31:53 +0400
Message-ID: <1116484313.21310.78.camel@uganda>
References: <20050518202458.55a63d37.akpm@osdl.org>
	 <E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
	 <20050518222729.007887b8.akpm@osdl.org>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ICESXTcUFlDQU7GFlVId"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050518222729.007887b8.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ICESXTcUFlDQU7GFlVId
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-05-18 at 22:27 -0700, Andrew Morton wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >
> > Andrew Morton <akpm@osdl.org> wrote:
> >  >=20
> >  > This is the second report of this happening.
> >  >=20
> >  > FATAL: Error inserting ipt_ULOG (/lib/modules/2.6.12-rc4-mm1-2/kerne=
l/net/ipv4/netfilter/ipt_ULOG.ko): Cannot allocate memory
>=20
> Ah yes, thanks.  netlink_kernel_create() has a dumbish return-value proto=
col.
>=20
> >  This probably means that someone has stolen the NETLINK_NFLOG id.
>=20
> cn_init() uses NETLINK_NFLOG.  Peculiar.

Yep...
One may use "unit" module parameter to specify different socket.
Should I ask David Miller to allocate new one specially for connector?

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-ICESXTcUFlDQU7GFlVId
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjDLZIKTPhE+8wY0RAtoTAJ4l9jQ5bmP4W8PnE/swxMmw1fFlDACfQBWE
w1ct28hi//kJ3AvOHu7+D3c=
=I6jn
-----END PGP SIGNATURE-----

--=-ICESXTcUFlDQU7GFlVId--
