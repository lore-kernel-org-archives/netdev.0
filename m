From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 10:38:52 -0700 (PDT)
Message-ID: <20110316.103852.193714733.davem@davemloft.net>
References: <20110316073803.GB2780@psychotron.redhat.com>
	<20110316084022.GA2845@psychotron.brq.redhat.com>
	<20110316084739.GD26145@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
To: tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110316084739.GD26145-oJAMn8VJQk8CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date: Wed, 16 Mar 2011 04:47:39 -0400

> On Wed, Mar 16, 2011 at 09:40:23AM +0100, Jiri Pirko wrote:
>> >What do you suggest? To remove unused flags and leave gaps there or to
>> >not to remove the flags at all?
>> 
>> Well, the following comment:
>> <quote>
>> /* Private (from user) interface flags (netdevice->priv_flags). */
>> </quote>
>> leads me to think that these flags should not be used by userspace.
>> So maybe it may not be problem to change those values.
> 
> These flags should be moved to linux/netdevice.h

We've had them exposed in a header file without __KERNEL__ protection
for a long time, the cat is therefore out of the bag and it's too late
to just remove them from user visibility as if they were not there.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
