From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Tue, 03 May 2005 14:18:22 +0400
Message-ID: <1115115502.3414.22.camel@uganda>
References: <20050429144103.A23268@2ka.mipt.ru>
	 <20050503095312.GA29788@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cJaM2D1YZkDdvae0Sc3H"
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050503095312.GA29788@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-cJaM2D1YZkDdvae0Sc3H
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-05-03 at 19:53 +1000, Herbert Xu wrote:
> On Fri, Apr 29, 2005 at 02:41:03PM +0400, Evgeniy Polyakov wrote:
> >=20
> > I've created POC code to perform asynchronous IPsec [ESP]
> > processing. Please comment about bugs in the following patch.
> > It of course very dirty - but it is only begining,=20
> > I just want to know if approach is right.
> > Patch was tested with several ssh session and some=20
> > traffic like find / and tcpdump over them.
>=20
> IMHO we should ensure that the async code path does not adversely
> impact synchronous crypto performance.  Most users will be using
> synchronous crypto primitives.  Synchronous crypto is also the best
> way to utilise VIA Padlock which is arguably the best hardware crypto
> solution that's available today.

It can be compile option - those people who wants asynchronous crypto
processing and has appropriate hardware will benefit from that even
if theirs general purpose CPU is VIA with PadLock ACE.

It looks like several CPUs can not be used for synchronous crypto
processing in current IPsec implementation. Using asynchronous
mode there might be significant performance win.

> Cheers,
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-cJaM2D1YZkDdvae0Sc3H
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCd0/uIKTPhE+8wY0RAh7xAJ4nA4frpuNJdlP59SNY7U9nsxXkRwCcDlFJ
BZlFh0eFWlwEIevbQHdhnuQ=
=MkCS
-----END PGP SIGNATURE-----

--=-cJaM2D1YZkDdvae0Sc3H--
