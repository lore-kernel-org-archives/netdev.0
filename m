From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: Reserve skb headroom and set skb->dev
 even if using __alloc_skb
Date: Wed, 13 May 2015 18:07:44 -0400 (EDT)
Message-ID: <20150513.180744.973850573845788118.davem@davemloft.net>
References: <20150513182738.GA28201@saruman.tx.rr.com>
	<20150513203413.8252.98057.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, balbi@ti.com, tony@atomide.com,
	netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933971AbbEMWHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 18:07:49 -0400
In-Reply-To: <20150513203413.8252.98057.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 13 May 2015 13:34:13 -0700

> When I had inlined __alloc_rx_skb into __netdev_alloc_skb and
> __napi_alloc_skb I had overlooked the fact that there was a return in the
> __alloc_rx_skb.  As a result we weren't reserving headroom or setting the
> skb->dev in certain cases.  This change corrects that by adding a couple of
> jump labels to jump to depending on __alloc_skb either succeeding or failing.
> 
> Fixes: 9451980a6646 ("net: Use cached copy of pfmemalloc to avoid accessing page")
> Reported-by: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks.
