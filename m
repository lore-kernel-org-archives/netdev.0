From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Fri, 21 Jun 2013 13:45:51 +0100
Message-ID: <1371818751.8771.26.camel@deadeye.wl.decadent.org.uk>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
	 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
	 <1371765508.8771.17.camel@deadeye.wl.decadent.org.uk>
	 <1371766157.8333.25.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VgEDO9KgNjPA8fdyzb1x"
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, Johannes Stezenbach <js@sig21.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36309 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138Ab3FUMp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 08:45:59 -0400
In-Reply-To: <1371766157.8333.25.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VgEDO9KgNjPA8fdyzb1x
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-06-21 at 00:09 +0200, Johannes Berg wrote:
> On Thu, 2013-06-20 at 22:58 +0100, Ben Hutchings wrote:
>=20
> > > Yeah, no idea, just copy/paste. Lots of drivers seem to do this, for =
no
> > > particular reason it seems?
> >=20
> > As I said, most of them select MII which depended on NET_CORE, so they
> > really did need to select NET_CORE too.  I've now fixed that.
>=20
> Ok, I can kick out the 'select NET_CORE' here anyway as MDIO doesn't
> need it. Or did you want to do a more general cleanup on this, then I'll
> leave it to you?

See commit a1606c7dc64d8449676d7e840dd2cd0c4e0a0c57.

[...]
> > > > I couldn't find where auto-negotiated flow control is programmed af=
ter
> > > > the link comes up.  Maybe it isn't?
> > >=20
> > > No idea, sorry. I clearly have a lot to learn about how ethernet devi=
ces
> > > typically work, should it be programmed?
> >=20
> > When autoneg is enabled, the PHY should perform autonegotiation wheneve=
r
> > it detects an electrical link; if successful it will configure itself
> > for the negotiated link speed and duplex, and trigger a link interrupt.
> > But unless there is firmware running on the controller, the driver
> > usually has to read PHY registers to get the result and then configure
> > the MAC speed, duplex and flow control accordingly.
>=20
> Ok, makes sense. I guess a bunch of these things are done in
> alx_post_phy_link() or so, but yeah I don't see flow control either.
>=20
> How would I even test that? Find random devices that have flow control?
> I don't think I have anything that would be programmable, unless I don't
> know about it being so :-)

Most Ethernet controllers seem to support flow control.  Though, in a
quick test, the e1000e driver on my laptop never seems to turn off Pause
advertising!

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.

--=-VgEDO9KgNjPA8fdyzb1x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcRK/+e/yOyVhhEJAQrFlBAAyWckTf0tdu/rWpZkstQD6xO28iXJveIy
j8L92U5WBqqcdxX9u4QiSVMSSS5tpLdb18CFm69xx7Uv26ngbpzOgB2dkK80HeCj
roR7cu9PD3D7pKR8EBgmmaDZKBoHFJ7IwB+33mRT2C1m77i7OVr8rS9GQLEGrGOt
WK+eR2NgQAmMe05VMFg8x+ZS1H42WVVIJAsN7a52mM/Majx1w+4Kx/v7GXjF2DqG
6Tg8TGAZCaPM8zUEqkXUbob8mulC4jA9QacksgtsBvYRJQ+I0yEFOChFRjTkJp+5
PvQL4lETGhZwjQB9IpQqdwL6OxKysy5AyqpaKlcrdzC4Si7vqlHJH4XZDF+nzW3E
E767ZsM+YkZ10v69cIVWFIMS/TjVuKlAyt2Voow+q2JBfoRAtrXedGp3insOoVEo
Kf9EFlLktNVHFjVJGVw0NkqT9MBvaa9sMf+/rFmcEI92bZQOQwdK2i4TIiJ6csgr
ysbFKmhBxxdDjKXICCF5DluJu8DRodDzDCjNX/1FHgiL9w4GfKmo8zt7BLXv7o1v
1Uw+NMh5Aj8WJQ9bb8drLkeNJoLWZEM1F1A3XTKscAczoqkteLZd4VBOBZUSDJFU
yxMRiRea2/B8M0iKNWXHZmn9vYk2toPbNVdLcSNoIquVg8yMBzBsGPc4PeYG4Axk
rTJbuuRsjHg=
=cQvu
-----END PGP SIGNATURE-----

--=-VgEDO9KgNjPA8fdyzb1x--
