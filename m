From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: ieee80211_get_channel exported twice
Date: Fri, 28 Mar 2008 00:47:53 -0700 (PDT)
Message-ID: <20080328.004753.36505184.davem@davemloft.net>
References: <20080328004353.7ae30fe4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080328004353.7ae30fe4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date: Fri, 28 Mar 2008 00:43:53 -0700

> 
> ia64 allmodconfig says:
> 
> WARNING: net/wireless/cfg80211: 'ieee80211_get_channel' exported twice. Previous export was in net/ieee80211/ieee80211.ko
> 
> net/ieee80211/ieee80211_geo.c already has an exported ieee80211_get_channel().
> 
> net-2.6.26 adds a new version of ieee80211_get_channel() in
> net/wireless/util.c and exports that as well.

It's fixed in the net-2.6.26 tree as of this afternoon.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
