From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Fri, 21 Sep 2012 13:24:45 -0400 (EDT)
Message-ID: <20120921.132445.72763806946072284.davem@davemloft.net>
References: <CANn89i+9Th=xVgDgoy7tHwKtLNpOC8rgJkA09nQ1Yf0zvqBw6w@mail.gmail.com>
	<1348147353.2388.19.camel@sauron.fi.intel.com>
	<1348151149.31352.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348151149.31352.109.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 20 Sep 2012 16:25:49 +0200

> Please remove this hack and try the following bugfix in raw handler
> 
> icmp_filter() should not modify skb, or else its caller should not
> assume ip_hdr() is unchanged.

Right, good catch.

Please submit this fix formally Eric, thanks a lot.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
