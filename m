From: Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: rfkill: convert net/rfkill/* to use
 module_platform_driver()
Date: Mon, 28 Nov 2011 11:09:47 -0800
Message-ID: <1322507387.3888.1.camel@rklein-linux2>
References: <1322471704.2730.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Axel Lin <axel.lin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322471704.2730.1.camel@phoenix>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-28 at 01:15 -0800, Axel Lin wrote:
> This patch converts the drivers in net/rfkill/* to use the
> module_platform_driver() macro which makes the code smaller and a bit
> simpler.
> 
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Cc: Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
> Cc: Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Axel Lin <axel.lin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/rfkill/rfkill-gpio.c      |   13 +------------
>  net/rfkill/rfkill-regulator.c |   12 +-----------
>  2 files changed, 2 insertions(+), 23 deletions(-)
> 
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index 128677d..ca355e7 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -220,18 +220,7 @@ static struct platform_driver rfkill_gpio_driver = {
>  	},
>  };
>  
> -static int __init rfkill_gpio_init(void)
> -{
> -	return platform_driver_register(&rfkill_gpio_driver);
> -}
> -
> -static void __exit rfkill_gpio_exit(void)
> -{
> -	platform_driver_unregister(&rfkill_gpio_driver);
> -}
> -
> -module_init(rfkill_gpio_init);
> -module_exit(rfkill_gpio_exit);
> +module_platform_driver(rfkill_gpio_driver);
>  
>  MODULE_DESCRIPTION("gpio rfkill");
>  MODULE_AUTHOR("NVIDIA");

Gpio part looks good to me.

Acked-by: Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
