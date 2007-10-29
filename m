From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Oops in 2.6.21-rc4, 2.6.23
Date: Mon, 29 Oct 2007 14:13:48 +0100
Message-ID: <20071029131348.GA2999@ff.dom.local>
References: <20071015173956.6c554387@beavis.confused.org> <20071029084232.GA2280@ff.dom.local> <20071029.014147.56411400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: darko.koruga@siol.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:51871 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752654AbXJ2NKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 09:10:20 -0400
Content-Disposition: inline
In-Reply-To: <20071029.014147.56411400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 01:41:47AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Mon, 29 Oct 2007 09:42:32 +0100
> 
> > I hope you've found this by yourself by now, but:
> > 
> > 1. These are warnings only - not oopses.
> > 2. It seems this patch you've found to be responsible for this all
> > slightly changes some limits, which is not necessarily wrong; the
> > lucky thing is you can change these limits with sysctl or some
> > echos to /proc/sys/net/ipv4/tcp_mem, I presume. (Or more safely by
> > adding some memory.)
> 
> Actually, this was caused by a real bug in the SKB_WITH_OVERHEAD macro
> definition, which Herbert Xu quickly spotted and fixed.

But, since Darko has found this other patch matters for him too, maybe
there could be more than one cause to 'blame' for such differences
from 2.6.20 (maybe it's not all yet) - especially if it's all around
some limits.

> 
> Which "I hope you've found this by yourself by now".
> 

I think it's unfair! Darko got 2 weeks for thinking about this all...

Thanks,
Jarek P.
