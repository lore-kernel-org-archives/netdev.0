From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/3] iwmc3200wifi: select IWMC3200TOP in Kconfig
Date: Tue, 29 Sep 2009 17:22:43 +0800
Message-ID: <1254216163.3731.36.camel@debian>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-3-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Perez-Gonzalez, Inaky" <inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Kao, Cindy H" <cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Cohen, Guy" <guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Rindjunsky, Ron" <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Winkler, Tomas" <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253662724-16497-3-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-09-23 at 07:38 +0800, Winkler, Tomas wrote:
> iwmc3200wifi requires iwmc3200top  for its operation
> 
> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Acked-by: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Thanks,
-yi

> ---
>  drivers/net/wireless/iwmc3200wifi/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwmc3200wifi/Kconfig b/drivers/net/wireless/iwmc3200wifi/Kconfig
> index c62da43..69faaf1 100644
> --- a/drivers/net/wireless/iwmc3200wifi/Kconfig
> +++ b/drivers/net/wireless/iwmc3200wifi/Kconfig
> @@ -3,6 +3,7 @@ config IWM
>  	depends on MMC && WLAN_80211 && EXPERIMENTAL
>  	depends on CFG80211
>  	select FW_LOADER
> +	select IWMC3200TOP
>  	help
>  	  The Intel Wireless Multicomm 3200 hardware is a combo
>  	  card with GPS, Bluetooth, WiMax and 802.11 radios. It

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
