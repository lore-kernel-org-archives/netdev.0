From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] stmmac: re-add IFF_UNICAST_FLT for dwmac1000
Date: Wed, 04 Apr 2012 09:33:42 +0200
Message-ID: <4F7BF956.4030301@pengutronix.de>
References: <1333475057-3752-1-git-send-email-mkl@pengutronix.de> <1333477224.18626.289.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3B1C6A1E966A34B302D604C2"
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55053 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124Ab2DDHd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 03:33:58 -0400
In-Reply-To: <1333477224.18626.289.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3B1C6A1E966A34B302D604C2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/03/2012 08:20 PM, Eric Dumazet wrote:
> On Tue, 2012-04-03 at 19:44 +0200, Marc Kleine-Budde wrote:
>> In commit (bfab27a stmmac: add the experimental PCI support) the
>> IFF_UNICAST_FLT flag has been removed from the stmmac_mac_device_setup=
()
>> function. This patch re-adds the flag.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> ---
>>
>> Just compile time tested, since I don't have the hardware.
>> Applies to net-next/master (and v3.3).
>>
>> regards, Marc
>>
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
>>  1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drive=
rs/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index e85ffbd..07e0c78 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1737,9 +1737,10 @@ static int stmmac_hw_init(struct stmmac_priv *p=
riv)
>>  	struct mac_device_info *mac;
>> =20
>>  	/* Identify the MAC HW device */
>> -	if (priv->plat->has_gmac)
>> +	if (priv->plat->has_gmac) {
>> +		priv->dev->priv_flags |=3D IFF_UNICAST_FLT;
>>  		mac =3D dwmac1000_setup(priv->ioaddr);
>> -	else
>> +	} else
>>  		mac =3D dwmac100_setup(priv->ioaddr);
>>  	if (!mac)
>>  		return -ENOMEM;
>=20
>=20
> 	if (priv->plat->has_gmac) {
> 		priv->dev->priv_flags |=3D IFF_UNICAST_FLT;
> 		mac =3D dwmac1000_setup(priv->ioaddr);
> 	} else {
> 		mac =3D dwmac100_setup(priv->ioaddr);
> 	}
>=20
> (Documentation/CodingStyle line 175)

Thanks for the hint.

Marc



--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3B1C6A1E966A34B302D604C2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk97+VkACgkQjTAFq1RaXHNt6gCcDJf5gSDtzf4gOhddjnL2DM0y
6d8An3wxKwFh+S0av4MIMtj834UVh0LQ
=CS6h
-----END PGP SIGNATURE-----

--------------enig3B1C6A1E966A34B302D604C2--
