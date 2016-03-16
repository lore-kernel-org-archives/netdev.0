From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/5] net: macb: Fix coding style error message
Date: Wed, 16 Mar 2016 14:39:39 +0100
Message-ID: <56E9621B.3090204@atmel.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-2-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:33585 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbcCPNjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:39:32 -0400
In-Reply-To: <1457896247-25934-2-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/03/2016 20:10, Moritz Fischer a =E9crit :
> checkpatch.pl gave the following error:
>=20
> ERROR: space required before the open parenthesis '('
> +	for(; p < end; p++, offset +=3D 4)
>=20
> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>


> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 50c9410..4370f37 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -496,7 +496,7 @@ static void macb_update_stats(struct macb *bp)
> =20
>  	WARN_ON((unsigned long)(end - p - 1) !=3D (MACB_TPF - MACB_PFR) / 4=
);
> =20
> -	for(; p < end; p++, offset +=3D 4)
> +	for (; p < end; p++, offset +=3D 4)
>  		*p +=3D bp->macb_reg_readl(bp, offset);
>  }
> =20
>=20


--=20
Nicolas Ferre
