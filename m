From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 0/3] llc2 station handler fixes
Date: Mon, 13 Aug 2012 13:48:40 +0100
Message-ID: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-r+g/abG7TQT15b/3cY9o"
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39124 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab2HMMsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 08:48:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-r+g/abG7TQT15b/3cY9o
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I was insprired by commit 91d27a8650d5359a7a320daeb35b88cdea15e3a8
('llc: free the right skb') to look into llc_station.c, and didn't like
what I saw.

These are *only* compile tested; hopefully you have some way to test
LLC.

Ben.

Ben Hutchings (3):
  llc2: Fix silent failure of llc_station_init()
  llc2: Call llc_station_exit() on llc2_init() failure path
  llc: Fix races between llc2 handler use and (un)registration

 include/net/llc.h     |    2 +-
 net/llc/af_llc.c      |    5 +++--
 net/llc/llc_input.c   |   21 +++++++++++++++++----
 net/llc/llc_station.c |   21 +++------------------
 4 files changed, 24 insertions(+), 25 deletions(-)



--=-r+g/abG7TQT15b/3cY9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUCj3qOe/yOyVhhEJAQpwKBAArzkRd4uGIZjWjsLFSVSqUB75FKcSiBeS
1v85vM52enD5BppnEqhdSfSsqOa8nYoNwDT+0MUNI54sE/8SGkD8bwNa3YM8gnYz
CYhKjsofAAkfyNWfIpD5IB2a2OPzzDbGi4xeMxHDumOOuyt+Vi+ZZVAcsVl56fPt
BOBto7eZ7E6mSf5T6KaNCPX6B99u5s415bcZyNV5hKlDCr8+7m3QTCfLDBEoh7K1
MV8k65vl6HLDYW5O0fSKVwnu3yuI7IOqAdY/2FnNQJPSc2fLrwsvZq1rHINoOXeY
S6zkZeAjI4+kLpfHvVt8YhsWvTNdZFUJLeOzDr4Qf51Z+lIIJqwPkEt+wMrOT3y5
E/ZJXDnvo5skTowwyMaC3CDaXZIYv40ugN/ZxtaLQSmp7mPBL5867Oaci+a2rwpw
3tR4Kf76mYvPgJAlvh33pGeFl7eOJfny/X/4a5KlVNqtWZqLfDtbj+8jMs4k2iTi
jMb8W6jhsmncvyfEI4OG9zW6nvzXf4vzzSP4cn9aUnVluR5z2rHSpNSZ/TXB53aC
OmAkdJrhmia4yaqStZvgPQ6ijsZS0NNjk0gcwJQGccnZGnCpcb3SS+36ZVFD6seT
pPViA7KcvanMk1zBog61EMIWh9nssOMbaYTBRvQGVU1lWuzXWLTgT25kfT42Jr8u
yBxn61Jhb20=
=AmdX
-----END PGP SIGNATURE-----

--=-r+g/abG7TQT15b/3cY9o--
