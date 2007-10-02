From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 13:33:22 -0700 (PDT)
Message-ID: <20071002.133322.52193802.davem@davemloft.net>
References: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
	<20071002150935.GC17418@bitmover.com>
	<alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lm@bitmover.com, herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753498AbXJBUdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 16:33:22 -0400
In-Reply-To: <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 2 Oct 2007 12:27:53 -0700 (PDT)

> We see a single packet containing 16060 bytes, which seems to be because 
> of TSO on the sending side (you did your tcpdump on the sender, no?), so 
> it will actually be broken up into 11 1460-byte regular frames by the 
> network card, since they started out agreeing on a standard 1460-byte MSS. 
> So the above is not a jumbo frame, it just kind of looks like one when you 
> capture it on the sender side.
> 
> And maybe a 32kB window is not big enough when it causes the networking 
> code to basically just have a single packet outstanding.

We fixed a lot of bugs in TSO last year.

It would be really great to see numbers with a more recent kernel
than 2.6.18

