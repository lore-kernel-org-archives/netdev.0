From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] bluetooth: document config options
Date: Fri, 21 Jul 2017 12:42:28 +0200
Message-ID: <20170721104228.GA9448@amd>
References: <20170721074957.GA12640@amd>
 <CDF602D5-78C6-4F97-9C12-3E6AD3AA6C37@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        linux-bluetooth@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        Netdev list <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CDF602D5-78C6-4F97-9C12-3E6AD3AA6C37@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > Kernel config options should include useful help text; I had to look
> > up the terms on wikipedia.
> >=20
> > Signed-off-by: Pavel Machek <pavel@ucw.cz>
> >=20
> > diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
> > index 68f951b..133c8a6 100644
> > --- a/net/bluetooth/Kconfig
> > +++ b/net/bluetooth/Kconfig
> > @@ -45,6 +45,8 @@ config BT_BREDR
> > 	bool "Bluetooth Classic (BR/EDR) features"
> > 	depends on BT
> > 	default y
> > +	help
> > +	  Support Bluetooth version 1 and 2 connections.
>=20
> so this is actually not correct. Version 5.0 is also Bluetooth BR/EDR.
>=20
> I am fine if use the terms "Basic Rate" and "Enhanced Data Rate" in the d=
escription, but the version numbers are kinda not how this works. So some a=
lternative wording needs to be used:
>=20
> "Bluetooth Classic includes support for Basic Rate (BR) available with Bl=
uetooth version 1.0b or later and support for Enhanced Data Rate (EDR) avai=
lable with Bluetooth version 2.0 or later."
>=20

Ok, works for me.

> > +	help
> > +	  Bluetooth 3 introduces high-speed mode where bluetooth endpoints
> > +	  negotiate fast connection over WIFI. This controls its support.
>=20
> Again, while Bluetooth version 3.0 introduces HS support, it is not what =
is selecting this.
>=20
> I think here we can write something like this:
>=20
> "Bluetooth High Speed includes support for off-loading Bluetooth connecti=
ons via 802.11 physical layer available with Bluetooth version 3.0 or later=
=2E"
>

Ok.

> > config BT_LE
> > 	bool "Bluetooth Low Energy (LE) features"
> > 	depends on BT
> > 	default y
> > +	help
> > +	  Bluetooth 4 introduces special low-energy protocol, designed
> > +	  for simple devices. This controls its support.
>=20
> I think here it is also better to have an alternative text:
>=20
> "Bluetooth Low Energy includes support low-energy physical layer availabl=
e with Bluetooth version 4.0 or later."
>=20

Ok. Do I understand it correctly that Bluetooth LE basically has
nothing to do with bluetooth, and that Bluetooth 2 hardware will not
be able to detect / communicate with Bluetooth LE hardware?

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAllx2pQACgkQMOfwapXb+vJXwQCfUJOiXLzhYNwzmIO8Kbvqvbdf
S+4An3PPdWMwtyRE2j4hXD93LaN7H9jH
=FIUF
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--
