From: Harald Welte <laforge@gnumonks.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sun, 19 Sep 2004 09:46:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919074605.GJ6005@sunbeam.de.gnumonks.org>
References: <20040918.084304.75142669.yoshfuji@linux-ipv6.org> <20040918220211.GI6005@sunbeam.de.gnumonks.org> <20040918180647.6be57884.davem@davemloft.net> <20040919.111141.42341294.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUvfsPTz/SzOZDdw"
Cc: davem@davemloft.net, netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040919.111141.42341294.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fUvfsPTz/SzOZDdw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 19, 2004 at 11:11:41AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ w=
rote:
=20
> > On Sun, 19 Sep 2004 00:02:11 +0200
> > Harald Welte <laforge@gnumonks.org> wrote:
> >=20
> > > Now I'm stuck with another issue:  The interfaces suddenly no logner
> > > get any link-local addresses:

> I've run TAHI test on post-rc2 kernel,=20
> and the result is as I expected.
> I haven't met such issues...  hmm...

Apparently this happens when you=20

1) insmod ipv6
2) ifconfig your interfaces up
3) only now ifconfig 'lo' up.

This happened due to a typo in my script :(  If 'lo' exists prior to the
other interfaces, everything seems to work as usual.

Is this desired or accidential and/or documented behaviour?

> --yoshfuji

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--fUvfsPTz/SzOZDdw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBTTk9XaXGVTD0i/8RAvyPAKCqMWPz0lZgNAqmFPrJ+sfaBzZ/AwCcCix/
o57zySwH07my7VMrCrOdNJg=
=VIZ1
-----END PGP SIGNATURE-----

--fUvfsPTz/SzOZDdw--
