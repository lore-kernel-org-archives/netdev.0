From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH 31/31] CAPI: Officially claim char major 191
Date: Sat, 23 Jan 2010 14:13:35 +0100
Message-ID: <4B5AF5FF.6050702@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>	 <445e1bf881b6f8b6a5886d6eee70f6435a5619d6.1264201408.git.jan.kiszka@web.de>	 <20100123122430.5a078b4a@lxorguk.ukuu.org.uk> <1264250892.3469.52.camel@violet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig64C0F6C8F6B9EEC14775D2D7"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755480Ab0AWNNr@vger.kernel.org>
In-Reply-To: <1264250892.3469.52.camel@violet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig64C0F6C8F6B9EEC14775D2D7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Marcel Holtmann wrote:
> Hi Alan,
>=20
>>> I found no trace of this mysterious "pcl181" device, neither in-tree =
nor
>>> out there in the wild. At the same time, the in-tree CAPI middleware =
is
>>> using major 191 for many years now and obviously without any conflict=
=2E
>>> Let's officially claim this major number.
>> This is not the way it should have been done but whoever needs spankin=
g
>> got away with it years ago. Given that this seems the best way forward=
=2E
>>
>> With LANANA hat on
>=20
> actually in the days of udev, the capifs is not really needed anymore.
> The right choice would be to remove it. I haven't been enabling it sinc=
e
> years.

First of all, the capifs story is orthogonal to the major claim.

But basically you are right, capifs is likely not needed anymore. The
only user visible change - and that was holding me back to suggest its
removal - is the time when the NCCI minor ttys show up under /dev/capi/
(or wherever you direct them to). If I didn't miss something about udev,
it will make all possible minors pop up once the major is registered.
However, I'm not sure if there is some userland actually relying on this.=


Jan


--------------enig64C0F6C8F6B9EEC14775D2D7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEUEARECAAYFAkta9gMACgkQitSsb3rl5xQJzwCg5XSeY79DUfnbksivaf+P11oV
VLIAmKF9AZx5eLoFAW8ztsiUpiiQwvE=
=XSl9
-----END PGP SIGNATURE-----

--------------enig64C0F6C8F6B9EEC14775D2D7--
