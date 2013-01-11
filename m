From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3] net, wireless: overwrite default_ethtool_ops
Date: Fri, 11 Jan 2013 15:59:36 -0800 (PST)
Message-ID: <20130111.155936.1799008114956712424.davem@davemloft.net>
References: <20130111091909.GA2347@redhat.com>
	<1357934432.2643.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357934432.2643.4.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Date: Fri, 11 Jan 2013 20:00:32 +0000

> On Fri, 2013-01-11 at 10:19 +0100, Stanislaw Gruszka wrote:
>> Since:
>> 
>> commit 2c60db037034d27f8c636403355d52872da92f81
>> Author: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> Date:   Sun Sep 16 09:17:26 2012 +0000
>> 
>>     net: provide a default dev->ethtool_ops
>> 
>> wireless core does not correctly assign ethtool_ops.
>> 
>> After alloc_netdev*() call, some cfg80211 drivers provide they own
>> ethtool_ops, but some do not. For them, wireless core provide generic
>> cfg80211_ethtool_ops, which is assigned in NETDEV_REGISTER notify call:
>> 
>>         if (!dev->ethtool_ops)
>>                 dev->ethtool_ops = &cfg80211_ethtool_ops;
>> 
>> But after Eric's commit, dev->ethtool_ops is no longer NULL (on cfg80211
>> drivers without custom ethtool_ops), but points to &default_ethtool_ops.
>> 
>> In order to fix the problem, provide function which will overwrite
>> default_ethtool_ops and use it by wireless core.
>> 
>> Signed-off-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> [...]
> 
> Acked-by: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
