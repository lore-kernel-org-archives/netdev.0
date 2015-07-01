From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with NET_IP_ALIGN
Date: Wed, 1 Jul 2015 12:03:23 +0200
Message-ID: <5593BAEB.8030103@atmel.com>
References: <5592D105.7080006@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Nicolae Rosia <nicolae.rosia@certsign.ro>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:51185 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbbGAKEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 06:04:30 -0400
In-Reply-To: <5592D105.7080006@certsign.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/06/2015 19:25, Nicolae Rosia a =C3=A9crit :
>=20
> Signed-off-by: Nicolae Rosia <nicolae.rosia@certsign.ro>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks, bye.

> ---
>  drivers/net/ethernet/cadence/macb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index caeb395..dbb5160 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2554,9 +2554,9 @@ static void at91ether_rx(struct net_device *dev=
)
>  	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
>  		p_recv =3D lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
>  		pktlen =3D MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
> -		skb =3D netdev_alloc_skb(dev, pktlen + 2);
> +		skb =3D netdev_alloc_skb(dev, pktlen + NET_IP_ALIGN);
>  		if (skb) {
> -			skb_reserve(skb, 2);
> +			skb_reserve(skb, NET_IP_ALIGN);
>  			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
> =20
>  			skb->protocol =3D eth_type_trans(skb, dev);
>=20


--=20
Nicolas Ferre
