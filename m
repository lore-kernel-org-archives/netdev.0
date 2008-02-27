From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Wed, 27 Feb 2008 13:34:34 +0100
Message-ID: <1204115674.6309.0.camel@johannes.berg>
References: <47BAEE3B.7020502@trash.net>
	 (sfid-20080219_145720_362430_7BA05F2C) <1204112235.3729.54.camel@johannes.berg>
	 <47C54DA1.5070402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Ja5qwsuW5Q+mH0qNtJcq"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57294 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbYB0Mev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 07:34:51 -0500
In-Reply-To: <47C54DA1.5070402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ja5qwsuW5Q+mH0qNtJcq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Could this be the reason for us seeing "multicast address leakage"
> > warnings?
>=20
>=20
> I don't think so, the users field was already initialized properly
> before. Is wireless using dev_unicast_sync or dev_mc_sync?

dev_mc_sync(), we sync all multicast addresses of all interfaces to the
master netdev to have a single consistent list. There used to be a
custom implementation of that but I replaced it.

johannes

--=-Ja5qwsuW5Q+mH0qNtJcq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8VY2aVg1VMiehFYAQJaQg//X7pZIokjaEK04huUr/vc1kYvqUWTATXe
K+VphNNt74sA8WdxuI6kUETkjsfsgm0FSji/m6H94JZprq0gemhd9h62yGndZUtx
26iLafFDGamFtwYPh4SmeEHQewn3e+Nlk/ebUob3KE+/2tHUBje4dw0AbrOpi4cX
vFlR2dEKK3QdEj0TQR0dd3XK5+7yqsfsEM1xyTWk1UFSG/Y5KonTDZJ7GVLSYuyl
Hl5nWNt3kU1oxvHnyjgZbp9dHNZ5oMaB0wNpPWefAoZUiTlX9ZXoZCyQDiAKQp6S
TSHwcaBiiMvY0dRUfhDqXkYbPS9AJfYAXza0Z+PZrc0L4/tnsXOVRshC5DHVt1pc
4DPIX2PH0EPADqpn7dVgLQVkLtx/VW8CPYifjJzqEnl+xFozV4H3iBs1MNRuYB5L
vjVUvs0eF6PQJ00VEz8tK/CBKIT+KJoubrPLCIEo5oKJ6wG59hZye3x0EkvlQrqE
+MHiwzAzqRXNvgUbDQaAXEk7+hlvn25XebjVkUSfQ1DgP+ULoLTcmSXX+EZMvgRV
6SGCXP4EorV4uEIidFRPD0kwXcyASkH5pHpwekZDy8jQsZJH72OtSlgJXlKiN6x1
GyILsqMKSlqHbe5yWseIE+cdpt3Pc8KL5+qHz2CuFaarSfiBtBBaOvUiRINQeDBs
BJuowOUSc3U=
=Ql6H
-----END PGP SIGNATURE-----

--=-Ja5qwsuW5Q+mH0qNtJcq--

