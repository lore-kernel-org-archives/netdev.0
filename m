From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V1 net-next] IB/ipoib: Fix ndo_get_iflink
Date: Fri, 17 Apr 2015 15:21:33 -0400 (EDT)
Message-ID: <20150417.152133.1818018053733533978.davem@davemloft.net>
References: <1429191274-11600-1-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429191274-11600-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Thu, 16 Apr 2015 16:34:34 +0300

> Currently, iflink of the parent interface was always accessed, even 
> when interface didn't have a parent and hence we crashed there.
> 
> Handle the interface types properly: for a child interface, return
> the ifindex of the parent, for parent interface, return its ifindex.
> 
> For child devices, make sure to set the parent pointer prior to
> invoking register_netdevice(), this allows the new ndo to be called
> by the stack immediately after the child device is registered.
> 
> Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
> Reported-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
