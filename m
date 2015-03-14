From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 3/3] can: kvaser_usb: Use can-dev
 unregistration mechanism
Date: Sat, 14 Mar 2015 16:55:11 +0100
Message-ID: <550459DF.1050804@pengutronix.de>
References: <20150226152011.GA6075@linux> <20150314130249.GA20796@linux> <20150314130952.GB20796@linux> <20150314131147.GC20796@linux> <55045340.6050908@pengutronix.de> <20150314154122.GB18736@vivalin-002>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="iniKhAAxbfNvNSH5dPbVcElU1uPVjlxEx"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150314154122.GB18736@vivalin-002>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iniKhAAxbfNvNSH5dPbVcElU1uPVjlxEx
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/14/2015 04:41 PM, Ahmed S. Darwish wrote:
> On Sat, Mar 14, 2015 at 04:26:56PM +0100, Marc Kleine-Budde wrote:
>> On 03/14/2015 02:11 PM, Ahmed S. Darwish wrote:
>>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>>
>>> Use can-dev's unregister_candev() instead of directly calling
>>> networking unregister_netdev(). While both are functionally
>>> equivalent, unregister_candev() might do extra stuff in the
>>> future than just calling networking layer unregistration code.
>>
>> Since 2 goes into can, I've applied this into can-next.

> Was this a cherry-pick? Because I was going to send a new
> series with patch #2 better worded, and with a new patch for
> the endiannes issue.

Yes, no need to resend patch #3, as it's already applied to can-next.

regards,
Marc

1 =3D can: kvaser_usb: Fix tx queue start/stop race conditions
2 =3D can: kvaser_usb: Utilize all possible tx URBs
3 =3D can: kvaser_usb: Use can-dev unregistration mechanism
4 =3D the endianess issue

1 =3D is in linux-can and included in linux-can-fixes-for-4.0-20150314
2 =3D will go into linux-can with a better commit message
    which is currently prepare by you
    will be in the next pull request for net
3 =3D is in linux-can-next and will be included in the next pull request
    for net-next
4 =3D is currently prepared by you
    will be in the next pull request for net

This means, you'll send me patches 2 and 4 in a new v5 series. (This
patches will of course have new numbers, 1 and 2.)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--iniKhAAxbfNvNSH5dPbVcElU1uPVjlxEx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVBFniAAoJECte4hHFiupU2tgQAJIjUI3Twth8EWzB9RFsg/i1
htBqQMC76arOpW70sBFOJH+d6aK/k6ogssuEQm9BBI9s0FkOyz4nCl8R6ZoamnKs
3oZX1rnPJTLHW/+efhe1WXvXmrk8Ot/Ekh/WBwF7cMlC+aTFHT0UwyPuz9sol8YE
9XNM0SWLlwFOyfuydawhx9M6xxu7bFHwFaiB/7RLSwGdwQVnAygNwOhescVsW9vB
LN7yLh95rw+URYfejmTo9S3FlT+RlYy/xZmIz42MvZUA610G4E//nOJsZ+FsRu01
u//kRAOKcFvXLLlzHgtOhHaXvsZmsY/p3nkm3XhL3P0NRMhnbtaEoaeHLSk1zXwf
EiDBSbNxXjePHj1cfHvyWtIq9XXl431YjZWKRrbiMtl8OeGSfyiLTO+qX48pK4Bv
SbZawc/60QH/UpAzCbadjYvYwpp+dUVLwYN2hf/F7Hs6XkoO2qSkfJBckZooQgAs
oYrCPJ5KW535lrvo+oYaGUz1cJcBYoB5GmYgrZgCSXU0v6k5wGtGrPSLeKNnkS77
soikVasAYVYLSZrkky+eICuT3nduKHmeqMa76Ua64SI+pCXBO5KSY2oU1Gqwd3r1
GaL5kacMoCZySIBqcDCZO7dF/oJCafzqxOiyeG/Sc6H+UYrEKljtorETq84bz+J6
1gjSgELD2bAKumb9mPi7
=/h1u
-----END PGP SIGNATURE-----

--iniKhAAxbfNvNSH5dPbVcElU1uPVjlxEx--
