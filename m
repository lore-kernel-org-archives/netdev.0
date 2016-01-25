From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 2/3] net: macb: fix build warning
Date: Mon, 25 Jan 2016 09:45:36 +0100
Message-ID: <56A5E0B0.4070802@atmel.com>
References: <1453702389-601-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453702389-601-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 25/01/2016 07:13, Sudip Mukherjee a =E9crit :
> We are getting build warning about:
> macb.c:2889:13: warning: 'tx_clk' may be used uninitialized in this f=
unction
> macb.c:2888:11: warning: 'hclk' may be used uninitialized in this fun=
ction
>=20
> In reality they are not used uninitialized as clk_init() will initial=
ize
> them, this patch will just silence the warning.
>=20
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks for your patch.

Bye,

> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 9d9984a..50c9410 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2823,7 +2823,7 @@ static int macb_probe(struct platform_device *p=
dev)
>  	struct device_node *np =3D pdev->dev.of_node;
>  	struct device_node *phy_node;
>  	const struct macb_config *macb_config =3D NULL;
> -	struct clk *pclk, *hclk, *tx_clk;
> +	struct clk *pclk, *hclk =3D NULL, *tx_clk =3D NULL;
>  	unsigned int queue_mask, num_queues;
>  	struct macb_platform_data *pdata;
>  	bool native_io;
>=20


--=20
Nicolas Ferre
