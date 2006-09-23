From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.1[78] page allocation failure. order:3, mode:0x20
Date: Fri, 22 Sep 2006 22:25:07 -0700 (PDT)
Message-ID: <20060922.222507.74751476.davem@davemloft.net>
References: <20060922004253.2e2e2612.akpm@osdl.org>
	<4514190C.8010901@intel.com>
	<20060922215000.c1fde093.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, Holger.Kiehl@dwd.de,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21648
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751044AbWIWFZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 01:25:08 -0400
To: akpm@osdl.org
In-Reply-To: <20060922215000.c1fde093.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Fri, 22 Sep 2006 21:50:00 -0700

> On Fri, 22 Sep 2006 10:10:36 -0700
> Auke Kok <auke-jan.h.kok@intel.com> wrote:
> 
> > e1000: account for NET_IP_ALIGN when calculating bufsiz
> > 
> > Account for NET_IP_ALIGN when requesting buffer sizes from netdev_alloc_skb to 
> > reduce slab allocation by half.
> 
> Could we please do whatever is needed to get this blessed and merged?  This
> is such a common problem on such a common driver that I would suggest that
> we want this in 2.6.18.x as well.  At least, I'd expect distributors to
> ship this fix (they're nuts if they don't) and so it makes sense to deliver
> it from kernel.org.

The NET_IP_ALIGN existed not just for fun :)  There are ramifications
for removing it.

