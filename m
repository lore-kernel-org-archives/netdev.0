From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/2] remove CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
Date: Mon, 24 Jul 2006 15:44:15 -0700
Message-ID: <ada4px6ipxc.fsf@cisco.com>
References: <20060707091008.GB2543@lst.de>
	<20060724.153044.10246226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:13211 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932313AbWGXWoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:44:17 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060724.153044.10246226.davem@davemloft.net> (David Miller's message of "Mon, 24 Jul 2006 15:30:44 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> skbuff.h has an #ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB to allow
> architectures to reimplement __dev_alloc_skb.  It's not set on any
> architecture and now that we have an architecture-overrideable
> NET_SKB_PAD there is not point at all to have one either.

I missed this when hch first posted it, sorry.

But my impression was that the intent of the config option was to let
Xen hook __dev_alloc_skb() to allocate special receive skbs to handle
their page-flipping virtual network device.  Which goes beyond
NET_SKB_PAD.

So the real question is about Xen hooks I guess -- and given where the
rest of Xen is, it probably does make sense to go ahead and strip this
out.

 - R.
