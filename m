From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] drivers: net: davinci_mdio: use builtin_platform_driver
Date: Wed, 23 Nov 2016 11:22:32 -0600
Message-ID: <00cc7fb8-6c2f-16ae-c589-bd9ad5bd7beb@ti.com>
References: <055763562f90fd7e2d311308e1d731ba93c3eea9.1479912302.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <055763562f90fd7e2d311308e1d731ba93c3eea9.1479912302.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/23/2016 08:45 AM, Geliang Tang wrote:
> Use builtin_platform_driver() helper to simplify the code.

Not sure about this. We do support this driver to be a module.

>
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  drivers/net/ethernet/ti/davinci_mdio.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 33df340..b3f0a12 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -536,11 +536,7 @@ static struct platform_driver davinci_mdio_driver = {
>  	.remove = davinci_mdio_remove,
>  };
>
> -static int __init davinci_mdio_init(void)
> -{
> -	return platform_driver_register(&davinci_mdio_driver);
> -}
> -device_initcall(davinci_mdio_init);
> +builtin_platform_driver(davinci_mdio_driver);
>
>  static void __exit davinci_mdio_exit(void)
>  {
>

-- 
regards,
-grygorii
