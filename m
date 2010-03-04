From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Thu, 04 Mar 2010 00:52:46 -0800 (PST)
Message-ID: <20100304.005246.240968829.davem@davemloft.net>
References: <20100303200510.17531s9x98zyvwm8@hayate.sektori.org>
	<20100303180956.GC2760@psychotron.redhat.com>
	<20100304.004150.129762672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jussi.kivilinna-E01nCVcF24I@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100304.004150.129762672.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Thu, 04 Mar 2010 00:41:50 -0800 (PST)

> From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 3 Mar 2010 19:09:56 +0100
> 
>> Here's corrected patch:
>> 
>> Subject: [net-2.6 PATCH] rndis_wlan: correct multicast_list handling V2
>> 
>> My previous patch (655ffee284dfcf9a24ac0343f3e5ee6db85b85c5) added locking in
>> a bad way. Because rndis_set_oid can sleep, there is need to prepare multicast
>> addresses into local buffer under netif_addr_lock first, then call
>> rndis_set_oid outside. This caused reorganizing of the whole function.
>> 
>> Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Reported-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> 
> Applied.

Jiri did ou even type make on this patch?  The 'size' is still
referenced:

drivers/net/wireless/rndis_wlan.c: In function 'set_multicast_list':
drivers/net/wireless/rndis_wlan.c:1530: error: 'size' undeclared (first use in this function)
drivers/net/wireless/rndis_wlan.c:1530: error: (Each undeclared identifier is reported only once
drivers/net/wireless/rndis_wlan.c:1530: error: for each function it appears in.)

I reverted, and I'm pissed off.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
