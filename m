From: Wang Weidong <wangweidong1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wireless: fix build warning of used uninitialized variable
Date: Fri, 6 Dec 2013 19:10:44 +0800
Message-ID: <52A1B0B4.9060703@huawei.com>
References: <52A15777.5000508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52A15777.5000508-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013/12/6 12:49, Wang Weidong wrote:
> nl80211.c: In function __cfg80211_wdev_from_attrs
> nl80211.c:77: warning: wdev_id may be used uninitialized in this function
> 

Sorry. My complier version is too low so that I got this warning.
Just ignore it.

Regards.
Wang

> Signed-off-by: Wang Weidong <wangweidong1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  net/wireless/nl80211.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 138dc3b..6894229 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -74,7 +74,7 @@ __cfg80211_wdev_from_attrs(struct net *netns, struct nlattr **attrs)
>  	struct wireless_dev *result = NULL;
>  	bool have_ifidx = attrs[NL80211_ATTR_IFINDEX];
>  	bool have_wdev_id = attrs[NL80211_ATTR_WDEV];
> -	u64 wdev_id;
> +	u64 wdev_id = 0;
>  	int wiphy_idx = -1;
>  	int ifidx = -1;
>  
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
