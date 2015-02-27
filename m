From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net-next 2/2] net: netcp: select davinci_mdio driver by
 default
Date: Fri, 27 Feb 2015 08:29:22 -0800
Message-ID: <20150227162921.GX11056@atomide.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
 <1424813251-31610-2-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mugunthanvnm@ti.com, george.cherian@ti.com,
	prabhakar.csengg@gmail.com, varkabhadram@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, lokeshvutla@ti.com, mpa@pengutronix.de,
	w-kwok2@ti.com
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424813251-31610-2-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Murali Karicheri <m-karicheri2@ti.com> [150224 13:31]:
> Keystone netcp driver re-uses davinci mdio driver. So enable it
> by default for keystone netcp driver.
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> ---
>  drivers/net/ethernet/ti/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index 3bc992c..945a221 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -88,6 +88,7 @@ config TI_CPTS
>  config TI_KEYSTONE_NETCP
>  	tristate "TI Keystone NETCP Core Support"
>  	select TI_CPSW_ALE
> +	select TI_DAVINCI_MDIO
>  	depends on OF
>  	depends on KEYSTONE_NAVIGATOR_DMA && KEYSTONE_NAVIGATOR_QMSS
>  	---help---

These options should be silent Kconfig options if we're selecting
them. Or else you should use depends on instead.

In general using select for driver modules will eventually lead into
randconfig build failures as things change.

Regards,

Tony
