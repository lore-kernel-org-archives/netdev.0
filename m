From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 12:55:58 +0200
Message-ID: <E1KLyUI-0006ZS-Cg@pomaz-ex.szeredi.hu>
References: <1216890648.7257.258.camel@twins> <20080724.023210.229338550.davem@davemloft.net> <1216894136.7257.266.camel@twins> <200807242038.36693.nickpiggin@yahoo.com.au>
Cc: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <200807242038.36693.nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org> (message from Nick
	Piggin on Thu, 24 Jul 2008 20:38:35 +1000)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Jul 2008, Nick Piggin wrote:
> Hey, something kind of cool (and OT) I've just thought of that we can
> do with ticket locks is to take tickets for 2 (or 64K) nested locks,
> and then wait for them both (all), so the cost is N*lock + longest spin,
> rather than N*lock + N*avg spin.

Isn't this deadlocky?

E.g. one task takes ticket x=1, then other task comes in and takes x=2
and y=1, then first task takes y=2.  Then neither can actually
complete both locks.

Miklos
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
