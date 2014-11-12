From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH] net: pxa168_eth: move SET_NETDEV_DEV a bit earlier
Date: Wed, 12 Nov 2014 14:34:45 +0100
Message-ID: <20141112133445.GC18559@kwain>
References: <1415790527-6494-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, antoine.tenart@free-electrons.com,
	arnd@arndb.de, sebastian.hesselbarth@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415790527-6494-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jisheng,

On Wed, Nov 12, 2014 at 07:08:47PM +0800, Jisheng Zhang wrote:
> This is to ensure the net_device's dev.parent is set before we used i=
t
> in dma_zalloc_coherent() from init_hash_table().

Applies on top of net-next.

>=20
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

=46WIW,

Acked-by: Antoine Tenart <antoine.tenart@free-electrons.com>

> ---
>  drivers/net/ethernet/marvell/pxa168_eth.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/=
ethernet/marvell/pxa168_eth.c
> index 21ddece..38f7cee 100644
> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> @@ -1540,8 +1540,8 @@ static int pxa168_eth_probe(struct platform_dev=
ice *pdev)
>  	if (err)
>  		goto err_free_mdio;
> =20
> -	pxa168_init_hw(pep);
>  	SET_NETDEV_DEV(dev, &pdev->dev);
> +	pxa168_init_hw(pep);
>  	err =3D register_netdev(dev);
>  	if (err)
>  		goto err_mdiobus;
> --=20
> 2.1.3
>=20

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
