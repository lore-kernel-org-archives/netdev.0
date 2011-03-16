From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 10:38:57 -0700 (PDT)
Message-ID: <20110316.103857.226773145.davem@davemloft.net>
References: <20110316065008.GA2780@psychotron.redhat.com>
	<20110316.000251.189704695.davem@davemloft.net>
	<20110316073803.GB2780@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
To: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110316073803.GB2780-YzwxZg+R7et1/kRsl7OVgNvLeJWuRmrY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 16 Mar 2011 08:38:03 +0100

> Wed, Mar 16, 2011 at 08:02:51AM CET, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org wrote:
>>From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>Date: Wed, 16 Mar 2011 07:50:09 +0100
>>
>>>>Jiri, I know there is your patch set there, but I think you and Changli
>>>>still need to go back and forth one more time wrt. orig_dev semantics.
>>>>Since you have been posting this patch set for some time I'm still
>>>>willing to apply it for this merge window, but please make haste and
>>>>work out the remaining discussion.  Thank you.
>>> 
>>> Dave, you can apply the rest of the series and leave only the first
>>> patch (af_packet) out. There's no dependency. We will figure out things
>>> around origdev later.
>>
>>I was about to do that but I've found other problems.
>>
>>You cannot make the modifications you make to linux/if.h, those
>>interface flags are visible to userspace.
> 
> What do you suggest? To remove unused flags and leave gaps there or to
> not to remove the flags at all?

You can't remove them, otherwise if it happened to be reference in the
sources to some app out there, it will start to fail to compile.

This is pretty obvious stuff, I hope :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
