From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net-next] net/macb: sqe_test_errors are TX errors, not
 RX errors
Date: Fri, 10 Apr 2015 16:12:10 +0200
Message-ID: <5527DA3A.6030105@atmel.com>
References: <1428658976-28050-1-git-send-email-wsteinwender@pcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Wolfgang Steinwender <wsteinwender@pcs.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:25794 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932412AbbDJONF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 10:13:05 -0400
In-Reply-To: <1428658976-28050-1-git-send-email-wsteinwender@pcs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/04/2015 11:42, Wolfgang Steinwender a =E9crit :
> The statistics are grouped by TX and RX errors.
> The SQE Test Errors Register indicates problems with TX.
>=20
> Signed-off-by: Wolfgang Steinwender <wsteinwender@pcs.com>

seems okay:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 448a323..9f53872 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1956,12 +1956,12 @@ static struct net_device_stats *macb_get_stat=
s(struct net_device *dev)
>  			    hwstat->rx_oversize_pkts +
>  			    hwstat->rx_jabbers +
>  			    hwstat->rx_undersize_pkts +
> -			    hwstat->sqe_test_errors +
>  			    hwstat->rx_length_mismatch);
>  	nstat->tx_errors =3D (hwstat->tx_late_cols +
>  			    hwstat->tx_excessive_cols +
>  			    hwstat->tx_underruns +
> -			    hwstat->tx_carrier_errors);
> +			    hwstat->tx_carrier_errors +
> +			    hwstat->sqe_test_errors);
>  	nstat->collisions =3D (hwstat->tx_single_cols +
>  			     hwstat->tx_multiple_cols +
>  			     hwstat->tx_excessive_cols);
>=20


--=20
Nicolas Ferre
