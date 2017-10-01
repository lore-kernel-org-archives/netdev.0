From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Sun, 1 Oct 2017 09:21:51 +0200
Message-ID: <20171001072151.GA14600@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
 <20170908215735.GF27428@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
 <20170928152445.GC2482@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD4112CBC8@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:41533 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdJAHVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 03:21:54 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD4112CBC8@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-09-29 18:45:19, Tristram.Ha@microchip.com wrote:
> > > > > > Similar code will be needed by other drivers, right?
> > > > >
> > > > > Although KSZ8795 and KSZ8895 may use the same code, the other
> > > > > chips will have different code.
> > > >
> > > > Ok, please make sure code is shared between these two.
> > >
> > > The exact function probably cannot be shared between KSZ8795
> > > and KSZ8895 drivers because although the register constants look
> > > the same but their exact locations are different in the 2 chips.
> >=20
> > Put the code into header as static inline and include it from both
> > places?
>=20
> Although KSZ8795 and KSZ8895 share the same code when simulating
> the PHY register access, even though the exact registers are not the
> same, this code needs a little modification for another chip.  It also lo=
oks
> too large to put in a header.

I believe putting it into a header is prefferable to having two (or
three) copies of the code. If it needs small changes, you can
introduce if () ..., gcc can probably optimize it out.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnQl48ACgkQMOfwapXb+vKpcgCbBHROx49BRx6wegoec7Y1NW23
TNMAnA5E9a6zyIs7P11+Xod4xIXBWKjS
=Ak3X
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
