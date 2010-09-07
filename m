From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PROBLEM] ipw2200: WARNING: at kernel/softirq.c:143
	local_bh_enable+0x58/0x80()
Date: Tue, 7 Sep 2010 10:34:13 +0000
Message-ID: <20100907103412.GA8999@ff.dom.local>
References: <AANLkTi=BBQL5cS6Ox8MGiy+Pun56xtEhakJxeLwx9UnW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=BBQL5cS6Ox8MGiy+Pun56xtEhakJxeLwx9UnW-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2010-09-05 17:11, Pekka Enberg wrote:
> Hi,
> 
> This showed up in dmesg:
> 
> [  143.695527] ------------[ cut here ]------------
> [  143.695550] WARNING: at kernel/softirq.c:143 local_bh_enable+0x58/0x80()
> [  143.695557] Hardware name: 2373KYG
> [  143.695562] Modules linked in: ipw2200 libipw
> [  143.695577] Pid: 4112, comm: NetworkManager Not tainted 2.6.36-rc2+ #182
> [  143.695584] Call Trace:
> [  143.695596]  [<c15b8ddc>] ? printk+0x18/0x1a
> [  143.695610]  [<c1033fbd>] warn_slowpath_common+0x6d/0xa0
> [  143.695620]  [<c1039568>] ? local_bh_enable+0x58/0x80
> [  143.695630]  [<c1039568>] ? local_bh_enable+0x58/0x80
> [  143.695640]  [<c103400b>] warn_slowpath_null+0x1b/0x20
> [  143.695650]  [<c1039568>] local_bh_enable+0x58/0x80
> [  143.695662]  [<c1482d25>] netif_rx+0x155/0x180
> [  143.695677]  [<f807519c>] libipw_rx+0x55c/0xad0 [libipw]
> [  143.695703]  [<f816f86a>] ipw_handle_data_packet+0x12a/0x260 [ipw2200]

Hi,
Here is the thread:

http://www.spinics.net/lists/netdev/msg139731.html

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
