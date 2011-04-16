From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: r8169 misleading firmware error messages
Date: Sat, 16 Apr 2011 16:34:23 +0100
Message-ID: <1302968063.5282.859.camel@localhost>
References: <4DA952D5.7030805@joco.name>
	 <20110416110454.GC17833@electric-eye.fr.zoreil.com>
	 <4DA9864E.2070405@joco.name>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-5q6hYAK208z1SYwGyDPT"
Cc: =?ISO-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: Fejes =?ISO-8859-1?Q?J=F3zsef?= <fejes@joco.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51034 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751811Ab1DPPe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 11:34:28 -0400
In-Reply-To: <4DA9864E.2070405@joco.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5q6hYAK208z1SYwGyDPT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-04-16 at 14:06 +0200, Fejes J=C3=B3zsef wrote:
[...]
> I took a deeper look. It seems to me that the firmware files are not the=
=20
> usual microcode type that the device can't function without, it just=20
> sets up some registers, which supposedly already contain some sensible=
=20
> values, so it's more like patching.

Some of the R8169 variants have a microcontroller in the PHY running
firmware that is initially loaded from non-volatile memory (maybe
eFuse?).  These blobs contain bug fixes for the original PHY firmware.

> That explains why this device still=20
> works without the firmware. So my actual question is this: what do I=20
> gain if I use the firmware, what do I lose if I don't?
[...]

The original firmware apparently is unable to establish a stable link
against some link partners.

This warning:

> W: Possible missing firmware /lib/firmware/rtl_nic/rtl8168d-2.fw for=20
> module r8169
> W: Possible missing firmware /lib/firmware/rtl_nic/rtl8168d-1.fw for=20
> module r8169

is purely based on the MODULE_FIRMWARE annotations, which do not
distinguish which devices might require which files.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-5q6hYAK208z1SYwGyDPT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATam28+e/yOyVhhEJAQqJhRAAmUM7R9XQOacTqgltbIo8uZGQjnL7ZZYm
4NnFylaX6IhnbfzDyVM15LZk7AbE6nHmnSgz7qO2qUVT8VJUgSi791VDwg78UnWR
hWr+wt1q2ptkd5rraB+8w1E37rb1zeglYV53xmyNNWbu0e0hwMeQX9QR3N315IGv
alw9Je1o5/AW95Mn7o+V+S/pSLum3ZDC/q38pZhZW3cGrjNJyLokkdx1ueLFeDVQ
LsV6+tMucazzXbNRwiHe9cZc5PLD53MLmVmbVB0aiHIssOmOt+W/x3wZroWNRpqx
NkBHp61nrKWT5TzF4pfoEX8Gm7jCDUWSJQG7mCBSyNzTu+MSlQatAje3l682DwXy
FyS9hN7isqSeJFFN2qkeyW0qTz6IAGnqwTwcqUCke+3zp/FVfUpXcV1E4tuRJPJh
Lfe0ejevEs6da+5sU5ulWgBxajzpNwLCQeGrFTak3B/ii/lfAPXFPgfPQ6fhBGWU
iIFE0BbIQXxN+9DTOxlUN/b2rJfGYj5+a2cneVu7qNx0WTLROEsCff+A69jjasEC
ssNB0TuTwm5g140Z8JYwv3VMpMz/OlhLpgE8yBsLjhC+WCjOpWzCBt0kuIY8F1JB
AT5dfaWASifs27+DiFzlox+czwHw7sX8euLz1c02Lj5JuuVr6qA7FkP/pzRAO+j1
cUMaROZgtf0=
=5x1p
-----END PGP SIGNATURE-----

--=-5q6hYAK208z1SYwGyDPT--
