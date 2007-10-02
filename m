From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 14:21:32 -0700
Message-ID: <20071002212132.GF29944@bitmover.com>
References: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org> <20071002.133322.52193802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, lm@bitmover.com,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43950 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755381AbXJBVVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:21:33 -0400
Content-Disposition: inline
In-Reply-To: <20071002.133322.52193802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We fixed a lot of bugs in TSO last year.
> 
> It would be really great to see numbers with a more recent kernel
> than 2.6.18

More data, sky2 works fine (really really fine, like 79MB/sec) between
Linux dylan.bitmover.com 2.6.18.1 #5 SMP Mon Oct 23 17:36:00 PDT 2006 i686
Linux steele 2.6.20-16-generic #2 SMP Sun Sep 23 18:31:23 UTC 2007 x86_64

So this is looking like a e1000 bug.  I'll try to upgrade the kernel on 
the ia64 box and see what happens.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
