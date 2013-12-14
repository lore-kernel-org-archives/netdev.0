From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/3] can: mcp251x: Convert driver to use common clk framework
Date: Sat, 14 Dec 2013 14:18:21 +0100
Message-ID: <52AC5A9D.3010703@pengutronix.de>
References: <1384332144-15211-1-git-send-email-shc_work@mail.ru> <528340A7.9080708@pengutronix.de> <20131214091507.35557bcf132c885cfba69008@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="iCLSvHLgRmuMSIhaXwCub6i9wLvBE99jE"
Cc: Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-can@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sascha Hauer <kernel@pengutronix.de>,
	Eric Miao <eric.y.miao@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>, dbaryshkov@gmail.com
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20131214091507.35557bcf132c885cfba69008@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iCLSvHLgRmuMSIhaXwCub6i9wLvBE99jE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/14/2013 06:15 AM, Alexander Shiyan wrote:
> On Wed, 13 Nov 2013 10:04:39 +0100
> Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>=20
>> as this series adds device tree bindings, please add
>> devicetree@vger.kernel.org on Cc for the whole series.
>>
>> On 11/13/2013 09:42 AM, Alexander Shiyan wrote:
>>> This patch converts mcp251x driver to using common clk framework
>>> for getting input frequency. The change was made for the preparation
>>> of the driver work with the devicetree. As a result private header
>>> for the driver is eliminated.
>>> Additionally, all existing users of the driver was converted to use
>>> this feature.
>>>
>>> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
>>
>> Looks good from my point of view. I'll take the whole series via the
>> linux-can tree, if there are no objections. I'd like to have the pxa a=
nd
>> imx maintainer's Ack and an Ack from the DT list.
>>
>> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
>=20
> Ping. Resend?

Is Dmitry's comment still valid?

PXA does not employ COMMON_CLK yet (WIP locally, but it is not finished
yet), so clk_register_fixed() will probably fail.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--iCLSvHLgRmuMSIhaXwCub6i9wLvBE99jE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKsWqEACgkQjTAFq1RaXHOSLQCff6Srpy4oFdvJzJR4x62dLm0P
1YYAnj+XEjR7rkUhWPvAAl7gGaugX4uo
=SR8H
-----END PGP SIGNATURE-----

--iCLSvHLgRmuMSIhaXwCub6i9wLvBE99jE--
