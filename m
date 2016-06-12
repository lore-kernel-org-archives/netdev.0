From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636
 Memory map max sizes
Date: Sun, 12 Jun 2016 13:34:12 +0100
Message-ID: <1465734852.3529.148.camel@decadent.org.uk>
References: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
	<20160611.155134.1474324006340328110.davem@davemloft.net>
	<CAKWE-Xrw6kE7-rSOP1NRQaT3jAHWVVkhWz8c2oinYmQc+LrnjQ@mail.gmail.com>
	 <20160611.192648.91885921700006865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2XhPyYf8WVHdLHJgj1N0"
Cc: bwh@kernel.org, netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, vidya@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33597 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbcFLMeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 08:34:16 -0400
In-Reply-To: <20160611.192648.91885921700006865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2XhPyYf8WVHdLHJgj1N0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-06-11 at 19:26 -0700, David Miller wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> Date: Sat, 11 Jun 2016 16:22:38 -0700
>=20
> > As part of ethtool application, application is requesting=C2=A0 the dri=
vers
> > to provide the supported eeprom size to allocate memory buffer for
> > getting complete dump.
>=20
> And the right way to do that is the driver requests the eeprom info
> with a buffer size of zero, then the driver fills in the size field
> for what the size actually is.
>=20
> Then the application can allocate the proper buffer size and rerun
> the eeprom request.
>=20
> Putting endless values for each and every eeprom type a device has is
> just rediculous.
>=20
> I'm not going to continue promoting this broken and unscalable scheme,
> we have to fix this.

I don't think there's nothing broken here. =C2=A0ethtool doesn't use those
macros, the drivers do.

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.

--=-2XhPyYf8WVHdLHJgj1N0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXXVbEAAoJEOe/yOyVhhEJks8QAJy0EtCN7GYJDWLaOah8s+Kz
OBzdST5jBDZL1zQASKJt5XZ73FdxcK7GbvZySFXn8iHn1cEt82bJEJL86GJVhw8j
q3I9r3dRJOF6gAryupxyICmDbG0G/4TPnTHQgCdB0WeNnkM2MhQTGPoxBThrjWMg
vejoLGXmhe2Rpfm8BKvsF5LoODLJ2ZzdR+9vZP6WWZCruyHEZ0x9m7EnAqk870FL
wiDjwWUJ7kAosfuWsfN0UBlJ06bNyTEAyXKyPf8Ht8QlhNke2TX+HsycScC9h1TE
pxpcjcN4e0paeHFMABQOpIZfNCY3Egz3+zaubUWUMS3vSvZozTdWOO+KlCJYAi1s
TYZ6pxxxFf4yWuOSrOJSs80y5JirnqdCofXETzVJGdVJWpwj/qaMyCMkB9Sqr+Ts
h4bVyGqVqpXphv5IHFqDoWztbIpeuJBUf6CY+Rn82yO8YEPMRNHz8gF3P+N+76yN
wTpFxIt0efMVkoORbZ1fUrxZaI3SroryEC7kBJ66FQyHudILIuoIBEeWD/ASg4I3
NnrfagbDSsoQ2VxWMRWkbV8YeOfzKSelRz0GFp9nmeVjWeRgmtMmzDLWOdvoqVfe
A6PycIlsNsUHVJ6Kj3gflkzUOqzqjUZAH/UTg3qxf3v2PxpNO6csp2zyZmzkGwd5
A7Rg5bqcbB/58q0FVIPf
=zE7/
-----END PGP SIGNATURE-----

--=-2XhPyYf8WVHdLHJgj1N0--
