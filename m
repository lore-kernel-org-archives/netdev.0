From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: Resurrecting due to huge ipoib perf regression - [BUG] skb
 corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jul 2016 17:14:23 -0600
Message-ID: <20160707231423.GA21039@obsidianresearch.com>
References: <CAL1RGDV3u4bzuyGkMZGJQOiXje_qVh7AA-2nJMm2J2TR60H72g@mail.gmail.com>
 <CAKgT0UerNfn9Uas34y6_+Fa4ALCcToQvNdbEkH1erVosa=xvXg@mail.gmail.com>
 <CAL1RGDVgjRcb23jQQqJ4W-dfm8OkiH6n7hktVLX4mo-oUGj4gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL1RGDVgjRcb23jQQqJ4W-dfm8OkiH6n7hktVLX4mo-oUGj4gA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 07, 2016 at 03:01:40PM -0700, Roland Dreier wrote:

> The reason we moved to the cb storage is that in the past, trying to
> hide some data in the actual skb buffer that we don't actually send

We have neighbour_priv, and ndo_neigh_construct/destruct now ..

A first blush that would seem to be enough to let ipoib store the AH
and other path information in the neigh and avoid the cb? At least the
example in clip sure looks like what ipoib needs to do.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
