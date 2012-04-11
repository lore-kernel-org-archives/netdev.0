From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH 05/10] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Wed, 11 Apr 2012 11:01:35 -0700
Message-ID: <4F85C6FF.1050004@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com> <1334166738-28243-6-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334166738-28243-6-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/2012 10:52 AM, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:
> From: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>
> The signal and noise are forced to be positive since ethtool
> deals in unsigned 64-bit values and this number should be human
> readable.  This gives easy access to some of the data formerly
> exposed in the deprecated /proc/net/wireless file.

> +	if (WARN_ON(i != STA_STATS_LEN)) {
> +		rcu_read_unlock();
> +		return;
> +	}
> +
> +	drv_get_et_stats(sdata, stats,&(data[STA_STATS_LEN]));
> +}
> +

Ahh crap, I missed an rcu_read_unlock here...will fix this
and whatever else folks suggest and repost..but don't apply
this patch as is!

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
