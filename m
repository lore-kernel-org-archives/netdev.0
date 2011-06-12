From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: 3c503: fix broken IRQ autoprobing
Date: Sun, 12 Jun 2011 17:45:11 -0400
Message-ID: <1307915111.22348.652.camel@localhost>
References: <201106122140.51776.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-Nnol0GArL/oi4DLNZSuE"
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39163 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369Ab1FLVp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 17:45:26 -0400
In-Reply-To: <201106122140.51776.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Nnol0GArL/oi4DLNZSuE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-06-12 at 21:40 +0200, Ondrej Zary wrote:
> Fix broken IRQ autoprobing in 3c503 driver:
>  - improper IRQ freeing (does not free IRQs causes WARN)
>  - missing break when an working IRQ is found
>=20
> The driver works with this patch.

I made a previous attempt to fix autoprobing (commit
b0cf4dfb7cd21556efd9a6a67edcba0840b4d98d), but didn't have any hardware
to test on.  In the process I introduced these new bugs.  Sorry about
that.

> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
[...]
Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-Nnol0GArL/oi4DLNZSuE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATfUzZue/yOyVhhEJAQr+Lg//RdyXldL1SfWOCI9OntaqD48zxirnEksW
9Rdl7gc2o6FbwVMYXVfyjEII2y6jxIcNEat/ZH6XPhxGn9p+JUBbqLIQjkLlxYow
EkLdIWEVDmklR0LfokTlVjyQrLA04Gi2otKpTu5UoGJVJGqYxEbrWaZR/Y+e5AgP
ytZK66ii5T8HT1LwOaB7BM8dQRlNNICLxdgZ/Br6OOFzVywDIw4Uj99Ojgb5Qt9d
6Sa0R0S+v8I/l3t26WY9nkTJaK0vqoteejO0D5SYvhuT80fjo06Bx/PPpzyzEzcd
p4P2Mh0PBbyfZkiRSeGViZBqDodXR8MSEETHZ7wKp1nCujLSwQ2OXoKe6bc83GP/
NXnZbzIVOJ7FMjW37nJx3rF8dAy/BytwSOruRxAWGK3HY2eLg74zbVoef3eBbxVd
jmAjmUcPOw5PPz22DWXvqjiVZAgcYeM2A9tyS8/GzxxJK+80uYPA6JfcEddsNw7p
oCuNXFUKzNAFULrm4UzLcCzGvutUxppJZf0GMqj8Z06sUp+Vp9IRhN82NphWFbz7
IbHrnJ/MGPeELdYmz1DqemeY1kgd57byu4xjKy823TEA10rF+wkPvtmCowgOVJJo
2kyX4+UQNV4Bu8qYl45nG63oL8Lb3NvHg/RU0z6knLqtybRctHPLiangZ/7nizKc
8+QpP/qWfQw=
=wcJ+
-----END PGP SIGNATURE-----

--=-Nnol0GArL/oi4DLNZSuE--
