From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next] net: dpaa: remove init which already done in
 per-cpu allocation
Date: Mon, 30 Oct 2017 05:08:28 +0000
Message-ID: <DB3PR0402MB3849E758B1A2AD5FEF80DC27EC590@DB3PR0402MB3849.eurprd04.prod.outlook.com>
References: <1509241724-16997-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0077.outbound.protection.outlook.com ([104.47.0.77]:60782
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751568AbdJ3FIc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 01:08:32 -0400
In-Reply-To: <1509241724-16997-1-git-send-email-cugyly@163.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuan,

Can you please give more details about this change you are proposing?

Regards,
Madalin

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of yuan linyu
> Sent: Sunday, October 29, 2017 3:49 AM
> To: netdev@vger.kernel.org
> Cc: David S . Miller <davem@davemloft.net>; yuan linyu
> <Linyu.Yuan@alcatel-sbell.com.cn>
> Subject: [PATCH net-next] net: dpaa: remove init which already done in
> per-cpu allocation
>=20
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>=20
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> ---
>  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 ----
>  1 file changed, 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> index a8d0be8..1ccc316 100644
> --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> @@ -2814,10 +2814,6 @@ static int dpaa_eth_probe(struct platform_device
> *pdev)
>  		err =3D -ENOMEM;
>  		goto free_dpaa_fqs;
>  	}
> -	for_each_possible_cpu(i) {
> -		percpu_priv =3D per_cpu_ptr(priv->percpu_priv, i);
> -		memset(percpu_priv, 0, sizeof(*percpu_priv));
> -	}
>=20
>  	priv->num_tc =3D 1;
>  	netif_set_real_num_tx_queues(net_dev, priv->num_tc *
> DPAA_TC_TXQ_NUM);
> --
> 2.7.4
>=20
