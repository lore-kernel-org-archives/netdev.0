From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 12:53:02 -0700
Message-ID: <4702A19E.5090403@hp.com>
References: <20071002005917.GB5480@bitmover.com>	<E1IcfN0-0007tt-00@gondolin.me.apana.org.au>	<20071002150935.GC17418@bitmover.com> <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry McVoy <lm@bitmover.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:47195 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055AbXJBTxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 15:53:15 -0400
In-Reply-To: <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I also would have expected more ACK's from the HP box. It's been a long 
> time since I did TCP, but I thought the rule was still that you were 
> supposed to ACK at least every other full frame - but the HP box is acking 
> roughly every 16K (and it's *not* always at TSO boundaries: the earlier 
> ACK's in the sequence are at 1460-byte packet boundaries, but it does seem 
> to end up getting into that pattern later on).

Drift...

The RFC's say "SHOULD" (emphasis theirs) rather than "MUST."

Both HP-UX and Solaris have rather robust ACK avoidance heuristics to cut-down 
on the CPU overhead of bulk transfers.  (That they both have them stems from 
their being cousins, sharing a common TCP stack ancestor long ago - both of 
course have been diverging since then).

rick jones
