From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] skge: resolve tx multiqueue bug
Date: Wed, 23 Jul 2008 15:30:00 -0700 (PDT)
Message-ID: <20080723.153000.172383135.davem@davemloft.net>
References: <20080723101827.GA2236@gentoox2.trippelsdorf.de>
	<20080723140347.GA2245@gentoox2.trippelsdorf.de>
	<48874C6A.1020604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org, ag-CnKWz401HL/3u/SXJKErtNrkRsMOXBsj@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48874C6A.1020604-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Wed, 23 Jul 2008 23:21:14 +0800

> Markus Trippelsdorf said the following on 2008-7-23 22:03:
> > On Wed, Jul 23, 2008 at 12:18:27PM +0200, Markus Trippelsdorf wrote:
> >> On Wed, Jul 23, 2008 at 04:50:13PM +0800, Wang Chen wrote:
> >>> Markus Trippelsdorf said the following on 2008-7-23 13:40:
> >>>> On Tue, Jul 22, 2008 at 11:54:26AM +0200, Alessandro Guido wrote:
> >>>>> Got a WARNING this morning (2.6.26-05752-g93ded9b) and I think it's related.
> >>>> Same thing here (latest git):
> >>>>
> >>>> skge eth1: enabling interface
> >>>> skge eth1: disabling interface
> >>>> ------------[ cut here ]------------
> >>>> WARNING: at net/core/dev.c:1344 __netif_schedule+0x24/0x6d()
> >>>> Pid: 1904, comm: ip Not tainted 2.6.26-06077-gc010b2f #33
> >>>>  [<ffffffff8020b3eb>] system_call_after_swapgs+0x7b/0x80
> >> ...
> >>>> ---[ end trace 92936ef183e09876 ]---
> >>>> skge eth1: enabling interface
> >>>> skge eth1: Link is up at 100 Mbps, full duplex, flow control both
> >>>>
> >>> Markus, please try this.
> >>>
> >>> - Add netif_start_queue() in ->open()
> >>> - netif_carrier_*() is enough, remove netif_*_queue()
> >> Unfortunately, your patch does not fix this. I still get the same warning.
> >>
> > 
> > This patch works for me:
> 
> Your patch works for me too. So I think it's better than mine. :)
> 
> Tested-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Dave, since Markus and me tested this patch, would you please apply it?

I can't, it's whitespace damaged.  All the tabs are turned into spaces,
also there is no signoff from Markus.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
