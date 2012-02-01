From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 6/6] cls_cgroup: remove redundant rcu_read_lock/unlock
Date: Wed, 01 Feb 2012 02:10:02 -0500 (EST)
Message-ID: <20120201.021002.1399660597996401402.davem@davemloft.net>
References: <4F28E1D1.900@cn.fujitsu.com>
	<4F28E22A.703@cn.fujitsu.com>
	<1328080039.22641.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328080039.22641.2.camel@edumazet-laptop>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 01 Feb 2012 08:07:19 +0100

> Then, I wonder why we do the "if (classid && classid != sk->sk_classid)"
> 
> before the :
> 
> 	sk->sk_classid = classid;
> 
> This seems unnecessary checks.
> 

Avoiding dirtying the sk->sk_classid cache line unnecessarily?

I actually have no idea actually how often this routine can get
invoked in real world scenerios.
