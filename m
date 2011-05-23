From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: linux-next: Tree for May 23 (infiniband + netlink)
Date: Mon, 23 May 2011 11:05:59 -0700
Message-ID: <BANLkTindDsbE-Fdr5-Db4Kw6ww+ntk2S2Q@mail.gmail.com>
References: <20110523154518.5e27cfb0.sfr@canb.auug.org.au> <20110523094205.4a5651d2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110523094205.4a5651d2.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2011 at 9:42 AM, Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, 23 May 2011 15:45:18 +1000 Stephen Rothwell wrote:
>
>> Hi all,
>>
>> Changes since 20110520:
>
> when CONFIG_NET is not enabled:
>
> ERROR: "skb_trim" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "netlink_kernel_create" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "netlink_kernel_release" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "netlink_rcv_skb" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "nla_put" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "init_net" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "netlink_dump_start" [drivers/infiniband/core/ib_core.ko] undefined!
> ERROR: "skb_put" [drivers/infiniband/core/ib_core.ko] undefined!

Guess we have to depend on CONFIG_NET now.
I'll fix it up.

Thanks,
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
