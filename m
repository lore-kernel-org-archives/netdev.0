From: Harald Welte <laforge@gnumonks.org>
Subject: Re: "dst cache overflow"
Date: Wed, 22 Sep 2004 03:20:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922012011.GL3236@sunbeam.de.gnumonks.org>
References: <200409201907.43317.cd@cdaniel.de> <4150B00C.7010305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n1iI6MeELQa9IOaF"
Cc: Christian Daniel <cd@cdaniel.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4150B00C.7010305@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--n1iI6MeELQa9IOaF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 22, 2004 at 12:49:48AM +0200, Patrick McHardy wrote:
> Christian Daniel wrote:
>=20
> >Hello everybody,
> >
> >I'm running Linux 2.6.8.1+pom20040621+imq+... as a firewall and router o=
n=20
> >a 2MBit/s leased line to our ISP. After about 24 hours I get loads of "d=
st=20
> >cache overflow" messages and extreme packet loss occurs on all routed=20
> >connections - bridges continue to work.
>=20
> Have you tried without imq ?

as stated in my other mail, imq is actually patched in the source, but
not used on the running system.  Since no imq code is executed, and I
cannot see any place where imq changes core networking code, I doubt it
has any relation to this problem.

> Regards
> Patrick

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--n1iI6MeELQa9IOaF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUNNLXaXGVTD0i/8RAvEAAJ9i5CQpoe9qsDfKVSIcBFWm2x03XwCeIQCw
AjcE0BqJ0WoVnzFmrvUXgKE=
=kxzE
-----END PGP SIGNATURE-----

--n1iI6MeELQa9IOaF--
