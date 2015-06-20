From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/3] rcar_can: print signed IRQ #
Date: Sat, 20 Jun 2015 18:02:19 +0200
Message-ID: <55858E8B.9000801@pengutronix.de>
References: <2010452.WyFito6egU@wasted.cogentembedded.com>
 <2390389.thI8mIvbv5@wasted.cogentembedded.com>
 <CAMuHMdWZFKR04NJc7xtnPUosYuosX9FPDJopG3wovu_GqGxSOw@mail.gmail.com>
 <55857AD3.4040000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lQpXtkO3WU2FppTVeAi6IeK2808SouQuX"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55857AD3.4040000@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lQpXtkO3WU2FppTVeAi6IeK2808SouQuX
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/20/2015 04:38 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 6/20/2015 3:03 PM, Geert Uytterhoeven wrote:
>=20
>>> Printing IRQ # using "%x" and "%u" unsigned formats isn't quite corre=
ct as
>>> 'ndev->irq' is of  type *int*, so  the "%d" format  needs to be used =
instead.
>=20
>>> While fixing this, beautify the dev_info() message in rcar_can_probe(=
) a bit.
>=20
>> If you change the message, why don't you make it consistent
>> ("interrupt" vs. "IRQ")?
>=20
>     I decided to change the message in a follow-up patch (posted afterw=
ards).

Please squash you patches, so that you don't modify code (or error
messages) that you've added in a previous patch.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--lQpXtkO3WU2FppTVeAi6IeK2808SouQuX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJVhY6PAAoJEP5prqPJtc/H9s8IAIPp0G3jxJIrU7MEi+GRwMmV
sSzDSHYyYHysx/CE3LGD3P/3seXNTH9uJNK/U8SmVcFR2TqORz1KipygR6j/tthw
gAE86eWUZUc1wRx9anauM4i8LLMPrPUa/r8dlE7zyFg+MExwwOi+8KrBK+MP8nzb
i2gDKAlbcHLuNax8lK4NG2mtcXfMOQJPhjARqF9rZFDyAa4CPHWx1EV+s2BISsNq
8/1GDZgumRVFOR8cP5eCkdMZn9lCO6hAdpLty77WR+TAJywkcmUMYlh02R0txNtp
kfO0HOkzr4hlO7O6355SbKTEdkOCDNMiZ4nxoL74U7eiYjHLecrIdhkZqwjGRu0=
=xl8/
-----END PGP SIGNATURE-----

--lQpXtkO3WU2FppTVeAi6IeK2808SouQuX--
--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
