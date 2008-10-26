From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 20:33:11 +0100
Message-ID: <1225049591.3746.0.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
	 <1225009822.3478.30.camel@johannes.berg>  <1225047674.10060.10.camel@brick>
	 (sfid-20081026_200122_320043_BFBB81CD)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-OfB/aAYEAOdsB/Q2duWr"
Cc: David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46874 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbYJZTd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 15:33:28 -0400
In-Reply-To: <1225047674.10060.10.camel@brick> (sfid-20081026_200122_320043_BFBB81CD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OfB/aAYEAOdsB/Q2duWr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 12:01 -0700, Harvey Harrison wrote:
> On Sun, 2008-10-26 at 09:30 +0100, Johannes Berg wrote:
> > static char *ip6_string(char *buf, char *end, be16 *addr, int field_wid=
th, int precision, int flags)
> > {
> > 	char ip6[8*5];
> > 	char *p =3D ip6;
> > 	int i;
> > 	u16 tmp;
> >=20
> > 	for (i=3D0; i<7; i++) {
> > 		tmp =3D cpu_to_le16(addr[i]);
>=20
> 		tmp =3D be16_to_cpup(addr + i);
>=20
> > 		p =3D pack_hex_byte(p, tmp >> 8);
> > 		p =3D pack_hex_byte(p, tmp & 0xFF);
> > 		if (!(flags & SPECIAL))
> > 			*p++ =3D ':';
> > 	}
> > 	tmp =3D cpu_to_le16(addr[7]);
>=20
> 	tmp =3D be16_to_cpup(addr + 7);
>=20
> Or maybe just cast addr to char * and avoid the byteswapping altogether.

Yeah, this was obviously not tested. Want to build it? I don't have
access to a fast build machine right now.

johannes

--=-OfB/aAYEAOdsB/Q2duWr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBMXzAAoJEKVg1VMiehFYAwAQAJSIuoydE0pv3stypRSsTzjN
+LV26eYMW+v10qW2mHfDTEpnFsGtYDXTP3HMAADAAq1AWw4IpfhUB5hDfj1zmPOg
9rsqBI8qh1DsilpschLXQfem56I0dGE/l+m6u1Lbppeux42rNGQ95q5AAhAQRpv+
tJOyxsUTxoOT3AQaQwJfJa3mYGNjqBfFkofNNgOGKAFGcDuLsAyk0QQ+S7N11Lan
P8sppcC8wn7/0S8ZOxh38wFqS20wXkhJw8DzGJTCS5MPt+uoWJ874zt8yCgPTiD5
1IHNwEvu3Nx71lNWu4FIj4cTcxPbw2OHuMq1y63cWXubnUVjE8dAfFJIoD63d3OG
NMj/GfHQa/NS0KZYjSLzqGPYEj7PL9QcpFjDPfP818Ta44vugpARlwCL21YYYIgO
qDpfi4mGT8AkIcblDaL/9ZXJgUFBbXREXR0TpXi51BGwDohuxZK/h/op+huFgXX5
tCATLARZyBZ/HXEGKu4ffk1qV5r8Y/m/F96ZVyIUl1DkknIR0uHRaKMj4DqGZdNd
SpJdberGJy1qm8eCaBfHYuXaKp69pvOlkib6xaUwyKvzahqLCtELa0HfxCErujjz
cQaLRcNZQHDd1+oYO0Js0tTbz5ZiO6xEPeyPrR38pIYPAVwsg7I0dL1P1bBulZbx
RZXbzfJuAsXnQnF4ql57
=6jE1
-----END PGP SIGNATURE-----

--=-OfB/aAYEAOdsB/Q2duWr--

