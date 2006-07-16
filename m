From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: michael_mic in crypto api?
Date: Sat, 15 Jul 2006 21:44:38 -0700
Message-ID: <200607152144.44350.flamingice@sourmilk.net>
References: <E1G1hWW-0004ec-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1255527.Y4atA5KU0J";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:14728 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1946001AbWGPEpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 00:45:18 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G1hWW-0004ec-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1255527.Y4atA5KU0J
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 15 July 2006 03:37, Herbert Xu wrote:
> I suppose the question is that what do you gain by moving it out?
> If all else being equal then it's better to have a standardised
> interface for accessing it.
>
Simplicity and consistency. Whereas the relatively simple mic part of the T=
KIP=20
algorithm is in crypto API, the (more important, more complicated) key mixi=
ng=20
part is not in crypto api. It is unlikely that either the mic or key mixing=
=20
part would be used separately or even outside of TKIP/802.11i code, and we=
=20
don't want to encourage people anyways since they're just bandaids for=20
problems associated with using rc4.

=2DMichael Wu

--nextPart1255527.Y4atA5KU0J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEucQ8T3Oqt9AH4aERArmvAKCK/oRDyiu2E3NTKR7AJo+5YjzMVwCgm3Zh
ET4vGa+DqZ11Xn4odEJZZUc=
=+Skh
-----END PGP SIGNATURE-----

--nextPart1255527.Y4atA5KU0J--
