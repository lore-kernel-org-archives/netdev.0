From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 07/12] test-features.c: add braces around
 array initialization
Date: Mon, 07 Mar 2016 16:08:25 +0000
Message-ID: <1457366905.15205.24.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-8-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ne7CAuG5TC9fEaML+KZC"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43700 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753259AbcCGQIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:08:37 -0500
In-Reply-To: <1457138533-2417-8-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ne7CAuG5TC9fEaML+KZC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> This fixes:
> =C2=A0 test-features.c:21:1: error: missing braces around initializer [-W=
error=3Dmissing-braces]
> =C2=A0=C2=A0=C2=A0cmd_gssetinfo =3D { { ETHTOOL_GSSET_INFO, 0, 1ULL << ET=
H_SS_FEATURES }, 34 };
> =C2=A0=C2=A0=C2=A0^
[...]

LGTM.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-Ne7CAuG5TC9fEaML+KZC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3ad5AAoJEOe/yOyVhhEJo+IQAMlzKbq3onmUkg+CTFqLDIA9
sfSfzzOb0NDiEtdV/9erW3NS2V5XKWsw82ui6AAMFMIPYdQoPFDjU0Fdr56jZppy
iMDWlkmroKsqMu5LzQxOTKgG3ena5wjghrD1+YDPSrGQFb7BoqD8UX/LZArYu6Jh
kH7BR9vOT6lwEL3kaB6ULXHPfoGGzvS5VNVPs4lol4fUlPQJdCakHOY/u2jB0rKi
gUtKcjggrCCoyM0N3+PnJV6VaL2ScA0HiqBHcs03VhsnQNxd0t2NCyauCCIpM2Co
KZyvHPif/JK4o5u7n3gcyzFwWaUaJI8Fvtnpm+Fp6V3ubCK3J/Ayu/rwF86iZWe+
yaBkhRyJpvN+pJeg80w4GN8cUfZNCuiFnWTd3W3PA6s8PX9kD2FI8z2D6T7CQfSv
+n8W9sud953/gguchvZaDg4RA6VHGxqM/6iX6aRyKiyMG8kKUvXQAwRX6IvgT9lu
HrWpRhRwL4WiZzdoiltv6Are8XbhVwasLnD6RJcnzi4nlgIWfVzc/sbX/oQOB9Cz
LgruV1nIGyN2zRrg8BZYwLQS0bUbJTpa4gojSj90siWSML1LlHCVNkq0iOG1L3gj
f1KL91jtcqoiCgtmi+e552OX7DJ1gEmboi4dgYu/+b5+brkJS+a0yVCsuJhDeMqU
MpFgUdmEggcYRTtA18NJ
=pYYW
-----END PGP SIGNATURE-----

--=-Ne7CAuG5TC9fEaML+KZC--
