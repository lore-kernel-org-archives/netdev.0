From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 2/2] net: macb: Fix multi queue support for xilinx ZynqMP
 soc
Date: Fri, 6 Mar 2015 17:55:23 +0100
Message-ID: <54F9DBFB.3020504@atmel.com>
References: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com> <364d36c03e63ef33c5f52a8eaa4418320c6c0d3f.1425560649.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	<netdev@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <364d36c03e63ef33c5f52a8eaa4418320c6c0d3f.1425560649.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/03/2015 14:04, Michal Simek a =E9crit :
> From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com=
>
>=20
> ZynqMP soc has single interrupt for all the queue events. So,
> passing the IRQF_SHARED flag for interrupt registration call.
>=20
> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Ok then:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>=20
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 24b1eb466e52..0493c3e6bbbe 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2319,7 +2319,7 @@ static int macb_probe(struct platform_device *p=
dev)
>  		 */
>  		queue->irq =3D platform_get_irq(pdev, q);
>  		err =3D devm_request_irq(&pdev->dev, queue->irq, macb_interrupt,
> -				       0, dev->name, queue);
> +				       IRQF_SHARED, dev->name, queue);
>  		if (err) {
>  			dev_err(&pdev->dev,
>  				"Unable to request IRQ %d (error %d)\n",
>=20


--=20
Nicolas Ferre
