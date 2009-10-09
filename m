From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 09 Oct 2009 09:23:03 -0700
Message-ID: <4ACF6367.8040401@kadzban.is-a-geek.net>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009145137.GD19218@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enig1803A6C35735FB8F59016565"
Cc: Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091009145137.GD19218@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1803A6C35735FB8F59016565
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Matt Domsch wrote:
> Let me also note that we are prepared to have userspace consumers of=20
> this new character device node.
>=20
> http://linux.dell.com/wiki/index.php/Oss/libnetdevname
>=20
> notes how the kernel patch will interact with udev, describes the new
> library helper function in libnetdevname, and has patches for=20
> net-tools, iproute2, and ethtool to make use of the helper function.
>=20
> As has been noted here, MAC addresses are not necessarily unique to
> an interface.

Only in the case of e.g. qemu (virtual hardware), I think.  (Or some
kinds of broken hardware.  Anything not on the udev whitelist from
75-persistent-net-generator.rules.)

The combination of (MAC, ifindex) is not unique, which is what I meant
earlier -- but the setup on the wiki seems to handle this properly.
Assuming there was a /dev/net/by-mac/00:01:02:03:04:05 link, it should
work fine...


--------------enig1803A6C35735FB8F59016565
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkrPY3AACgkQYasYN+YI5W6XdwCgpBlOrFJ7YPMYUOfP8idmH47P
33QAn0CmGCuf22EgSuonmAlG518ViUuF
=Bjm2
-----END PGP SIGNATURE-----

--------------enig1803A6C35735FB8F59016565--
