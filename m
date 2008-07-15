From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 02:28:54 -0700 (PDT)
Message-ID: <20080715.022854.55875400.davem@davemloft.net>
References: <1215769627.3483.107.camel@johannes.berg>
	<20080715.021637.103260952.davem@davemloft.net>
	<1216113923.3535.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216113923.3535.14.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 15 Jul 2008 11:25:23 +0200

> > It seems to me that a simple synchronize_net() call near the end of
> > agg queue removal would solve your problem as-is, wouldn't it?
> 
> Well, as far as I can tell we can't do that there because it's in
> tasklet context/called under spinlocks so it has to be atomic. I think.

Right, my bad.

It seems that there can end up being holes in the queue
space on mac80211, which slightly complicates matters.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
