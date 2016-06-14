From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC address on RTL8153-AD
Date: Tue, 14 Jun 2016 18:28:10 +0200
Message-ID: <201606141828.10969@pali>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com> <20160611153921.GP2338@lunn.ch> <20160611.104226.1571085838142610714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1931430.yfpjyEjA35";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, mario_limonciello@dell.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com,
	gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160611.104226.1571085838142610714.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1931430.yfpjyEjA35
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 11 June 2016 19:42:26 David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Sat, 11 Jun 2016 17:39:21 +0200
>=20
> > What is still open is do we want to accept it at all? Do we accept
> > the concept of putting the same MAC address on multiple interfaces
> > at hotplug time? Do we trust BIOS vendors to not keep changing
> > DSDT property name, since it is not standardised?
> >=20
> > Do we want this at all should be decided by somebody more senior
> > then those passing comments on the code.
>=20
> Indeed, I think the behavior of using the same MAC address on
> multiple interfaces if we plug several of these in at once is not
> good.
>=20
> We shouldn't behave this way just because the Microsoft driver does.

I agree, but in some cases it is night mare for local admins when=20
booting different OS cause changing MAC address on local network.

Another similar situation: Imagine that you have two USB network cards=20
and both have "burned" into their registers same MAC address. If you=20
connect both those USB network cards, linux kernel bind appropriate=20
driver which read MAC address for both those cards. But those addresses=20
are same. What will linux kernel do in this case?

This is very similar situation as those Dell usb network cards told us=20
"hey, use address which is in ACPI DSDT table".

Either we should trust what network card what told us, or not and then=20
generate MAC addresses in better way.

Just my opinion...

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1931430.yfpjyEjA35
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAldgMJoACgkQi/DJPQPkQ1IHrQCfaIVHBc15BzsnyUg9BEWsc3dA
ZIYAn2aSDM62b8c5S1nr7SFlZBM5OZ7Y
=/Bk2
-----END PGP SIGNATURE-----

--nextPart1931430.yfpjyEjA35--
