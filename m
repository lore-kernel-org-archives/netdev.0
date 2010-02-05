From: Octavian Purdila <opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Fri, 5 Feb 2010 14:05:53 +0200
Message-ID: <201002051405.54029.opurdila@ixiacom.com>
References: <201002031312.48531.opurdila@ixiacom.com> <201002042015.51092.opurdila@ixiacom.com> <4B6BA272.4090405@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B6BA272.4090405-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 05 February 2010 06:45:38 you wrote:

> Again, using bitmap algorithm is not a problem and it's better, the
> problem is sysctl interface, how would you plan to interact with users
> via sysctl/proc if you use bitmap to handle this? I would like to hear
> more details about this.
> 

We could use something like positive values for setting and negative for reset 
(e.g. 3 would set the port in the bitmap and -3 would reset it).

But we would need new sysctl and proc handlers to handle the bitmap case (e.g. 
sysctl_bitmap, proc_dobitmap_minmax).
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
