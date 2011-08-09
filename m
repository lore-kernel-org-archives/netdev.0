From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 12/12] headers, ppp: Add missing #include to
 <linux/if_ppp.h>
Date: Tue, 09 Aug 2011 13:40:20 +0100
Message-ID: <1312893620.2591.1222.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
	 <1312809919.2591.1152.camel@deadeye>
	 <20110809.002738.679747111943821641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-5kjS+KeVFbeHVfj2rjjM"
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20110809.002738.679747111943821641.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5kjS+KeVFbeHVfj2rjjM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-08-09 at 00:27 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 08 Aug 2011 14:25:19 +0100
>=20
> > <linux/if_ppp.h> uses various types defined in <linux/ppp_defs.h>.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> Unfortunately there is a "net/if_ppp.h" provided by glibc that
> includes "net/ppp_defs.h", and all of this is presumably in order
> to discourage direct use of the kernel headers.
>=20
> Even though net/ppp_defs.h ends up including linux/ppp_defs.h
> anyways.
>=20
> Whilst I think your efforts are to be commended, we can't start doing
> or else we'll start breaking the build in various unexpected ways.
>=20
> The SIOCDEVPRIVATE (defined by GLIBC in bits/ioctls.h) case is just
> one such example.

I did try to check for these cases, but obviously missed some.  I'll
re-post the series without these ones.

In the longer term I would really like to solve this mess somehow.
glibc is obviously duplicating a lot of definitions in different headers
(but tends to lag behind a little) and other C libraries may also have
to duplicate that work for compatibility.  Some kernel headers already
*do* include headers such as <linux/if.h> that can conflict with C
library headers, sometimes requiring userland to work around the
conflict somehow.

Ben.


--=-5kjS+KeVFbeHVfj2rjjM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATkEqtOe/yOyVhhEJAQq8qA/7Ba+KIB0tKdbdOpDPrPFhwNn2AF1mb9OM
yGRZnjrmeMUuqBeWeWVDiT6ps2LYofCQw4dRJnteSTfO6RmGQgifOUVz7k6HjZpz
HDmT3uSZBgbRsZeXWfnrgheyYKWc2kQPu/wGh3zUZH4gYptLkYjrol49PI6b6vw8
pM/rFP55tTIj15RMGMhm6I9pJ951pnyfbnXvgjX0jMUa+HA/fMkRSXx6Zku+iu7O
cF0GbHsr6HBjSvK2Q6A9qLorntIaIGIgH197UOWObL63d7XjchmF4fSsGUZlki8a
kZL8SSTJ3QVJU1mEHizaObg4nQ4gXly0E/mwj2GdXHqE4pgHpePbrxws/dqY/ibd
UiWA3RdQaU0Mk4TcGa9ZHpj/y0SsDgxKlo6DJZl5IDxw0QMexUwxC2/uIfbcYerI
xtfxheNVXo2VHf4VRP6VgkJxS2x/lFYl/RCMnLuI3KQxnXMwquNp2TSniQlyFQ3g
ITs2XrJ38V+Do3uOw4555tg3/hpeZblNcxKwDHLdN0VWRouvYWRERCFihv5JlvIO
rjQ6UrURSZtNG/Y3++5FvYoM+a5JTetL/Ipn/g2+UWDZru7K/DpqMxHibSJap5Ek
g8xFpfiahdrvvh7SGZh2uKI1ctrH36di3aFuZWIxe7eX+gs5j6TDmrdj2Oy3DE76
1iMx+63s8Ao=
=/6m1
-----END PGP SIGNATURE-----

--=-5kjS+KeVFbeHVfj2rjjM--
