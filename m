From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6 0/7] can: kvaser_usb: Leaf bugfixes and USBCan-II support
Date: Mon, 26 Jan 2015 11:56:16 +0100
Message-ID: <54C61D50.4070308@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150126051755.GA3014@Darwish.PC> <54C611DA.8050500@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="TSf1iFhNlrmbdx5HSwX5o4NwmDEStvQmk"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54C611DA.8050500@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TSf1iFhNlrmbdx5HSwX5o4NwmDEStvQmk
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/26/2015 11:07 AM, Marc Kleine-Budde wrote:
> On 01/26/2015 06:17 AM, Ahmed S. Darwish wrote:
>> Hi!
>>
>> This is an updated patch series for the Kvaser CAN/USB devices:
>>
>> 1- Extra patches are now added to the series. Most importantly
>> patch #1 which fixes a critical `sleep in atomic context' bug
>> in the current upstream driver. Patch #2 fixes a corruption in
>> the kernel logs, also affecting current upstream driver. Patch
>> #4 was originally USBCan-II only, but since it's a generic fix,
>> it's now retrofitted to the Leaf-only upstream driver first.
>>
>> 2- The series has been re-organized so that patches #1 -> #4
>> inclusive can go to linux-can/origin, while the rest can move
>> to -next.
>>
>> 3- There are some important updates regarding the USBCan-II
>> error counters, and how really erratic their heaviour is. All
>> the new details are covered at the bottom of this URL:
>>
>> 	http://article.gmane.org/gmane.linux.can/7481
>>
>> 4- Attached below is the new candump traces. Now
>> `back-to-error-active' states appear _if_ the hardware was
>> kind enough and decreased the error counters appropriately.
>> The earlier code did not recognize the error counters going
>> down, thus the `back-to-error-active' transitions did not
>> appear.
>=20
> For patches 5-7 I'm waiting for an Acked by Andri.

Applied to can-next, it's available as can-next-testing in the
linux-can-next repo.

Marc.

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--TSf1iFhNlrmbdx5HSwX5o4NwmDEStvQmk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUxh1RAAoJECte4hHFiupUFckP/3A0Uenfy3Ojg3MAkZorBgt9
lxhm9gG/ITFXhkRXVZVDADOSvYkJLhw5ozfC4G/1FAYVATCfVDOY7ZGil+ofboZz
DytAPU60VWRQAOnXbNmQ2gu7prQK3YmQhSvSSimMjC59CYBs9OyIDPQ8FNjy3s1Y
SQyMJPtB7CDmyA+X72kMeSa0Zz3kg9FTWpVN9a1RdMtnqudUliPiKbuiWinBe3fg
F//MHzLIUpbGxxHpexq7LV/JDEv0FUMdTr2M62tw3Sabcl85wMLIQDrpKqbt546s
1idPWueeUA91LBY9Em9pJsfGUOB+VF+gd9REMu4n4/FElseYJ4vfo2QM8g0ujfq9
TCmganZGIagZre081uyoueBmVMA6LuGRPEY2YjZLN7LL6bfjJcMOIv7wCnJEJYeW
uHfWkOvP4+wWZ5Q0fIRVh78R7/tcfwGotQFWvYz5gKX6omJZGAtbtEj0rP1hq3Pd
M0Z1ZFUSCZJmqkZfwIn3j0KWsOvSRhNKn4Ll0bNt10Z4J63liuFAo77GZUpP0qyH
DO8UZchJthYKBho5Zwq3pDRghF2PvIne8QiDM8jWiXzqGOnWGcpDG0VIIwVcrDGV
r0vDhuDp2Ag6tRFjJCE7MSi5QeyUOlJq+yt0H5lRf53JUp15GFkVE5XGia7ozrc+
83o/JyqvuAlt25k7nPlf
=9rdA
-----END PGP SIGNATURE-----

--TSf1iFhNlrmbdx5HSwX5o4NwmDEStvQmk--
