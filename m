From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 2/14] net: axienet: delete unneeded test before
	of_node_put
Date: Fri, 8 Aug 2014 12:44:59 +0200
Message-ID: <982aa979-17f6-4f7d-af29-084c2f263652@BY2FFO11FD060.protection.gbl>
References: <1407492475-26283-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kernel-janitors@vger.kernel.org>,
	John Linn <John.Linn@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	=?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>
To: Julia Lawall <Julia.Lawall@lip6.fr>,
	Anirudha Sarangi <anirudh@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407492475-26283-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/08/2014 12:07 PM, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> Of_node_put supports NULL as its argument, so the initial test is not
> necessary.
>=20
> Suggested by Uwe Kleine-K=C3=B6nig.
>=20
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
>=20
> // <smpl>
> @@
> expression e;
> @@
>=20
> -if (e)
>    of_node_put(e);
> // </smpl>
>=20
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> ---
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/driv=
ers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 7b0a735..30e8608 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -1630,8 +1630,7 @@ static int axienet_of_remove(struct platform_de=
vice *op)
>  	axienet_mdio_teardown(lp);
>  	unregister_netdev(ndev);
> =20
> -	if (lp->phy_node)
> -		of_node_put(lp->phy_node);
> +	of_node_put(lp->phy_node);
>  	lp->phy_node =3D NULL;
> =20
>  	iounmap(lp->regs);
>=20

Reviewed-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal
