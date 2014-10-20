From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.4-stable v2] ipv6: reallocate addrconf router for ipv6
 address when lo device up
Date: Mon, 20 Oct 2014 04:14:32 +0100
Message-ID: <1413774872.31953.13.camel@decadent.org.uk>
References: <53E1E4C9.4010006@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lVpNIMKSAmB2QxVqAaxj"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>
To: chenweilong <chenweilong@huawei.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <53E1E4C9.4010006@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lVpNIMKSAmB2QxVqAaxj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-08-06 at 16:18 +0800, chenweilong wrote:
> It fix the bug 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=3D67951
>=20
> The patch can't be applied directly, as it' used the function introduced
> by "commit 94e187c0" ip6_rt_put(), that patch can't be applied directly
> either.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> From: Gao feng <gaofeng@cn.fujitsu.com>
>=20
> commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 upstream.
>=20
> This commit don't have a stable tag, but it fix the bug
> no reply after loopback down-up.It's very worthy to be
> applied to stable 3.4 kernels.
>=20
> The bug is 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=3D67951
[...]

It looks like this is needed for 3.2.y as well, so I've queued it up.
Thanks.

Ben.

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-lVpNIMKSAmB2QxVqAaxj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVER+GOe/yOyVhhEJAQo5MA//ZelSQAv8ThitW2NmBi4JM8CDG+0DHblh
BnXa8BH5O/zSBS+lPUmWGnACUBTnUqgWI1u+vxKaQFc2pqWTyIOyrZwXSrObU4Xs
bDOWEMz9IkNQFRCeGiYvGuU749h8JcF/5eH2cfLUGDaDh9mgb3RCKl/O8p3HG34b
Tyw5hpKqaGBvDZley3PyQRO5ibAjTHQFM87wml5evi5KSCr+wpB5xYmjuVsR0x1K
ECzlciT3kARveE8BhFW6NzPNqqTewse5k5gSnlFbulYbwOFXFHH8jP9/0JKts2kR
BMshKxy25pIBdw5yyFWejUG3lxwjniyC3PG869rTiNdUD5Jv3V6JjwFxq0efm4FV
qUnBAbRtyPfLUnBFrhBjBBx6h1rXkA83C0voZa9iqzy5qA1kN27Ih8mtvD+SPUAZ
tZUi7tE6nbcy29lbAaBncavWI+HFsCF8e4Lxf/CQuneUvJG1viARzri1VycZULXl
DBLadsdJxp9EFLRYKgQ4ooYglqw6h7sO0KqI3lBb4pziXhktXgq9GnvdZKzbd5LU
QTwU33T8X9H8ek1Mz79Bw9P7nT4r+Rpugl5RBch6fYGQTGolYmYkjhriY+XLw3W/
y67ZW/Y3ZoQcfHhMnYcHW/O1n0TVoHwsx4BGWWMIpNSNgBu6O6hMQ/3NCLEV+v2Y
Sa6EVQyC+6w=
=vscU
-----END PGP SIGNATURE-----

--=-lVpNIMKSAmB2QxVqAaxj--
