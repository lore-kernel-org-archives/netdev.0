From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: alloc skb based on a given data buffer
Date: Tue, 15 Sep 2009 01:33:21 -0700 (PDT)
Message-ID: <20090915.013321.07006714.davem@davemloft.net>
References: <1252897270.5650.169.camel@debian>
	<20090914130612.GA11778@csn.ul.ie>
	<1253003420.7549.51.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, assaf.krauss-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253003420.7549.51.camel@debian>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Tue, 15 Sep 2009 16:30:20 +0800

> This way, device drivers can allocate the Rx buffers with their own size
> and alignment requirement. i.e. do an order-1 page allocation directly
> with free_pages() in the iwlagn driver for a 256 bytes aligned 8K Rx
> buffer. After DMA is finished, drivers can use the above function to
> assemble an skb based on the Rx buffer. It should resolve the problem
> for requiring an order-2 allocation by alloc_skb() in the first place.

You can create paged RX skbs just like drivers such as niu.c
and others already do, there is no need for special APIs for
this.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
