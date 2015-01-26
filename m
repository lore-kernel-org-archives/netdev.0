From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6 0/7] can: kvaser_usb: Leaf bugfixes and USBCan-II support
Date: Mon, 26 Jan 2015 10:55:31 +0100
Message-ID: <54C60F13.5040104@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150126051755.GA3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="OgiWu4PWPcHviuUHdTiJ3iKTenCI7BwD6"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150126051755.GA3014@Darwish.PC>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OgiWu4PWPcHviuUHdTiJ3iKTenCI7BwD6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/26/2015 06:17 AM, Ahmed S. Darwish wrote:
> Hi!
>=20
> This is an updated patch series for the Kvaser CAN/USB devices:
>=20
> 1- Extra patches are now added to the series. Most importantly
> patch #1 which fixes a critical `sleep in atomic context' bug
> in the current upstream driver. Patch #2 fixes a corruption in
> the kernel logs, also affecting current upstream driver. Patch
> #4 was originally USBCan-II only, but since it's a generic fix,
> it's now retrofitted to the Leaf-only upstream driver first.
>=20
> 2- The series has been re-organized so that patches #1 -> #4
> inclusive can go to linux-can/origin, while the rest can move
> to -next.

Applied 1-4 to can/master, I'm adding stable on Cc before sending a
pull-request to David.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OgiWu4PWPcHviuUHdTiJ3iKTenCI7BwD6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUxg8WAAoJECte4hHFiupUJVwP/1nce41HvqiZB0ISlwYTzELI
EjWwnlBF+ePEZTyuYmyqriPlrZaE8TamLQxYwcVmdw4y01BoRZVSAG1jovqqtgYd
1oOeJMG5lCniJGPLmaxatQvsxyj+/WeB0OciwcoR9GYlyFfybJQa8q/dCtMzNosy
fy45Y6neoHsQyegHHqMNV8p5avm/KA1LIpKIafq7iVA+fV7au5ijFAR89SZGoC6D
pXBiRfyCC7NwcLstRej9k/MxSWxGviWspW/J2Y4Y5yjFOfAOMrxItX7ZVIaRuRpP
its4yDDr8TzRFcpcwTiHzkPY8D8+DXf1JwgaPoV4m2EnLXLNHTRHLkI6lxb5pXmm
9REf3yrbNTSqHay83fkL9pHotRG3NwCSqwiJqG2TqLoPiAGKZnyJl1CpynZL4uSp
n4IAk2yIyyt/NcHSGPFifRvLmgW6ZWeMO/gq59AqkBoz+FS0dHbq8dsJUEEmoqTa
pOIjJxW4GaHPQoTywFgwykxBZGiJEdt5IH7sn8lfAsB/G2yrvTXiet+G5QsqUQkI
YVtit+ck0irhf+s1V3nBWlUtxBNIbUu1nyFLKRtNYwTw5Kg6UCuXXE5X33F3WhXU
wVD6F+Sai/IKYVcPdsDoigRWBqBv1pgU3i0nMLMgOCRlx5MwK90Uj3FTxjviNe1O
ROPRdJeeiB+ApdqUe4dV
=o3CA
-----END PGP SIGNATURE-----

--OgiWu4PWPcHviuUHdTiJ3iKTenCI7BwD6--
