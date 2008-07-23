From: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Subject: Re: WARNING: at net/core/dev.c:1328!
Date: Wed, 23 Jul 2008 07:40:39 +0200
Message-ID: <20080723054039.GA2272@gentoox2.trippelsdorf.de>
References: <d4b984a30807210914nd4d0db5yb7b93ca5143ff0d5@mail.gmail.com> <20080721.092027.14394005.davem@davemloft.net> <d4b984a30807220254t1aaf6ac4q874329966511b0c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alessandro Guido <ag-CnKWz401HL/3u/SXJKErtNrkRsMOXBsj@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d4b984a30807220254t1aaf6ac4q874329966511b0c5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 22, 2008 at 11:54:26AM +0200, Alessandro Guido wrote:
> Got a WARNING this morning (2.6.26-05752-g93ded9b) and I think it's related.

Same thing here (latest git):

skge eth1: enabling interface
skge eth1: disabling interface
------------[ cut here ]------------
WARNING: at net/core/dev.c:1344 __netif_schedule+0x24/0x6d()
Pid: 1904, comm: ip Not tainted 2.6.26-06077-gc010b2f #33

Call Trace:
 [<ffffffff8022e5f4>] warn_on_slowpath+0x4c/0x87
 [<ffffffff802fc5cb>] delay_tsc+0x0/0x55
 [<ffffffff802fc5cb>] delay_tsc+0x0/0x55
 [<ffffffff802fc5e7>] delay_tsc+0x1c/0x55
 [<ffffffff8037e2ee>] gm_phy_write+0x50/0x90
 [<ffffffff8037e2f8>] gm_phy_write+0x5a/0x90
 [<ffffffff8037f03f>] skge_led+0x1fb/0x20b
 [<ffffffff804202e8>] __netif_schedule+0x24/0x6d
 [<ffffffff80381298>] skge_down+0x440/0x4cf
 [<ffffffff803814be>] skge_change_mtu+0x3d/0x61
 [<ffffffff80420775>] dev_set_mtu+0x46/0x79
 [<ffffffff80427a51>] do_setlink+0x1c5/0x31f
 [<ffffffff804287d3>] rtnl_newlink+0x2b9/0x3e3
 [<ffffffff804285a8>] rtnl_newlink+0x8e/0x3e3
 [<ffffffff80428d69>] rtnetlink_rcv_msg+0x5a/0x1ea
 [<ffffffff80428d0f>] rtnetlink_rcv_msg+0x0/0x1ea
 [<ffffffff8042efde>] netlink_rcv_skb+0x34/0x7e
 [<ffffffff80428d09>] rtnetlink_rcv+0x1f/0x25
 [<ffffffff8042eb97>] netlink_unicast+0x119/0x17f
 [<ffffffff8041b35d>] __alloc_skb+0x61/0x123
 [<ffffffff8042ee37>] netlink_sendmsg+0x23a/0x24d
 [<ffffffff804152e4>] sock_sendmsg+0xcb/0xe3
 [<ffffffff8023f670>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80225643>] need_resched+0x1e/0x28
 [<ffffffff804147d8>] move_addr_to_kernel+0x25/0x36
 [<ffffffff8041c090>] verify_iovec+0x46/0x82
 [<ffffffff80415513>] sys_sendmsg+0x217/0x28a
 [<ffffffff8042e01e>] netlink_insert+0xfe/0x121
 [<ffffffff80414b40>] sockfd_lookup_light+0x1a/0x52
 [<ffffffff80261fe5>] __vma_link+0x58/0x61
 [<ffffffff80262062>] vma_link+0x74/0x99
 [<ffffffff802630ce>] do_brk+0x2c1/0x319
 [<ffffffff8020b3eb>] system_call_after_swapgs+0x7b/0x80

---[ end trace 92936ef183e09876 ]---
skge eth1: enabling interface
skge eth1: Link is up at 100 Mbps, full duplex, flow control both

-- 
Markus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
