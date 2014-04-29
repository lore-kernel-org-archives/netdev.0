From: Jan Moskyto Matejka <mq@suse.cz>
Subject: Re: [PATCH] net: via-rhine: fix compiler warning
Date: Tue, 29 Apr 2014 21:47:41 +0200
Message-ID: <20140429194741.GA30899@moskyto.dyndns.org>
References: <1398792971-10379-1-git-send-email-mq@suse.cz>
 <CABjd4Yxj12O7pi2kiqjO+YYU_D=Gdx98yNz6XE4tCX=sL2eYxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Cc: Jan Moskyto Matejka <mq@suse.cz>, Roger Luethi <rl@hellgate.ch>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey Charkov <alchark@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABjd4Yxj12O7pi2kiqjO+YYU_D=Gdx98yNz6XE4tCX=sL2eYxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 29, 2014 at 10:09:01PM +0400, Alexey Charkov wrote:
> 2014-04-29 21:36 GMT+04:00 Jan Moskyto Matejka <mq@suse.cz>:
> > Fixed different size cast warning:
> >
> >         drivers/net/ethernet/via/via-rhine.c: In function =E2=80=98rhin=
e_init_one_platform=E2=80=99:
> >         drivers/net/ethernet/via/via-rhine.c:1132:13: warning: cast fro=
m pointer to integer of different size [-Wpointer-to-int-cast]
> >           revision =3D (u32)match->data;
> >                      ^
>=20
> Looks like the same would apply to e.g. drivers/clk/samsung/clk.c and
> maybe some others... Also, a number of drivers cast OF data from (void
> *) to (int) or (unsigned int) - isn't this also problematic on 64bit?

Some of them are, some not, sometimes nobody knows. If it were up to me,
I would personally put a single comment "this throws a compilation
warning because this and that" at every place where the warning is
thrown and is to be ignored.

So I do fix almost every warning of this kind I come across. Better to
have that fixed than to believe that the warning is harmless (as this
probably really was).

I'm just running a script that checks the tree for new build warnings
and then analysing the script's output ... and sometimes it's worth
fixing, sometimes not.

		Moskyto

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTYAHcAAoJEDFERKcRJ1aplv4P/2vjstPxLRfFCH7js66MNwn3
4WlIglmvH0nMs/MPSLhqikNEeJossnAE0K5eMGMUV3aIPpKIUq5Z+xUVpDN67Nwn
EWI5zzOG7do+9W8uGXlA76a/++jksMk1Pzpi2azKns93JTsTYwDk2/nXmAsgxiKf
u6TRA0SYi3hb5+urmZ7HERuadp8Kc/e+ffzY1JfxJX1c+686RHP02BKbE0iPjOMd
S6Igt0Nl6ZdbMeHD4hZMPKiTOsSGadmQaQnLI0K3bQviMqKEC6W2tsZxOj3KOTu5
gOYtWHvat6cRj+fyueiONDXcNtvwTHfojxdntF/W4NqgCNAemkTrMHaH8aXm52On
i+6E20sgGaAe8QcZsYF8By9eTlhuqONkmuTXGJCXuK/xHlTSJWmxnq58NVvPZbMS
dE1Bzvs7jwJpFAcjWY1G3mImYU50P6K8uxL3qg0JFEhwVfoUqByRCTs/PrT2jiUS
tMs1bynVh4onu5jCfWWYvs0MBMXugDNCPZbk2FWiXjMk/3DTp00qeV8CWhxfeh4O
dCyB1ejnqfRl9WZl2YhMsPUT9oCzYNhUsiKYrBE6dpWDXh+53AIc/H2fZJ2Q4mA5
cxxkvQMCVy9hkVXQvklGIFHYSDV2+NrUypCelaCa9imf1l3TbAUeE6oppAQWU7F2
V/vofrShPxfgt4hGnpRY
=e31A
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--
