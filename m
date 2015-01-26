From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6 5/7] can: kvaser_usb: Update interface state before
 exiting on OOM
Date: Mon, 26 Jan 2015 11:50:12 +0100
Message-ID: <54C61BE4.8070105@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150126051755.GA3014@Darwish.PC> <20150126052039.GB3014@Darwish.PC> <20150126052254.GC3014@Darwish.PC> <20150126052406.GD3014@Darwish.PC> <20150126052543.GE3014@Darwish.PC> <20150126052719.GF3014@Darwish.PC> <20150126102843.17894.84372@shannon>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HhotTsnSxVTEcMWmE346UJcbg8uGaeSrP"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andri Yngvason <andri.yngvason@marel.com>,
	"Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150126102843.17894.84372@shannon>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HhotTsnSxVTEcMWmE346UJcbg8uGaeSrP
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/26/2015 11:28 AM, Andri Yngvason wrote:
> Quoting Ahmed S. Darwish (2015-01-26 05:27:19)
>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>
>> Update all of the can interface's state and error counters before
>> trying any skb allocation that can actually fail with -ENOMEM.
>>
>> Suggested-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>> ---
>>  drivers/net/can/usb/kvaser_usb.c |  181 ++++++++++++++++++++++-------=
---------
>>  1 files changed, 105 insertions(+), 76 deletions(-)
[..]

> Looks good to me.

Can I add your Acked-by to 5-7?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--HhotTsnSxVTEcMWmE346UJcbg8uGaeSrP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUxhvpAAoJECte4hHFiupURm0P/RoHDtCC3lfTVSjW5MlHe/Z/
CyU/xuqwaJar1TON+/D8EQXqVLL3bV2CWoj0FQpfKjKuTxylrqenRxwj+YD3dEIt
NErjVVNiQc3445tPJVFc0bJoqpmFB+20XemYUMKSC4aNbWHgVfHFdda3kkTVynyL
mnnokF26pdDGi54IuYZ3IyNkkNR6tVmr6iTxVgBU6LF5/2bgRnfcGglAJxk5CaA3
vkjmECWMFdxVxQENym2i56PgYrYm9k/HvvF+yMg8+gEXrI5Vxoyd3sfUhjI8kmT8
1ZfVVpTQTnr/XpAVy9INpS0yymVFTJmJkQdjg9oniUt/XyRtnkC1Xrhcr2EIL1HS
Unk4Uu2C+goq76DhrQ2enVxwBm5DG3T69qt9FDlHZIWaXwqErSRAsaBzpVqBU2uM
zfGS3TbztOT0MgQKWQhtIY9bHqCjDrqfR8Il4anww9TVzKBPF1lSafJEaLiThTKN
i+ZZnInltxYTR8Ql/Kt1rk9kJplF9eVhd1m4TLdlIpUgA3FlrcwrZCZb/Wg1asFG
AAlsaiy7qc2qn3xO0Y4AF4DY+MyLn+d/giZX6fLeHwLjTCfxWiAqPRNcWK0vpd50
zDkbGsU1yyAxXobAmW4vx2jFH9935xa9HIGH6UregWvk+OueeqE3cRgEfEx9oeTj
Tl9A9SNaqxGjnC7/gFc3
=0KwO
-----END PGP SIGNATURE-----

--HhotTsnSxVTEcMWmE346UJcbg8uGaeSrP--
