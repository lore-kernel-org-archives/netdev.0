From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 22:08:56 +0100
Message-ID: <201412082208.56307@pali>
References: <201411271506.20457@pali> <201412082015.18501@pali> <20141208210018.GB14895@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1606789.mnJHGJHFWa";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208210018.GB14895@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1606789.mnJHGJHFWa
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 08 December 2014 22:00:18 Greg Kroah-Hartman wrote:
> On Mon, Dec 08, 2014 at 08:15:18PM +0100, Pali Roh=C3=A1r wrote:
> > On Nokia N900 NVS data are generated on-the-fly from some
> > bytes from CAL (/dev/mtd1), from state of cellular network
> > and from some other regulation settings.
>=20
> When is this "generated"?  At boot time?  Or by the firmware
> loader program you have hooked into being called by the
> kernel at "load the firmware now please" call time?
>=20

When userspace system network daemon is started.

> > So I think that files stored in linux-firmware.git tree
> > (which are also installed into /lib/firmware/) should be
> > loaded with request_firmware function. Or not? Do you think
> > something else? What other developers think?
> >=20
> > I'm against kernel driver for CAL (/dev/mtd1) for more
> > reasons:
> >=20
> > 1) we have userspace open source code, but licensed under
> > GPLv3. And until kernel change license, we cannot include
> > it.
>=20
> You can change the license of your code if you want to, don't
> make this type of nonsense argument.
>=20

Code is not mine, so I cannot change license.

> > 2) NVS data are (probably) not in one place, plus they
> > depends on something other.
>=20
> What is "something other"?  Where are they located?  Why would
> the firmware interface know or care anything about this?
>=20

fcc bit and some other data retrieved from daemon which=20
communicating with cellular modem.

> > 3) If manufacture XYZ create new device with its own storage
> > format of calibration data this means that correct solution
> > for XYZ is also to implement new kernel fs driver for its
> > own format.
>=20
> Yes, as it is doing it's own custom thing, why overload an
> existing interface to do something it was never designed to
> do?
>=20
> > Do you really want to have in kernel all those drivers for
> > all different (proprietary) storage formats?
>=20
> Yes, we are not afraid of lots of different drivers.  That is
> not even a valid argument, you know better than this :)
>=20
> > 4) It does not help us with existence of generic file
> > /lib/firmware/ti-connectivity/wl1251-nvs.bin which comes
> > from linux-firmware.git tree.
>=20
> Again, not an issue.  If you don't want that file in the repo,
> ask for it to be removed, and it will be, just send a patch
> to do it.
>=20
> greg k-h

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1606789.mnJHGJHFWa
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSGE2gACgkQi/DJPQPkQ1LQRQCgk2B5ZOAScxF0ImASD/Ovbx5U
g/wAoK8+bUl/BHPdkuqNVb/G785LK7FP
=ZFpA
-----END PGP SIGNATURE-----

--nextPart1606789.mnJHGJHFWa--
