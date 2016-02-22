From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Mon, 22 Feb 2016 20:05:19 +0000
Message-ID: <1456171519.15241.65.camel@decadent.org.uk>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
	 <1455839111.2794.51.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B55D1@CHN-SV-EXMX02.mchp-main.com>
	 <20160222.141014.1517836822587262524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KCPPcgfBSrR2dkFKQ6Fz"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38707 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752020AbcBVUFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:05:35 -0500
In-Reply-To: <20160222.141014.1517836822587262524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KCPPcgfBSrR2dkFKQ6Fz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-22 at 14:10 -0500, David Miller wrote:
> From: <Woojung.Huh@microchip.com>
> Date: Mon, 22 Feb 2016 18:28:18 +0000
>=20
> >> This is incorrect; you should always return the manual settings
> >> (fc_request_control flags) here. =C2=A0If autonegotiation is enabled t=
hen
> >> your get_settings function will return the actual pause flags.
> >>=C2=A0
> > What do you mean "return actual pause flags" when autoneg is enabled?
> > Pause flags set by (or default) advertise flag?
>=20
> It means what was negotiated by autonegotiation, and is actually in use.
>=20
> Otherwise, how can the user find out what was negotiated?

Well, actually we don't *directly* report the autonegotiation flow
control mode at present. =C2=A0We report which pause flags were advertised
and what the link partner advertised, from which you can work it out.

Perhaps ethtool (the utility) should explicitly show what the result
is.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u
--=-KCPPcgfBSrR2dkFKQ6Fz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVstp/+e/yOyVhhEJAQoFTQ//Rkhqnk+0tR0cDrsopqe/RgGZGx4W9oEp
Lhh5WYQghWpICeOrBY8yhNwKspnt/IQDCc2a0qMgLYVu0BBoJgDFGPQgGEq8AGLj
ff2N5hbfyHq8zQpcbEcRFQh27FOVT1euUCKViTMCf2/M752+vW3NxtIlNVXtPk9O
1jJqNY16vWzgsNSfqyJQGTjoeUM0zwREb9ZGS1x3OFYtBTRseg8uWPrpXd9tbedI
FnOFxoBJPiT6Srzdl+eZ8SkX0QH+r6FrOF7FmPumuBfrchdGvpG6T6ZnjUBqO8RY
FnMnWwsrhcEoKK1wrTjDIR2jtCxbe1BFvCFex9mEtORCoM7xC9dx36kTgmw2HN9b
K3xXX2UwRyMF8dyk0SZ8iOdTtIBktzr8kHzJ5K6r6t05gMJDe/BleBeO8JE32V+N
9rWVHTaceV8jGcsjG0xfBJEWcHepWGYlptmGmyL/ojIknqsvdVqSyCBRQng5BIQa
O25eg4K7Ufb1ZKG+uX21twjP13zogexozEa0Y897sanGAWloy/8uyalRJROHDrBR
T7QmP0xCVeTRO9R/bbTOU+V2/aBwDCWg1GodhQIoLx0zGWNxj9gMrBrKEWyy6F4q
Hwwrj/aA9nnwIlEI8x3vzl1C4WUdN3CqkLeSTm7eI9QvbtbGbbmqbSC353P9xcTR
iUHowI5fgGM=
=apBn
-----END PGP SIGNATURE-----

--=-KCPPcgfBSrR2dkFKQ6Fz--
