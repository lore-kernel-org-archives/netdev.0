From: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 1/3] mfd: max8998: Remove CONFIG_OF around
 max8998_dt_match
Date: Wed, 12 Apr 2017 08:59:21 +0100
Message-ID: <20170412075921.m3yszzgayyd25iws@dell>
References: <20170412044156.17351-1-f.fainelli@gmail.com>
 <20170412044156.17351-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        Nicolas Ferre <nicolas.ferre-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170412044156.17351-2-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Apr 2017, Florian Fainelli wrote:

> A subsequent patch is going to make of_match_node() an inline stub when
> CONFIG_OF is disabled which will properly take care of having the compiler
> eliminate the variable. To avoid more #ifdef/#else, just always make the match
> table available.
> 
> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/mfd/max8998.c | 2 --
>  1 file changed, 2 deletions(-)

If it works, great!

For my own reference:
  Acked-for-MFD-by: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
  
> diff --git a/drivers/mfd/max8998.c b/drivers/mfd/max8998.c
> index 4c33b8063bc3..372f681ec1bb 100644
> --- a/drivers/mfd/max8998.c
> +++ b/drivers/mfd/max8998.c
> @@ -129,14 +129,12 @@ int max8998_update_reg(struct i2c_client *i2c, u8 reg, u8 val, u8 mask)
>  }
>  EXPORT_SYMBOL(max8998_update_reg);
>  
> -#ifdef CONFIG_OF
>  static const struct of_device_id max8998_dt_match[] = {
>  	{ .compatible = "maxim,max8998", .data = (void *)TYPE_MAX8998 },
>  	{ .compatible = "national,lp3974", .data = (void *)TYPE_LP3974 },
>  	{ .compatible = "ti,lp3974", .data = (void *)TYPE_LP3974 },
>  	{},
>  };
> -#endif
>  
>  /*
>   * Only the common platform data elements for max8998 are parsed here from the

-- 
Lee Jones
Linaro STMicroelectronics Landing Team Lead
Linaro.org │ Open source software for ARM SoCs
Follow Linaro: Facebook | Twitter | Blog
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
