From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
 drivers
Date: Sun, 28 Feb 2010 00:16:28 -0800 (PST)
Message-ID: <20100228.001628.48507956.davem@davemloft.net>
References: <20100227.040502.182574085.davem@davemloft.net>
	<51f3faa71002271015i7c9ec45j18381b1269bfd799@mail.gmail.com>
	<20100228033706G.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100228033706G.fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date: Sun, 28 Feb 2010 03:38:19 +0900

> When I proposed such approach (always use swiotlb) before, IIRC,
> the objections were:
> 
> - better to make allocation respect dma_mask. (I don't think that this
>   approach is possible since we don't know which device handles data
>   later when we allocate memory).

And such objects might end up being processed by multiple devices with
different DMA restrictions.

> - swiotlb is not good for small systems since it allocates too much
>   memory (we can fix this though).

Indeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
