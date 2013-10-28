From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Mon, 28 Oct 2013 17:21:25 +0100
Message-ID: <201310281721.25182@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <201310281604.48542@pali> <1382974161.1542.18.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1574068.VmWX2z1Tuz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382974161.1542.18.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1574068.VmWX2z1Tuz
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 28 October 2013 16:29:21 Dan Williams wrote:
> On Mon, 2013-10-28 at 16:04 +0100, Pali Roh=C3=A1r wrote:
> > On Monday 28 October 2013 15:56:55 Johannes Berg wrote:
> > > On Mon, 2013-10-28 at 09:46 -0500, Dan Williams wrote:
> > > > If the device doesn't actually *have* a permanent MAC
> > > > address, then it shouldn't be returning one via ethtool,
> > > > and should return an error for ETHTOOL_GPERMADDR.
> > >=20
> > > There's currently no provision for that, but I agree it
> > > would be better to do so.
> > >=20
> > > johannes
> >=20
> > So what to do with devices which has MAC address stored in
> > some obscure place and there is userspace binary which can
> > read it?
> >=20
> > I think that there should be some way to tell kernel that
> > *this* is the permanent address and it should use it.
> >=20
> > This is reason why I proposed patch which adding sysfs entry
> > for setting permanent address from userspace in wl1251
> > driver.
>=20
> Ok, so the N900's MAC is stored in the "cal partition", which
> is a region of flash exposed to the OS as /dev/mtd1.  That
> also stores the regulatory domain.  Typically userspace
> binaries are used to pull out this and other data (see
> https://dev.openwrt.org/browser/packages/utils/calvaria/files/
> src/calvaria.c ) which is then used to initialize the device.
>=20
> Any idea what kernel driver is used to expose the CAL
> partition as /dev/mtd1?  If it's nothing special maybe a
> small EEPROM-style driver could be written to read the
> relevant areas (and since they don't ever change, don't need
> to worry about something else writing at the same time).
>=20
> Dan

/dev/mtd1 is second (0 is first) OneNand partition. Nothing=20
special. Kernel driver for OnaNand is already in mainline kernel.

That partition also has NVS device data for wl1251 chip.

And you are right calvaria has GPL v2 code for parsing data in=20
that partition.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1574068.VmWX2z1Tuz
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlJujwUACgkQi/DJPQPkQ1LX5ACfcrgQRff2KxGg5oOgjLQ9+nqu
cjQAoK/SFpSUsV5jVdqdfNCN+yBkWdi0
=49Dn
-----END PGP SIGNATURE-----

--nextPart1574068.VmWX2z1Tuz--
