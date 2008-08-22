From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Fri, 22 Aug 2008 04:54:47 -0700 (PDT)
Message-ID: <20080822.045447.208480125.davem@davemloft.net>
References: <48AACC71.5090701@hp.com>
	<48AB87DE.1010205@cn.fujitsu.com>
	<48AC17CA.8010306@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753430AbYHVLyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 07:54:49 -0400
In-Reply-To: <48AC17CA.8010306@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 20 Aug 2008 09:10:34 -0400

> Yang Hongyang wrote:
> > Vlad Yasevich wrote:
> >> We are returning np->daddr, which is the peer address.
> >>
> >> The expected value is "destination of the received packet".  In the worst case,
> >> it should be the locally bound address.  In the correct case, it should be the
> >> address set in the sticky options if such is set.  It really should be 0::0, if there
> >> are no sticky options and no packets have been received.
> > 
> > Since here we do not recive any packet,we should return 
> > src_info.ipi6_ifindex=0 and src_info.ipi6_addr=0::0,right?
> 
> That's what I've done in other implementations.

I'm patiently waiting for a patch to fix this.

Thanks :)
