From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Tue, 13 May 2008 16:39:06 -0400
Message-ID: <20080513203906.GB20269@tuxdriver.com>
References: <20080502.163334.148944203.davem@davemloft.net> <1209807477.3987.9.camel@johannes.berg> <1209824720.1475.6.camel@johannes.berg> <20080512.201751.114868351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080512.201751.114868351.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 12, 2008 at 08:17:51PM -0700, David Miller wrote:

> Based upon them I will adjust LL_MAX_HEADER as follows:

> @@ -93,14 +93,16 @@ struct wireless_dev;
>   *	used.
>   */
>   
> -#if !defined(CONFIG_AX25) && !defined(CONFIG_AX25_MODULE) && !defined(CONFIG_TR)
> -#define LL_MAX_HEADER	32
> +#if defined(CONFIG_WLAN_80211) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)

Is WLAN_80211 really the right symbol here?  It applies to more than
just mac80211, and I doubt if full MAC devices need higher values.
It seems like MAC80211 would be the right symbol to add.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
