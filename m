From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [IPv4] Kill remnant of ip_nat_dumb
Date: Thu, 23 Sep 2004 08:19:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923061923.GL3236@sunbeam.de.gnumonks.org>
References: <20040922040155.GA19302@gondor.apana.org.au> <1095855039.1045.67.camel@jzny.localdomain> <20040922110931.68b113a4.davem@davemloft.net> <20040922181433.GH27432@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="suYNV1AwziNMnBoj"
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040922181433.GH27432@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--suYNV1AwziNMnBoj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 22, 2004 at 08:14:33PM +0200, Andi Kleen wrote:
> > It's gone until someone fixes it up into working condition
> > once more.  It's been broken ever since the first bits
> > of IPSEC dst cache infrastructure went in.
>=20
> Also netfilter has a static NAT too these days, so it doesn't=20
> seem to be very useful to have another one.

yes and no.=20

=46rom a functionality point of view: yes. =20

=46rom a performance point of view, there are applications for really dumb
static NAT where you don't want to pull all the dependencies from
ip_conntrack over ip_tables.

> -Andi

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--suYNV1AwziNMnBoj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUmrrXaXGVTD0i/8RAsB3AJ4pbskrLDWWLXYGbVUOwcO21Vi/SQCgigyn
eRZF/QFIUXBkd31eIDHaatU=
=Q/LN
-----END PGP SIGNATURE-----

--suYNV1AwziNMnBoj--
