From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [IPv4] Kill remnant of ip_nat_dumb
Date: Thu, 23 Sep 2004 10:29:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923082955.GP3236@sunbeam.de.gnumonks.org>
References: <20040923061923.GL3236@sunbeam.de.gnumonks.org> <E1CAOil-0005Ot-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2NSZC26AJDpFITwK"
Cc: ak@suse.de, davem@davemloft.net, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CAOil-0005Ot-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--2NSZC26AJDpFITwK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 23, 2004 at 06:12:55PM +1000, Herbert Xu wrote:
> Harald Welte <laforge@gnumonks.org> wrote:
> >=20
> > From a functionality point of view: yes. =20
> >=20
> > From a performance point of view, there are applications for really dumb
> > static NAT where you don't want to pull all the dependencies from
> > ip_conntrack over ip_tables.
>=20
> Well the problem is nobody is stepping forward to fix it.  It was removed
> not because it was redundant, but because it was broken.
>=20
> Until someone actually fixes it, it can't go back in.

I fully understand this, and I support that decision. =20

Independent of this, I just wanted to note that if there was working
and compatible code, it had it's use for high performance static nat
applications.

> Cheers,

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--2NSZC26AJDpFITwK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUomDXaXGVTD0i/8RAiYnAJ4tgZ8Ypj+OBa8QtuKWjp/rr0BTmACgpldR
kGQTXrupEi1I6GBmkXE2sV4=
=yzoq
-----END PGP SIGNATURE-----

--2NSZC26AJDpFITwK--
