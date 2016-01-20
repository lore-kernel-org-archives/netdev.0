From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 11:54:21 +0100
Message-ID: <569F675D.1070903@pengutronix.de>
References: <1452538083-7331-5-git-send-email-marex@denx.de>
 <1452643156-7291-1-git-send-email-marex@denx.de>
 <569F63C4.4070708@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HeopCKq71ngrlGWPgc8B1cp8ThDlonlej"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:55874 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934706AbcATKye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 05:54:34 -0500
In-Reply-To: <569F63C4.4070708@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HeopCKq71ngrlGWPgc8B1cp8ThDlonlej
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 11:39 AM, Marc Kleine-Budde wrote:
>> +/* IFI CANFD private data structure */
>> +struct ifi_canfd_priv {
>> +	struct can_priv		can;	/* must be the first member */
>> +	struct napi_struct	napi;
>> +	struct net_device	*ndev;
>> +	struct device		*device;
>=20
> Nitpick: This variable is write only, correct? I can fix this while
> applying the patch.
>=20
>> +	void __iomem		*base;
>> +};
>=20
> Otherweise looks good.

Until compiling:

> drivers/net/can/ifi_canfd/ifi_canfd.c:486:40: warning: cast truncates b=
its from constant value (ffffffff7ffffffd becomes 7ffffffd)
> drivers/net/can/ifi_canfd/ifi_canfd.c:640:9: warning: cast truncates bi=
ts from constant value (ffffffff7fffffff becomes 7fffffff)
> drivers/net/can/ifi_canfd/ifi_canfd.c:676:9: warning: cast truncates bi=
ts from constant value (ffffffff7fffffff becomes 7fffffff)

target is ARMv5 with gcc version 4.9.2, compiled with C=3D2 using sparse
v0.5.0.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |



--HeopCKq71ngrlGWPgc8B1cp8ThDlonlej
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn2dfAAoJEP5prqPJtc/Hd7UH/2mIkGlM4dNtvNAvM4pMWQem
gxzD32cuYHPEcgsu7cP8IFoJAG21b+dh3p/HKivkIMvlyocN8ddb8AhfOhprW1gp
V8pXgd2HUvk+J7tEr3qwelNndNspmZt4Zw3YIAbWYq52f6JzkCoyvPa7JISp//Q/
WWB6M/QDTslNXNRg45sZPAIZckGjiBDx4KH2lMFBjVFXnLnwL/2sZ+CRoqyxapGu
V5G7fDbKTO60y/4wJj6syU/DxZUmqVAnNF0YBofwZ91Iv081m4+U8ibqRDNNumRr
w3dcLnfSkbo4OTe30C3P6bpJHWDBXS7K1l6Ah3P/yTEeMTGxvcsZzKHPgUvm93s=
=2qI0
-----END PGP SIGNATURE-----

--HeopCKq71ngrlGWPgc8B1cp8ThDlonlej--
