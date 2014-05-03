From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] net: systemport: pad packets to a minimum
 of 64 bytes
Date: Sat, 03 May 2014 21:46:51 +0100
Message-ID: <1399150011.24523.72.camel@deadeye.wl.decadent.org.uk>
References: <1399141874-12003-1-git-send-email-f.fainelli@gmail.com>
	 <1399141874-12003-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Le1pH0gZwgh6i/eJzoKF"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35169 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750972AbaECUrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 16:47:03 -0400
In-Reply-To: <1399141874-12003-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Le1pH0gZwgh6i/eJzoKF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-05-03 at 11:31 -0700, Florian Fainelli wrote:
> The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
> controller will discard any incoming packet that is not 64 bytes or
> more. Since the UniMAC hardware automatically pads up to the specified
> length, we can simply ensure we instruct it to transmit >=3D 64 bytes
> packets.
[...]

No, you have to pad with zeroes (skb_padto()) otherwise you're leaking
potentially sensitive data.

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names taken.

--=-Le1pH0gZwgh6i/eJzoKF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU2VVwOe/yOyVhhEJAQoENg//Q8QFZtn0eXlaHtl0LhYRTbuLhSrZW8IM
Dy/jwxmu5663NoInsMeo7cf9NK7Qr0hPVeQe4cSqokNm7kIHjsOEGOFZoHlwpaFG
oNnAG7R7ZqkZYjVmntH94MuMW0DJHR/LpDAmtvEeS4k2KUA33TKC9idrHz62F/f8
/R+vz2RuDU3XwZ58IeA4Bl3lUvGqWpNnDyKitWBtuSabB8gepZqI6+GHaqmszT8m
xwt98lAM6C46SAYG1VcDN9ZH3n++qx+BXNvPE8SAkt5Vqjvr0iEF8ESmLhfIhZT6
WjBuPo+rtmhzUoUz6e2OaYB/H5aLD9XK9WKEA3ASy5Zkos9ciiwEro3Zx7MB18R6
cvpSuuE9DD0liVMIcrEiX/K8ANjj5V7EYXi6F/J3Le6Q64/YMHGF4Xq/aGKbbOQK
exwEP4R5tvmQHOYCq1aKBJRqDQ9WuYeavgyHmNLG49PA66Mjwjzy7IWuop3gBJPN
/MilHjYxkxv27c4z30CzJlkRQp6nyoUHp8hThi0mlqOQ/fCucR4cl0X0Xu8Q0hxj
ZP1u7jnawUe2lIzp52C9/7dvYZQA2sjuOqVprQd6UUb79xXhtfYkbSMa1M8uOs2Z
s4f1z5e3Q7N8SmT1+80wAUHBlIJVVCJ84IMwQq3AeMO3auqgI1u/pklHb++xikcG
psTa18br7Kc=
=iyQ7
-----END PGP SIGNATURE-----

--=-Le1pH0gZwgh6i/eJzoKF--
