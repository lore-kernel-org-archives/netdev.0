From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] libertas: fix for wireless Kconfig changes
Date: Tue, 01 May 2007 07:53:38 -0400
Message-ID: <1178020418.21671.3.camel@localhost.localdomain>
References: <20070429002844.GA11225@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070429002844.GA11225-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-04-28 at 20:28 -0400, John W. Linville wrote:
> Need to change the libertas Kconfig entry to match changes made for
> other wireless drivers.
> 
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> ---
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> index c4b3dc2..cb09e6b 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -267,7 +267,7 @@ config IPW2200_DEBUG
>  
>  config LIBERTAS_USB
>  	tristate "Marvell Libertas 8388 802.11a/b/g cards"
> -	depends on NET_RADIO && USB
> +	depends on USB && WLAN_80211
>  	select FW_LOADER
>  	---help---
>  	  A driver for Marvell Libertas 8388 USB devices.

Will apply, we need to pull in wireless-dev first to get the NET_RADIO
name change.

Dan
