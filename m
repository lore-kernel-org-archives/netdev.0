From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 08:44:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925064406.GL3236@sunbeam.de.gnumonks.org>
References: <20040923225158.23c2d502.davem@davemloft.net> <20040924085234.GE3236@sunbeam.de.gnumonks.org> <20040924142702.62a2b23d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cjNfFEtZoUGcCUIb"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924142702.62a2b23d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--cjNfFEtZoUGcCUIb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 24, 2004 at 02:27:02PM -0700, David S. Miller wrote:
> I've combined all of your thoughts into the patch below.
> We set the initial ARP table very small (2 chains), and we
> regenerate the random seed every time we grow the hash table.

Thanks, Dave.

> This should address all of your concerns.

Indeed, it does. This basically means I am very happy with your overall
patchset.  I'll inclue it in my next round of kernel builds and give it
some testing.  Do you still want to push this for 2.6.9?

I think I'll defer the 2.4.x backport until we've sorted out the one
remaining 'starvation due to incomplete' issue.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--cjNfFEtZoUGcCUIb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBVRO2XaXGVTD0i/8RAt/IAJ9Zn2qj0FVYffFVXyoBwLZYU2r4+ACfT6HB
DVrGCbT3SIzFyPHPWlbBrXA=
=F9JE
-----END PGP SIGNATURE-----

--cjNfFEtZoUGcCUIb--
