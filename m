From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Wed, 23 Jul 2008 13:55:30 -0700 (PDT)
Message-ID: <20080723.135530.63039342.davem@davemloft.net>
References: <20080723114914.GF4561@ff.dom.local>
	<20080723.131607.79681752.davem@davemloft.net>
	<20080723204335.GA14788@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080723204335.GA14788-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 23 Jul 2008 22:43:35 +0200

> On Wed, Jul 23, 2008 at 01:16:07PM -0700, David Miller wrote:
> ...
> > There will always be a need for a "stop all the TX queues" operation.
> 
> The question is if the current way is "all correct". As a matter of
> fact I think Peter's doubts could be justified: taking "USHORT_MAX"
> locks looks really dubious (so maybe it's not so strange lockdep
> didn't get used to this).

There are, of course, potentially other ways to achieve the objective.

And for non-multiqueue aware devices (which is the vast majority of
the 400 or so networking drivers we have) there is only one queue and
thus one lock taken.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
