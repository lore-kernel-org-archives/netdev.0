From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] iwl4965: Fix a memory leak in error handling code of
 __il4965_up
Date: Mon, 11 Jan 2016 13:16:10 +0100
Message-ID: <20160111121610.GF25015@redhat.com>
References: <1452392363-3600-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1452392363-3600-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 10:19:23AM +0800, Jia-Ju Bai wrote:
> diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
> index 6656215..fd7b5c7 100644
> --- a/drivers/net/wireless/iwlegacy/4965-mac.c
> +++ b/drivers/net/wireless/iwlegacy/4965-mac.c
> @@ -5577,6 +5577,7 @@ __il4965_up(struct il_priv *il)
>  	ret = il4965_hw_nic_init(il);
>  	if (ret) {
>  		IL_ERR("Unable to init nic\n");
> +		il_dealloc_bcast_stations(il);
>  		return ret;
>  	}

Please do not repost patches so frequent and if you repost
the unchanged patch mark it so i.e. [PATCH repost].

Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
