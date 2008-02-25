From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 2.6.25-rc2-git] rndis_host:  fix transfer size
	negotiation
Date: Mon, 25 Feb 2008 19:37:37 +0100
Message-ID: <1203964657.13162.127.camel@johannes.berg>
References: <200802221731.16698.david-b@pacbell.net>
	 <20080225182918.GA3094@tuxdriver.com>
	 (sfid-20080225_183249_690048_1D4B5D20)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-X9TJkZYysODYi4CPvy0u"
Cc: David Brownell <david-b@pacbell.net>,
	Network development list <netdev@vger.kernel.org>,
	Jean-Christophe Dubois <jcd@tribudubois.net>,
	jussi.kivilinna@mbnet.fi
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49176 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbYBYSjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 13:39:04 -0500
In-Reply-To: <20080225182918.GA3094@tuxdriver.com> (sfid-20080225_183249_690048_1D4B5D20)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-X9TJkZYysODYi4CPvy0u
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2008-02-25 at 13:29 -0500, John W. Linville wrote:
> On Fri, Feb 22, 2008 at 05:31:16PM -0800, David Brownell wrote:
> > From: Jean-Christophe Dubois <jcd@tribudubois.net>
> >=20
> > This patch should resolve a problem that's troubled support for
> > some RNDIS peripherals.  It seems to have boiled down to using a
> > variable to establish transfer size limits before it was assigned,
> > which caused those devices to fallback to a default "jumbogram"
> > mode we don't support.  Fix by assigning it earlier for RNDIS.
>=20
> Any chance that something like this is appropriate for rndis_wlan?

rndis_wlan uses this code so it already "got" this change.

johannes

--=-X9TJkZYysODYi4CPvy0u
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8MK8KVg1VMiehFYAQJtAxAAhOPD7+UOy8lC6rhjC53hbS5XTWZULEB3
MycbedEGTCryNf8aTEf5qwXFg7evW3FpZXYTM97mmNLNAzBKCwQwTzM+y8V34PvN
tHcElL4V1x5FefdgckDpSrIyw69VobQ60rML8CMZbBMVl/wz3iZjGRaNE2Y8MYo2
0nUVw+1ZulMUXPJhpavTwEbYg+9ATmQ9xVvQaLDK6kQVbiT6mGfetfuvpRT3dilI
A2kt+M+x2PfFwDkf2iYquHHggeiZN57DIqt1+/RPu1c0FKmRBJEM0rd/G2MCXDiM
BZJtw37wNXrrhs7oc+FuYXflSwdJ7jaK8ku5816KgoydvcG93RUKUiP80sNz5mwG
yOBfXGJZsHDbeGT5TZqPHS0lwPiqxwU0OCIkeVDVa3QVDBjQRYyT4y73Z4GmfkcT
gUNb1UMsONgLbSF0apGo6vJ4MvtFE1J775UbB+W/+kCM4+/veqYF6+d68hczwqY5
kSvAeflSxlKg0UTH+lOR3p/x2HyTQuQBa4/vd7HAZ2nGLX9g1g0heNIAPxIyLOPZ
HktS8GaZG5cvlSFbIuoMqKbqp/emsLv9U+DmZPHEW2rOOLqtdco8x5OzT21J3VJj
PJ4Q4kC2hrkv3N6ewMvuwBza1sBkMF0typ+Wms8MeCeEkZSdupnef2Ua9A8aKnuq
fIDKH72nl7Y=
=CoZ9
-----END PGP SIGNATURE-----

--=-X9TJkZYysODYi4CPvy0u--

