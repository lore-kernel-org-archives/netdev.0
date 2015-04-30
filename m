From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ss: Fix wrong filter behaviour
Date: Thu, 30 Apr 2015 09:19:14 -0700
Message-ID: <20150430091914.32385c0f@urahara>
References: <1430227008-7440-1-git-send-email-vadim4j@gmail.com>
	<20150428133745.GA10292@angus-think.wlc.globallogic.com>
	<55414B85.1070204@ionic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/NELPi+NwYnYjO7bl4EYlGB2"; protocol="application/pgp-signature"
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Mihai Moldovan <ionic@ionic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35928 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbbD3QTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:19:13 -0400
Received: by pdea3 with SMTP id a3so65237096pde.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 09:19:12 -0700 (PDT)
In-Reply-To: <55414B85.1070204@ionic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/NELPi+NwYnYjO7bl4EYlGB2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Apr 2015 23:22:13 +0200
Mihai Moldovan <ionic@ionic.de> wrote:

> On 28.04.2015 03:37 PM, Vadim Kochan wrote:
> > On Tue, Apr 28, 2015 at 04:16:48PM +0300, Vadim Kochan wrote:
> >> From: Vadim Kochan <vadim4j@gmail.com>
> >>
> >> Fixed applying family & socket type filters.
> >> It was not possible to select UDP & UNIX sockets together.
> >>
> >> Now selected families are ORed.
> >>
> >> The problem was that filters were combined by AND.
> >>
> >> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >> Reported-By: Mihai Moldovan <ionic@ionic.de>
> >> ---
> >>  misc/ss.c | 91 ++++++++++++++++++++++++++++++++++--------------------=
---------
> >>  1 file changed, 49 insertions(+), 42 deletions(-)
> >>
> >> diff --git a/misc/ss.c b/misc/ss.c
> >> index 954a30b..46dbb39 100644
> >> [...]
> >=20
> > Would you please respond if you received this patch ?
> > I am just checking, in case if it was get into 'Spam' list.
> >=20
> > Regards,
>=20
> I finally came around to testing this, sorry it took me so long.
>=20
> Using that patch, the output looks much better. It works for my use case.
>=20
> What do we do with the "broken" versions, though? Even if that patch hits=
 4.1.0,
> older versions like 4.0.0, 3.19.0 etc. will still be broken?

I could put out a 4.0.1 but usually reserve doing maintenance releases for =
serious bugs
like security problems.

--Sig_/NELPi+NwYnYjO7bl4EYlGB2
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVQlYCAAoJEICnf2CVzeR+mlkQAK+j2zJFTPjTwBlLzJE0QJ+G
2qvT8BBBMetqAZRQtueCve+coUGeZQKgWXPbhe0z4TTmcHT/6J56zy8Ws9pVFg27
uRUEk3AKCc+2BpTDEKI9JdodHYGhLnycxg/xOb2bc+nLqmJmIUJcI6WMckvZmqZR
jaAdZQQXCspTRADGgZTgIUF92qj3HKL0VxCJOQFIjVqXJyYgfTo3G+LdYX5aIsXM
kA3qoPc+t8X7NUUAj+GUUNjd7R1k0U4A3Cc5TIaNsNfrLNGC47U7SxRlDWLAjTee
nB/RXXoaZSADypCMXm0t9/bgix8BzU38TuTKGYmQFtMa/8HMvJ9pxRJrTEl6DzZl
OUHtAZgbWhor4sg34XVIiWakWJTBce/F+Js6IkGWoBCYet26S7uQyoSSnPs810Vw
isPtjQQFSiG5FPZr4MWXlyr/BFR7d+jrkVVQlu96MAdp1ctLH6cfih25Xtf2FoQF
vqQaCziB9skoLi2HDFUcGYK/qQsV5+1LSVTa65qbVnOpzNemOzFc+11Ehudir4KD
7IC8w3/ZBP0/N5+hXskNH5rJDlhL5Jye/mJSggXIXGdo+jGbuaMsNVP1reLgc2u7
SBm7ojYZhqWMXRvVqurjYAHCptPbiOqrdWv8dnKvgbXw80Tk9kRzdN9l1OojzoV5
R5UOx9iMMct+d82kqQFg
=eTDk
-----END PGP SIGNATURE-----

--Sig_/NELPi+NwYnYjO7bl4EYlGB2--
