From: Daniel Stone <daniel@fooishbar.org>
Subject: Re: net/ipv4/route.c GC patch: is this insane?
Date: Tue, 1 Jun 2004 00:08:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531140801.GS24955@fooishbar.org>
References: <20040530151434.GE24955@fooishbar.org> <16571.9006.703294.10134@robur.slu.se> <20040531122608.GR24955@fooishbar.org> <16571.10357.391130.128260@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9+VnUxDxRuy97YQ+"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16571.10357.391130.128260@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--9+VnUxDxRuy97YQ+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 31, 2004 at 02:43:33PM +0200, Robert Olsson wrote:
> Daniel Stone writes:
>  > gc_min_interval was zero - should this increase, or what?.
>=20
>  If I remember correctly this was an artifact when used by /proc. Try to=
=20
>  set this value via source and avoid /proc for this. In 2.6 it's somethin=
g=20
>  like:
>=20
>  int ip_rt_gc_min_interval	=3D HZ / 2;

This appears to already be the case, in 2.4.23's net/ipv4/route.c, at
any rate.

--=20
Daniel Stone                                              <daniel@fooishbar=
=2Eorg>
"The programs are documented fully by _The Rise and Fall of a Fooish Bar_,
available by the Info system." -- debian/manpage.sgml.ex, dh_make template

--9+VnUxDxRuy97YQ+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAuzxBcPClnTztfv0RAl33AJ0c/opKTGdy+brp3ZVKkqLT9Wd6yACghk21
4JKh15h3UYvk6hDPewPl3Bk=
=VjnG
-----END PGP SIGNATURE-----

--9+VnUxDxRuy97YQ+--
