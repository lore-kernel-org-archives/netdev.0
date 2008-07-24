From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 12:08:56 +0200
Message-ID: <1216894136.7257.266.camel@twins>
References: <1216890648.7257.258.camel@twins>
	 <20080724.022040.23129457.davem@davemloft.net>
	 <1216891625.7257.261.camel@twins>
	 <20080724.023210.229338550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080724.023210.229338550.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-07-24 at 02:32 -0700, David Miller wrote:
> From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Date: Thu, 24 Jul 2008 11:27:05 +0200
> 
> > Well, not only lockdep, taking a very large number of locks is expensive
> > as well.
> 
> Right now it would be on the order of 16 or 32 for
> real hardware.
> 
> Much less than the scheduler currently takes on some
> of my systems, so currently you are the pot calling the
> kettle black. :-)

One nit, and then I'll let this issue rest :-)

The scheduler has a long lock dependancy chain (nr_cpu_ids rq locks),
but it never takes all of them at the same time. Any one code path will
at most hold two rq locks.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
