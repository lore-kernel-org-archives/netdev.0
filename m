From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed
 port numbers
Date: Thu, 04 Feb 2010 10:21:13 -0800 (PST)
Message-ID: <20100204.102113.267879565.davem@davemloft.net>
References: <201002041444.01897.opurdila@ixiacom.com>
	<20100204.094110.64247447.davem@davemloft.net>
	<201002042015.51092.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201002042015.51092.opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Octavian Purdila <opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 4 Feb 2010 20:15:51 +0200

> int inet_is_reserved_local_port(int port)
> {
> 	if (test_bit(port, reserved_ports))
> 		return 1;
> 	return 0;
> }
> 
> In theory it might be slower because of the reserved_ports bitmap will have a 
> larger memory footprint than just a min/max, especially with random port 
> allocation. But is this an issue in practice?

No need to speculate, some simple benchmarks would confirm or deny
this.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
