From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH v2 3/3] net/fec: add imx6q enet support
Date: Wed, 21 Sep 2011 13:32:39 +0200
Message-ID: <20110921113239.GF1966@pengutronix.de>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-4-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Bqc0IY4JZZt50bUr"
Cc: "David S. Miller" <davem@davemloft.net>, patches@linaro.org,
	netdev@vger.kernel.org,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-arm-kernel@lists.infradead.org,
	Lothar =?iso-8859-15?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52495 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab1IULcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:32:42 -0400
Content-Disposition: inline
In-Reply-To: <1316603432-20032-4-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Bqc0IY4JZZt50bUr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> +/* Controller has GBIT support */
> +#define FEC_QUIRK_HAS_GBIT		(1 << 3)

Heh, this is not really a quirk, but a nice feature :) I think we can
drop QUIRK if we see driver_data more as "flags" instead of "quirks"?
Minor, though.

>  MODULE_DEVICE_TABLE(of, fec_dt_ids);
> @@ -373,6 +383,7 @@ fec_restart(struct net_device *ndev, int duplex)
>  	int i;
>  	u32 temp_mac[2];
>  	u32 rcntl =3D OPT_FRAME_SIZE | 0x04;
> +	u32 ecntl =3D 0x2; /* ETHEREN */

Also minor, but the patch looks like a good oportunity to start
replacing magic values with proper defines?

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--Bqc0IY4JZZt50bUr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk55y1cACgkQD27XaX1/VRs0twCgt1XAQHO8qUyNxRDEBsQ0futm
Q/8AoMabx4KZdpKcE40rz3cFUY+fAHvZ
=36o1
-----END PGP SIGNATURE-----

--Bqc0IY4JZZt50bUr--
