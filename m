From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 12:33:04 -0700
Message-ID: <20071002193304.GA31611@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <47028DEF.5070009@psc.edu> <20071002190742.GC29944@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Larry McVoy <lm@bitmover.com>, John Heffner <jheffner@psc.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netd
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43769 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753574AbXJBTdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 15:33:09 -0400
Content-Disposition: inline
In-Reply-To: <20071002190742.GC29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More data, we've conclusively eliminated the card / cpu from the mix.
We've got 2 ia64 boxes with e1000 interfaces.  One box is running
linux 2.6.12 and the other is running hpux 11.

I made sure the linux one was running at gigabit and reran the tests
from the linux/ia64 <=> hp/ia64.  Same results, when linux sends
it is slow, when it receives it is fast.

And note carefully: we've removed hpux from the equation, we can do
the same tests from linux to multiple linux clients and see the same
thing, sending from the server is slow, receiving on the server is
fast.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
