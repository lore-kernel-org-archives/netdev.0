From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 3/3] i2400m-sdio: select IWMC3200TOP in Kconfig
Date: Tue, 22 Sep 2009 17:44:04 -0700
Message-ID: <1253666644.2931.7.camel@localhost.localdomain>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-3-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-4-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253662724-16497-4-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tomas,

> i2400m-sdio requires iwmc3200top for its operation
> 
> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wimax/i2400m/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
> index d623b3d..7368ad5 100644
> --- a/drivers/net/wimax/i2400m/Kconfig
> +++ b/drivers/net/wimax/i2400m/Kconfig
> @@ -25,6 +25,7 @@ config WIMAX_I2400M_SDIO
>  	tristate "Intel Wireless WiMAX Connection 2400 over SDIO"
>  	depends on WIMAX && MMC
>  	select WIMAX_I2400M
> +	select IWMC3200TOP
>  	help
>  	  Select if you have a device based on the Intel WiMAX
>  	  Connection 2400 over SDIO.

this is not true actually. Since the WiMAX hardware in my laptop doesn't
require the top driver.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
