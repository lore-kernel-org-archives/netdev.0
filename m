From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 11:29:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927092933.GG3236@sunbeam.de.gnumonks.org>
References: <20040923225158.23c2d502.davem@davemloft.net> <20040924085234.GE3236@sunbeam.de.gnumonks.org> <20040924142702.62a2b23d.davem@davemloft.net> <20040925064406.GL3236@sunbeam.de.gnumonks.org> <20040925005623.2faf8faf.davem@davemloft.net> <20040925090933.GU3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OKO3D2de3c6Y4EaB"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040925090933.GU3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OKO3D2de3c6Y4EaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 25, 2004 at 11:09:33AM +0200, Harald Welte wrote:

> Please note that I guess I won't have any results until late Sunday/Monda=
y.

Ok, there you go.  I've tested a kernel with your 6-patch-set for
cleanup/jenkins/..., and the four patch set, including

> > 4) The controversial/RFC patch, dorking with neigh_forced_gc()

It performed perfectly, I wasn't able to reproduce those overflows
anymore (testing with two /16 networks and about 200kpps incoming
packets to unresolved and non-existant neighbours)

> I'll do tests with and without INCOMPLETE check. No results until late
> Sunday/Monday, as indicated above.

I didn't even bother doing the INCOMPLETE check since Yoshifuji
indicated that this caused problems with IPv6.... and it already works
for me while the INCOMPLETE check is still in place.  If you still want
me to run it, I'll give it a go.

Please also note my next mail, where I'll publish some neighbour cache
statistics similar to rt_cache_stat

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--OKO3D2de3c6Y4EaB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBV919XaXGVTD0i/8RAjUaAJ902dTXDxsoJETdqJF43z45IYinZACfczio
flsJxYBHx9TXL696lCZf4zc=
=f7ND
-----END PGP SIGNATURE-----

--OKO3D2de3c6Y4EaB--
