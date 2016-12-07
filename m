From: Thomas Haller <thaller@redhat.com>
Subject: Re: commit : ppp: add rtnetlink device creation support - breaks
 netcf on my machine.
Date: Wed, 07 Dec 2016 18:43:42 +0100
Message-ID: <1481132622.4116.6.camel@redhat.com>
References: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
         <20161205175320.mbtswpmdjumfgh7y@alphalink.fr>
         <5d537b7e-97e9-709c-7b3e-61280cc264f8@fnarfbargle.com>
         <20161206230853.ukyg75cyxugdwg4a@alphalink.fr>
         <1481065966.11028.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-xKf9uIVe7k2xIrISf9XK"
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
        David Miller <davem@davemloft.net>
To: Dan Williams <dcbw@redhat.com>,
        Guillaume Nault <g.nault@alphalink.fr>,
        Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54260 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932713AbcLGRn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 12:43:58 -0500
In-Reply-To: <1481065966.11028.3.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xKf9uIVe7k2xIrISf9XK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-12-06 at 17:12 -0600, Dan Williams wrote:
>=20
> > libnl1 rejects the IFLA_INFO_DATA attribute because it expects it
> > to
> > contain a sub-attribute. Since the payload size is zero it doesn't
> > match the policy and parsing fails.
> >=20
> > There's no problem with libnl3 because its policy accepts empty
> > payloads for NLA_NESTED attributes (see libnl3 commit 4be02ace4826

Hi,

libnl1 is unmaintained these days. I don't think it makes sense to
backport that patch. The last upstream release was 3+ years ago, with
no upstream development since then.

IMHO netcf should drop libnl-1 support.

best,
Thomas
--=-xKf9uIVe7k2xIrISf9XK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYSEpPAAoJECnCNm5N/Fco8FEP/jTeU23q6jGP5E/aPTRp90Ko
V0IKm/e3/Jq7K45zMi9LTeo17nknlFLWIMc1yRUGBksXOQQJBYq4QXTa0ZP2pwHX
QUZZpQYpI5fqOUtMxCSIH9oBto57MqcVmvHdYeWqCgkOzaPAp5YMk+JlvUB9E6II
wy27nHUcc1AaOG7MhVcQfW5J4a8GZkBKfUICwgsrdutZlV6/6jB/bBVIzWuEKk0y
v5zb19eHpKscdHP6X7/WreUJS80cHq0DeJiSavbMZE8ilGAs9OcIBkxjXL+DV1IG
yRi2tN/Ox+i6e49tqDYG8Y5U+cdZAP319miBZ2CIqDH2Lyr/ywzrq6fNYE7gInnT
sP8nIfLSb+PqMQQNbrsoM4JyO8xDDTM7RxdRvL2W7dtUUNkdHCKPJ0Qr6BhnjTWJ
0Bi/s458Ar4VKyspmTbGJoTLr/ej/Pc7lFl2GeuYivb/z2EgPsWGCGXKGq7Ey31C
t3ZpsJqtEQusCoT5KPdpeezUbJLyN1VCelzgXs+46bxZWqf5N0bdK40rCxCnGO6t
pXCTMlcV+GiE6QfWkUb3PR+7v1lfCWRGixeKkNvgmIKmsZwPJhYFswya5KgxrpX4
dk8qVVbTdNCAhYRXVqZ5S8jKqcSEOsybAZdXih8/FWUR8iM68H27dLiDeWokx/8z
BGWo8qVi4AshodwjEVFe
=QPuX
-----END PGP SIGNATURE-----

--=-xKf9uIVe7k2xIrISf9XK--
