From: Harald Welte <laforge@gnumonks.org>
Subject: Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Thu, 14 Oct 2004 12:57:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041014105757.GB12694@obroa-skai.de.gnumonks.org>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org> <E1CI2I2-0001sI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="neYutvxvOLaeuPCA"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CI2I2-0001sI-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--neYutvxvOLaeuPCA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 14, 2004 at 07:52:54PM +1000, Herbert Xu wrote:
> Harald Welte <laforge@gnumonks.org> wrote:
> >=20
> > If I send a GETSA with NLM_F_DUMP message from userspace, I receive a
> > batch of SA messages, but they apparently don't have the F_MULTI flag
> > set.=20
> >=20
> > Aren't they (all but the last msg) supposed to have the usual F_MULTI ?
> > Is this by intention or a mistake?
>=20
> The documentation says so but none of the existing users really care.

Well, people are developing more users, you know ;)  Somebody at
Astaro (http://www.astaro.com/) is investigating the possibilities of SA
synchronization for IPsec HA, and=20

> The doco also says that the DONE message shouldn't have F_MULTI set
> but it does :)

Ok, would you like to receive a patch that fixes the xfrm netlink
interface to be more compatible with the netlink manpage and what
rtnetlink does?

> Cheers,

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--neYutvxvOLaeuPCA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBblu1XaXGVTD0i/8RAg3AAJ0Yb/DU6Ol62rKkwHrGzWYRJ9YefgCeJGS3
lBl83UPypAfrVxEUkKQyABw=
=W7B8
-----END PGP SIGNATURE-----

--neYutvxvOLaeuPCA--
