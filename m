From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 2/4] net: stmmac: adding multiple buffers for rx
Date: Tue, 4 Apr 2017 21:23:18 +0200
Message-ID: <20170404192317.GE24271@ulmo.ba.sec>
References: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
 <4f35e9a73521ba4ab4868c75950166fb757b5f8a.1491328304.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="T6xhMxlHU34Bk0ad"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:3673 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753243AbdDDTXY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 15:23:24 -0400
In-Reply-To: <4f35e9a73521ba4ab4868c75950166fb757b5f8a.1491328304.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--T6xhMxlHU34Bk0ad
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 04, 2017 at 06:54:25PM +0100, Joao Pinto wrote:
[...]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/=
net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
> @@ -3402,6 +3474,9 @@ static irqreturn_t stmmac_interrupt(int irq, void *=
dev_id)
> =20
>  		if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
>  			for (queue =3D 0; queue < queues_count; queue++) {
> +				struct stmmac_rx_queue *rx_q =3D
> +				&priv->rx_queue[queue];

Found one more: the indentation here looks wrong. I think it's more
idiomatic to indent by at least a tab in such cases.

> +
>  				status |=3D
>  				priv->hw->mac->host_mtl_irq_status(priv->hw,
>  								   queue);

This is becoming quite unwieldy because of the indentation levels. Maybe
this could be split out into a separate function. Could be a separate
patch, though.

Thierry

--T6xhMxlHU34Bk0ad
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljj8qUACgkQ3SOs138+
s6HGUg/9HE8cPpmihkE5I7yP5l5Dokw45jvHhfAW47owLxUvy0BzHU1wHOXnDCoG
KaqZW0T0VhzxEfBCTFCfLR34ZaCVv9fecZUeQijYH46eLUKxmT2HXYQ0+vINXith
WKjVmL+72lLNK9QRyVidOucG97hI/jqYmPLDQGMteld9iwek1CtmFtTvOGQcTRbQ
UPte7vCIv1YO8czLEp/UdeHcVCrkjx/OD2thruGEAr6hLA8qVXmzDe75hBh/GDn5
1RYNA6Q4SmZRXk6yfgtF9rpDmXLWLMsbNJR/LR0ntf8EVqUdiB+hshm2bYQD3PEq
Ar2Dfp03hPRT7VDA6luyr+4RY15Ns9JZYep0V3EReZjxpCHj2W/xyS1Sb360+yjD
crtakNP5rgDAk0NDD4uWOfyY8bGJQHHzFeQXV4xakza7MkQ7rZfg4W837d3gxmEH
60hKmepaIzEnMP8SADJBR+RX4oMJjx5TmLL+CBwJazRApBcX/cUMAB9DUYoHWntt
nZscD5y5CNlHul1GMeULwCb/mx7sK5ew0rcp0ZvDRDRW9ZNIGAqEQBoDs3aLJ8sV
j9j5xDzrq5mnDWZhsmWSIAmuJYxmERw8xbu/gCrggrmSRQqmqTDRKhb0KkDGuQ8w
8RAWuQG4Q8+BOxRnrHIRiRKE6ffhLdOXzIYVimjlNhA/ck5UW1o=
=zVsn
-----END PGP SIGNATURE-----

--T6xhMxlHU34Bk0ad--
