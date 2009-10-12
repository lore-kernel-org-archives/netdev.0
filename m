From: Scott James Remnant <scott@ubuntu.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 11:41:15 +0100
Message-ID: <1255344075.2143.1.camel@warcraft>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009145137.GD19218@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-8WHhO4NRJuwOwVJ3UFlz"
Cc: Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091009145137.GD19218@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8WHhO4NRJuwOwVJ3UFlz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-10-09 at 09:51 -0500, Matt Domsch wrote:

> As has been noted here, MAC addresses are not necessarily unique to an
> interface.  As such, we are not proposing a net/by-mac/* symlink to
> /dev/netdev/*.
>=20
On the other hand, they *tend* to be unique for a wide range of systems.
This makes them pretty comparable to LABELs on disks, and we have
a /dev/disk/by-label

Remember that udev already supports symlink stacking, and priorities and
such.

I don't think there's any danger of supporting a /dev/netdev/by-mac by
default, it'll be a benefit to most and those who don't have unique MACs
will just ignore it.

Scott
--=20
Scott James Remnant
scott@ubuntu.com

--=-8WHhO4NRJuwOwVJ3UFlz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkrTB8gACgkQSnQiFMl4yK6nrgCeMoZOfJZOQNxZZnwxKhyCXAzq
UpgAoJ21fQJxIqzGggKdHMW9i6b3w5bD
=xRW8
-----END PGP SIGNATURE-----

--=-8WHhO4NRJuwOwVJ3UFlz--

