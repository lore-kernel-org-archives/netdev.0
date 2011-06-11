From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sat, 11 Jun 2011 14:26:48 +1000
Message-ID: <20110611142648.bf71b026.sfr@canb.auug.org.au>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
	<BANLkTi=fn1qxcJGs7Ngag6ph2uMECiyWLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__11_Jun_2011_14_26_48_+1000_1qHZEHXaj31N+mfP"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Alexey Dobriyan <adobriyan@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=fn1qxcJGs7Ngag6ph2uMECiyWLg@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sat__11_Jun_2011_14_26_48_+1000_1qHZEHXaj31N+mfP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Geert,

On Fri, 10 Jun 2011 22:28:03 +0200 Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
>
> On Thu, Jun 9, 2011 at 06:56, Stephen Rothwell <sfr@canb.auug.org.au> wro=
te:
> > I assume that this is fallout from commit a6b7a407865a ("net: remove
> > interrupt.h inclusion from netdevice.h").
>=20
> Ah, that's were the failures on m68k come from:
> http://kisskb.ellerman.id.au/kisskb/buildresult/4222666/
> http://kisskb.ellerman.id.au/kisskb/buildresult/4223000/

Yep.

> My first bisection between two successive versions of linux-next failed, =
but

Bisecting between successive linux-next versions is bound not to work.
Bisection really only works between a commit and one of ist ancestors.

> the second one between linus and linux-next just finished and points
> to that commit.

That is a much better bet.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__11_Jun_2011_14_26_48_+1000_1qHZEHXaj31N+mfP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN8u6IAAoJEDMEi1NhKgbsYj8IAJ34qlOZZKeU8JseUrn9rCjz
LHJaIeP37ro53ead5jRwOSI3YBJtprBYlupFG/FvBd+R+/xojYFo70P2lZRmS/i2
FjhsdZtL32KamWS73gmyqy3AeCqw5h1WvTZxE01E6l/xHQ7+6rwpgqO4g77R5nw4
qRKrwYBuTiZsH/X5+U7Ro1VuwHpMMVarfA/zRkonffTAkZIVn7DrYv6OWucjP1a8
aAFrUi6eL9ixotT6MzeiPvSaF4VGOVnhpqKILMvDt5y27Y/8ck8RVgatfMAWhShH
fMfDvhN6/z+DQZ+QBYiz0B2rSzcoaGA+Klomby13vqUp4H3MfIHJ56EQHIEi81Q=
=SGUd
-----END PGP SIGNATURE-----

--Signature=_Sat__11_Jun_2011_14_26_48_+1000_1qHZEHXaj31N+mfP--
