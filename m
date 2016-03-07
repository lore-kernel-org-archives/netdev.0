From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 09/12] internal.h: fix build for latest
 ethtool-copy.h
Date: Mon, 07 Mar 2016 16:11:28 +0000
Message-ID: <1457367088.15205.28.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-10-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3tn4PqQtHdqprGe94c05"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43729 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbcCGQLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:11:35 -0500
In-Reply-To: <1457138533-2417-10-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3tn4PqQtHdqprGe94c05
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0internal.h | 4 +++-
> =C2=A01 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/internal.h b/internal.h
> index 5f8504d..5df8124 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -13,6 +13,7 @@
> =C2=A0#ifdef HAVE_CONFIG_H
> =C2=A0#include "ethtool-config.h"
> =C2=A0#endif
> +#include=20
> =C2=A0#include=20
> =C2=A0#include=20
> =C2=A0#include=20
> @@ -36,6 +37,8 @@ typedef uint16_t u16;
> =C2=A0typedef uint8_t u8;
> =C2=A0typedef int32_t s32;
> =C2=A0
> +#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
> +
[...]

This needs to be fixed in the kernel tree instead (and has been since
you posted this).

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-3tn4PqQtHdqprGe94c05
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3agwAAoJEOe/yOyVhhEJQ4AQAMXLdq1wo/qRk97Z21XM3EsG
QYAxnQwqY/dNYep61gISP7yPO9P7Orika5Up1EPtL7L8Ht+yXPhAHGZvbsR6iLrc
NH+qGc08hLjacCzeJRgh2EWkyYWjx/vfHSAPobdp4wgyJZHx8d8y+fStPjqp8PV2
A4cZAx8oVumQ6pwSZXRVOBxWX8tlfRLtsR6ChvolJCFnGC0FcJ9TaR2d3oKWzcpW
9OOqGQWQ75PbtZHujEBgl4ObGOgBTuwhj5GpM0GxrLbC7fqAX9bC/OjxEmr7BVdR
fIB7qn2ZuflroLyn7XF2NLtNR7rhdvI/k0laHEsuL2mKeXOhuGl/QbXPUM8BKI+u
rloibvfPReFCsdHl2cyWe8oDPJwq1LQ6gnVAFA8/xgyV2TVZJUb9IPpBuYOE4kxc
Msai0W2/7qoxmKPz+4hmjn5tPC7PMQED/60qIWL+p9HKxm/LsBrKca9LbRv4FxnH
IZ10jLlkNdO4t+xFSqDMTe6zVtTnCCM/i/w1oq5kX0PJPlZ44nCZeePMxPiEZAnd
ZJ+zNOIc+hH29d1cZCmZv+5am5E0LB1wq3azht+sbkZqoo3BlC1KNkiIDU9mbKIJ
Z99R0lQQm6DXV7rNRUx3lYOHLHWQTb3g6Qv81l8gOP2mxCn4Eq3pNSKpBa81Nava
dByVsBpBpktv6zGRC4ER
=cb6n
-----END PGP SIGNATURE-----

--=-3tn4PqQtHdqprGe94c05--
