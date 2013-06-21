From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Fri, 21 Jun 2013 22:39:18 +0100
Message-ID: <1371850758.8771.28.camel@deadeye.wl.decadent.org.uk>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
	 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
	 <1371765508.8771.17.camel@deadeye.wl.decadent.org.uk>
	 <1371766157.8333.25.camel@jlt4.sipsolutions.net>
	 <1371818751.8771.26.camel@deadeye.wl.decadent.org.uk>
	 <1371847374.8936.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nnabdirftZWjFMHBQSgu"
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, Johannes Stezenbach <js@sig21.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37809 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1945958Ab3FUVjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 17:39:25 -0400
In-Reply-To: <1371847374.8936.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nnabdirftZWjFMHBQSgu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-06-21 at 22:42 +0200, Johannes Berg wrote:
> On Fri, 2013-06-21 at 13:45 +0100, Ben Hutchings wrote:
>=20
> > > Ok, I can kick out the 'select NET_CORE' here anyway as MDIO doesn't
> > > need it. Or did you want to do a more general cleanup on this, then I=
'll
> > > leave it to you?
> >=20
> > See commit a1606c7dc64d8449676d7e840dd2cd0c4e0a0c57.
>=20
> Ok, I'll remove it from alx.
>=20
> > > How would I even test that? Find random devices that have flow contro=
l?
> > > I don't think I have anything that would be programmable, unless I do=
n't
> > > know about it being so :-)
> >=20
> > Most Ethernet controllers seem to support flow control.  Though, in a
> > quick test, the e1000e driver on my laptop never seems to turn off Paus=
e
> > advertising!
>=20
> Hah! And how did you determine that? :)

Turned pause autoneg on/off and looked at the PHY registers with
mii-tool (Debian version, which I think has some patches that never went
upstream).

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.

--=-nnabdirftZWjFMHBQSgu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcTIBue/yOyVhhEJAQoHFxAArD4UaBd7dON0+DRXzQ1En2UrUe6XH4ey
9HYRdQG/ZUIS6iubYI9RIrdhtwGvX3/DSfZuRYcx2VLvOJ9aeaqGzAZEvnTyijhR
nhYuKBdok3/hnv6AIMW3lrcAhwQhkUe+xj20AWAZlONHuq7rnWlnxVRXI9LnopMs
ljRQq2dYNiy4AaZlAwZdRKcLn2ndIzZB14nLC/w38ydN1g/aqDRCvt+5R4Ggm8Lc
ZviQ7UqiOv0YQtwYxBO5M6xWe2K8fSb4Z6eeFHDlxv9N3IrWdamO6rh2nV69VlgE
+mB268sHHrw6GUPcvyz7Xwen05Hdk+pL5Okd2nO6yQVaQU+YMBfBaK4Ypab0ffgn
cftJxnkFUF5V96SE8LP+aEbaEWQqXUpXKUArERDNOT40ZpkIGDy9QlOaH7Cxkcg4
2C+qCYFiWAHqu+xSQUmx4sPF03lARpGPZwou5PlEE+5F5eijBouhiro22V5VlSlq
ovlaJE/L0PDBfCZ7PpOxaB8aaGcXyQI4958zceXo/+ntVoxw5aBPF/sQO8rhRdcp
ZhAm64iVsZrQN8/Ppp3gkjoFKB77PXweXOkp1LEmLKQrnTkHVAXbxfM58bWa06ty
tFUaMyDT6kaso19gU8KVUVBUTn1qmXtFIb1ZPBgTFWEaFXV6QBl+OY84IkuvxAio
m0rS9wusfRo=
=mWqo
-----END PGP SIGNATURE-----

--=-nnabdirftZWjFMHBQSgu--
