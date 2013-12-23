From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 1/6] batman-adv: free nf_bridge member on locally delivered
 skb
Date: Mon, 23 Dec 2013 01:11:10 +0100
Message-ID: <52B77F9E.8040201@meshcoding.com>
References: <1387412132-889-1-git-send-email-antonio@meshcoding.com>	<1387412132-889-2-git-send-email-antonio@meshcoding.com> <20131222.185027.572777902017063381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="QNghhhNb5qfBp7r5CW93NpvWc4lFuLeVW"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	mareklindner@neomailbox.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:45989 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3LWAM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 19:12:26 -0500
In-Reply-To: <20131222.185027.572777902017063381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QNghhhNb5qfBp7r5CW93NpvWc4lFuLeVW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 23/12/13 00:50, David Miller wrote:
>=20
> See nf_reset() and skb_scrub_packet().  Do not reinvent the
> wheel.
>=20

Hello David,

after some discussion[1] the suggestion was to keep the behaviour as
less intrusive as possible, thus I avoided any nf_reset() (and similar)
and I directly wrote my function that calls nf_bridge_put() only.

Do you think it is safe to use nf_reset() directly?
Pablo was worried about "strange" user configurations that may break
because of this.
(Even if somebody may argue that in this case user configurations are
probably broken, not the kernel :-) ).


Regards,


[1] http://thread.gmane.org/gmane.linux.network/286965/focus=3D287502



--=20
Antonio Quartulli


--QNghhhNb5qfBp7r5CW93NpvWc4lFuLeVW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSt3+pAAoJEEKTMo6mOh1V37cP/24K6EgV9dUnndsyHn02F7RI
FowrOdIMSdfruTjH6X8uKHxY5fPd4r97KeDkyDadYzfcjIBtGMCOGPgIg3M6sYS6
FWHXcYeMFQakFtK7f/7ttG5Y3sUGxqDwzVA3ASpC6lzr1b7k1udUYHQfLrqctC4j
mcNVKZnlHo/FQO1h2RAmcuZrcIZmRvVY1yYSW1XH3eVgtlXRdkZScDXhJt5MZxq0
qzDLwbearTyEjk3JWC5MYnrdKylOgFpUsGeXkL3bx9mQbDrbE0CoZqV3uaLKPDt0
LzTpTNr7DY3XiLVcD5A7vce5Z8DJKTIWlNC0zIBjO4TN0GtetiEflyD8KStILIEC
zNoiXVAqavF38IwDZrPzuR8dAVoM+OQoGp9Wnt94r7YEDtOH21d1HMuJONVGtZFV
edMSgYWltoh3mc1sJ4t7VXQ/df+EjZhOx4pBfzmwVmIGUnOTAV1q3kO41LpFS2pC
DiQL2DM2qBTk8m9SQ7pDe1VrL4T1CuP1MkIlJNdavFzA6YmNsYf0X3ZtKIEvppfT
CcjLa5fKfW3CUCaWKPpQjnpTQVHiNj2EwPRyqyq4QlK5jYHy/99JjCcy+tx3Or8S
4lxmC3KQzIt3P11VRwjk9GBxHUar2fhCRZdtEVwIoSK3PL1v81GV++bfGEeqP79y
emXWvFNqgpyqbcIE5kC8
=+Cr0
-----END PGP SIGNATURE-----

--QNghhhNb5qfBp7r5CW93NpvWc4lFuLeVW--
