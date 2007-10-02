From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 10:11:54 -0700
Message-ID: <20071002171154.GM17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <4702766E.80202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43505 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754736AbXJBRLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 13:11:54 -0400
Content-Disposition: inline
In-Reply-To: <4702766E.80202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I have a more complex configuration & application, but I don't see this 
> problem in my testing.  Using e1000 nics and modern hardware 

I'm using a similar setup, what kernel are you using?

> I am purposefully setting the socket send/rx buffers, as well has 
> twiddling with the tcp and netdev related tunables.  

Ben sent those to me, see below, they didn't make any difference.
I tried diddling the socket send/recv buffers to 10MB, that didn't
help.  The defaults didn't help.  1MB didn't help and 64K didn't
help.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
