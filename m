From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 09:48:58 -0700
Message-ID: <20071002164858.GH17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <alpine.LFD.0.999.0710020930250.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43467 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752559AbXJBQs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 12:48:59 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0710020930250.3579@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Isn't this something so straightforward that you would have tests for it?
This is the basic FTP server loop, doesn't someone have a big machine with
10gig cards and test that sending/recving data doesn't regress?

> Sounds like a bug to me, modulo the above caveat of making sure that it's 
> not some hw/driver/switch kind of difference.

Pretty unlikely given that we've changed the switch, the card works fine
in the other direction, and I'm 95% sure that we used to get better perf
before we switched to a more recent kernel.

I'll try and find some other gig ether cards and try them.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
