From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Wed, 10 Apr 2013 18:54:34 +0200
Message-ID: <20130410165434.GB5177@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
 <1365442863-32394-2-git-send-email-antonio@open-mesh.com>
 <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
 <20130409075606.GB3771@open-mesh.com>
 <51641049.3030100@mojatatu.com>
 <20130409135143.GA5177@open-mesh.com>
 <5164387D.8080700@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="uQr8t48UFsdbeI+V"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht2.myhostedexchange.com ([69.50.2.38]:13439 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761270Ab3DJQ4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 12:56:07 -0400
Content-Disposition: inline
In-Reply-To: <5164387D.8080700@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jamal, all,

On Tue, Apr 09, 2013 at 08:49:17 -0700, Jamal Hadi Salim wrote:
> On 13-04-09 09:51 AM, Antonio Quartulli wrote:
>=20
> >
> > Does this work at the bridge level? A packet entering a port and going =
out from
> > another one can be affected by tc/mark?
>=20
> Yes of course. And on any construct that looks like a netdev (tunnels etc=
).
>=20

Thanks for your hints. After having struggled a bit I found out how to do it
using ebtables and the mark target :)

Thanks a Lot!

These patches seem to be useless now

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--uQr8t48UFsdbeI+V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRZZlKAAoJEADl0hg6qKeOfHwP/A5MWeOyNciDcYYIl3nB58Pv
aVjJNIbeM/+hkCLnEbGjw9xp7H2Te2NZCjDgrRVLntBgtKu2OAZkZAAWFiruSz4k
iDDTzLGlCYLwfQiZQ1MAB4dJKO9MA8Ol62ohy5BAl7a6oz627oFA5VgDMXGy3Vjl
wKLTIFddC8JNfPjNtVY8mzIbhU7nFdks/kUFPhJlqKMqng3sMGnwPJylvceGggH4
dhTzoFQjXzFi3xHRrbWw4mevwNl18mZAVoYQ3QhKXFYw/hUhyZuILasN5bTSFOoK
OZ3N/UwNGn3GutGrFZUH5+DV9atEYqapSdfEzkckFjDQ//I6es/6pfNYRjcN8Z9H
VCJHjviHms90xKaT4zr0T6YfOveaaClHKBQlIE+dnB+TCoQJga8jia1uoSk1AxGp
QCH659NiYTNVWatPSFM47qAFUGsbqwDhytNb6Gq0KR52YeD8CkrwSqbDdsQSxsx8
rCe0iP5TNpY0qilej24Xr1M5Z003kmk5zjbz7w4VagZpJXQdZ+LRjghfOSmbaK4g
dRjFtcaYVv1NN/67KQBJ882CiYJgfx/GuYozJ1rgKJJKeRmcKvRYv754O4Jx4Jso
BRl/HTC4w6ZLXWUrSM1OQLwvYvyAxATNaF+/ScWjh8jShB5SMQIuFd4AlhgDjZSI
01OIdc1YXmPVupMdAo/G
=5jXA
-----END PGP SIGNATURE-----

--uQr8t48UFsdbeI+V--
