From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: on bnx2x firmware...
Date: Wed, 02 Nov 2011 04:36:54 +0000
Message-ID: <1320208614.3079.5.camel@deadeye>
References: <CAHo-OowF1LNmL0P_Rt=oKmhZMt=CVaVsAYkh_XqVJEOzBPXV7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FVwH6U6a2uUhzz3rQQhW"
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54594 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750781Ab1KBEhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 00:37:14 -0400
In-Reply-To: <CAHo-OowF1LNmL0P_Rt=oKmhZMt=CVaVsAYkh_XqVJEOzBPXV7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FVwH6U6a2uUhzz3rQQhW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-11-01 at 18:01 -0700, Maciej =C5=BBenczykowski wrote:
> ((v3.1))$ cat drivers/net/bnx2x/bnx2x_hsi.h | egrep BCM_5710_FW_
>=20
> #define BCM_5710_FW_MAJOR_VERSION                       7
> #define BCM_5710_FW_MINOR_VERSION                       0
> #define BCM_5710_FW_REVISION_VERSION            23
> #define BCM_5710_FW_ENGINEERING_VERSION         0
>=20
> So the desired firmware is version 7.0.23.0
>=20
> ((v3.1))$ find | egrep bnx2x | egrep fw
> ./firmware/bnx2x/bnx2x-e1-6.2.9.0.fw.ihex
> ./firmware/bnx2x/bnx2x-e2-6.2.9.0.fw.ihex
> ./firmware/bnx2x/bnx2x-e1h-6.2.9.0.fw.ihex
> ./drivers/net/bnx2x/bnx2x_fw_defs.h
> ./drivers/net/bnx2x/bnx2x_fw_file_hdr.h
>=20
> So it doesn't look like the in-tree fw matches the bnx2x driver in
> released v3.1.
> I can find this firmware in the firmware repository.
[...]

That's where it belongs.  But there is some confusion/disagreement on
this point.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.

--=-FVwH6U6a2uUhzz3rQQhW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATrDI5ue/yOyVhhEJAQqaSg/+LlCkJZ8BH8VPynWRda8dYAR3OCCLcaku
g/uPwOwOxtrTlIFK56isIE/L1CmdbN1luyqaCfoREIeiUDDbECCdQRJlU8fPiMRq
gY0bAamkOfjGY9UqgLWuMwKt69TYX4cwft5fujDRwqVql+/RgrZYCKrQNMosll6W
qpXKCuUZw00C6qK+khwxbkGo8joTrvZiU/3Lfm2DuQfV8Xlh37oiTGPVEc5HZGUf
taupA797ieH+4W2uGlD37bHSZ7hDEVjnpsdZ+BFFLY7kc62VBc2kSAACp3a6bAvi
uqJnBhE1n0uoYJqJoHb2K1TDQDGxrmK+D/ajJBYKIN2SLKBZybZ2dBl6Sjw1zej+
ZtzcQfWgXy9Bjfj1ydrsQ01pxTjMCSM63BaVY3KRWBuECVeazvyx17jyG8P9T848
LPtQGY1ivc1q2Zh7Ogrz3b0a4MNST0mcEQT8nwSX74cUVh0JZ1ypiyKQiuadmsyh
5k0iSZ+M/VdZHkiX+BIXDsqQyEkOTw71J7gvL0P2ePmWbfdB6TGLFgQEjWKkK8bB
z1SjISBGURvKeATPY4jnMhNr8dRqomItD4HIXRA8mHGlyKi9wQc05+QqAx63Kbcy
yB7IQ0L4QpkmQZLQPA423KKA8ndp0khl/0X2qcmjaeGJXdGgT+R/njzUs4LslPVu
46m1jc1lay8=
=mMgE
-----END PGP SIGNATURE-----

--=-FVwH6U6a2uUhzz3rQQhW--
