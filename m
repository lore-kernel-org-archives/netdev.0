From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues
 once we know the correct value
Date: Mon, 20 Sep 2010 20:54:27 +0200
Message-ID: <1285008867.2323.60.camel@edumazet-laptop>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
	 <1285008239.2282.110.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52981 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab0ITSyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:54:35 -0400
Received: by wwj40 with SMTP id 40so5617wwj.1
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 11:54:33 -0700 (PDT)
In-Reply-To: <1285008239.2282.110.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 19:43 +0100, Ben Hutchings a =C3=A9cr=
it :
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index 4a1c93f..48e2bf4 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -1315,6 +1315,7 @@ static int efx_probe_nic(struct efx_nic *efx)
> =20
>  	efx_set_channels(efx);
>  	efx->net_dev->real_num_tx_queues =3D efx->n_tx_channels;
> +	efx->net_dev->num_rx_queues =3D efx->n_rx_channels;
> =20
>  	/* Initialise the interrupt moderation settings */
>  	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true=
);
> --=20
> 1.7.2.1
>=20
>=20
>=20

Interesting, but why ?

No other driver does this AFAIK...



