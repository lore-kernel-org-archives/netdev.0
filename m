From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 1/3] ssb: add missing method ssb_gige_get_macaddr
Date: Sun, 13 Jan 2013 10:47:29 +0100
Message-ID: <20130113104729.37b9fa03@milhouse>
References: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
	<1358020905-9924-2-git-send-email-hauke@hauke-m.de>
	<20130112.153211.562541025115995797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/JPH0._sfxzvb6Yc9VJK7UB4"; protocol="application/pgp-signature"
Cc: hauke@hauke-m.de, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:52195 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198Ab3AMKhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 05:37:50 -0500
In-Reply-To: <20130112.153211.562541025115995797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/JPH0._sfxzvb6Yc9VJK7UB4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 12 Jan 2013 15:32:11 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Hauke Mehrtens <hauke@hauke-m.de>
> Date: Sat, 12 Jan 2013 21:01:43 +0100
>=20
> > When CONFIG_SSB_DRIVER_GIGE is not set the header does not provide the
> > needed method.
> >=20
> > Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
>=20
> This isn't right.
>=20
> You can't implement this function in a way that the caller cannot
> determine that it didn't actually do anything.
>=20
> You either have to protect calls with ifdefs or make this routine
> return an error indication, in response to which the caller can
> set a random ethernet address or take some other corrective action.

tg3 uses is_valid_ether_addr() afterwards anyway. An error code return value
could be added, but it didn't seem necessary.

--=20
Greetings, Michael.

PGP: 908D8B0E

--Sig_/JPH0._sfxzvb6Yc9VJK7UB4
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ8oKxAAoJEPUyvh2QjYsOBi0P/jW89ANlnIekZKqbL72EP9yc
91BkYpcKlBbLTG0j9JzUEstKIeIbHTj1upVDQHpwuRhzxRnl4JmoHvm0A2lrZGrN
wuh+8QO0B5u3LtIXhx60lyngEkEner7UlMDXRHV1qe6kyYtK/A9Dt2wSeh5dQw0V
VtdjWVZnW7yrruP6vv6SQclIqw4/ibaWUxO9hiQ6U/4gFnJ7xQzxCs6Y8kq9hT8p
n0NxEZSxAV/MfzedlstMYdO1oAvqHwuRWuCpzK1hCoZzf4JO9OQhuMZu/gLczpll
nGX4EhqNZvxxETXJZBbR5ggSOAWSOiSZJHiRKlt/GhdjcWKX6y6+2MgTQcEsqMIQ
2x5W5p7/YV9qsk6DWasoxt9dVm4RTvSU3iim8iHRV3OlE0YgKPXMrRq9QDT8h1A/
WBGRJ62SFEon5IwwSRn01Q5Lpz3fDqaPrnF2pE9cdpDhM/l1K4r7CWlVxOWNFrcE
yzV/vJ+ExbSBVk8MKlgW9c4NaVU2iyQlfbYyQKa8YB17lSaHkVsCJQt/+5shEIbM
iLZ+fEgt6u80BXZUOGVoRXb7rTMJ4fT6IcF5nHTYXK5bA1scibg//KTgwDkWck2S
7qL8dK8dHXGbGCZDgDcpuNkZ3Htu6z04BCotrDR+QYung0Blw/qtQiT0LzUKGeZ9
K3aRiohYB2zE0KTYTQ0Q
=7YS1
-----END PGP SIGNATURE-----

--Sig_/JPH0._sfxzvb6Yc9VJK7UB4--
