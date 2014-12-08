From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Tue, 9 Dec 2014 00:52:50 +0100
Message-ID: <201412090052.50900@pali>
References: <201411271506.20457@pali> <201412090023.18173@pali> <1418082137.31640.14.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1822501.dZCGejN3eR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
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
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418082137.31640.14.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1822501.dZCGejN3eR
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 09 December 2014 00:42:17 Dan Williams wrote:
> On Tue, 2014-12-09 at 00:23 +0100, Pali Roh=C3=A1r wrote:
> > On Monday 08 December 2014 23:51:07 Dan Williams wrote:
> > > Is the CAL data format generic to all wl1251 devices?  Or
> > > is the stuff in the CAL partition Nokia-specific?
> >=20
> > Specific for Nokia devices.
>=20
> Ok, but then something must transform that data into a format
> that the wl1251 chip can consume, correct?  What do other
> wl1251 platforms do to retrieve this information and set
> regulatory region?
>=20
> Dan

It looks like wl1251 driver supports standard way to set=20
regulatory settings. There is application which reads CAL data,=20
cellular network info, ... and sent it to kernel (via Nokia=20
specific netlink interface patch). And binary data which are sent=20
are in same format as file wl1251-nvs.bin. And some bits which=20
deterministically send to kernl depends on fcc.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1822501.dZCGejN3eR
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSGOdIACgkQi/DJPQPkQ1JMVwCfbojo5JPjO0nH/3q17ZEAUyfq
W1EAoICqO/v9eSzdH5a8Dc8YA7slrhUy
=jhZt
-----END PGP SIGNATURE-----

--nextPart1822501.dZCGejN3eR--
