From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PROBLEM]: potential unaligned memory access in
 drivers/usb/gadget/rndis.c
Date: Fri, 13 Mar 2009 13:52:16 -0700 (PDT)
Message-ID: <20090313.135216.19807120.davem@davemloft.net>
References: <3848726.1723791236775868071.JavaMail.root@spooler2-g27.priv.proxad.net>
	<20090311235119.f4609775.akpm@linux-foundation.org>
	<1236901897.4036.1.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, yann.poupet-GANU6spQydw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1236901897.4036.1.camel@brick>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 12 Mar 2009 16:51:37 -0700

> On Wed, 2009-03-11 at 23:51 -0700, Andrew Morton wrote:
> 
> > Maybe the below fixed this?  afacit it is queued for 2.6.30 in the
> > net-next tree: 
> > 
> > commit 35c26c2cf6a6a2d1c48add732d8ba002bd90784c
> > Author:     Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > AuthorDate: Sat Feb 14 22:56:56 2009 -0800
> > Commit:     David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > CommitDate: Sat Feb 14 22:56:56 2009 -0800
> > 
> >     rndis: remove private wrapper of __constant_cpu_to_le32
> >     
> >     Use cpu_to_le32 directly as it handles constant folding now, replace direct
> >     uses of __constant_cpu_to_{endian} as well.
> >     
> >     Signed-off-by: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >     Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> >     Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > 
> 
> Doubtful, this patch should be a no-op, any alignment problems that existed
> before will still be there.

Agreed, that patch won't do anything wrt. the alignment issue being
reported here.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
