From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 14:16:56 -0700 (PDT)
Message-ID: <20071002.141656.42880006.davem@davemloft.net>
References: <20071002154137.GD17418@bitmover.com>
	<alpine.LFD.0.999.0710020930250.3579@woody.linux-foundation.org>
	<20071002164858.GH17418@bitmover.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, herbert@gondor.apana.org.au,
	wscott@bitmover.com, netdev@vger.kernel.org
To: lm@bitmover.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39580
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752055AbXJBVQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:16:56 -0400
In-Reply-To: <20071002164858.GH17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lm@bitmover.com (Larry McVoy)
Date: Tue, 2 Oct 2007 09:48:58 -0700

> Isn't this something so straightforward that you would have tests for it?
> This is the basic FTP server loop, doesn't someone have a big machine with
> 10gig cards and test that sending/recving data doesn't regress?

Nobody is really doing this, or they aren't talking about it.
Sometimes the crash fixes and other work completely consumes us.  Add
in travel to conferences and real life, and it's no surprise stuff
like this slips through the cracks.

We absolutely depend upon people like you to report when there are
anomalies like this.  It's the only thing that scales.

FWIW I have a t1000 Niagara box and an Ultra45 going through a netgear
gigabit switch.  I'm getting 85MB/sec in one direction and 10MB/sec in
the other (using bw_tcp from lmbench3).  Both are using identical
broadcom tigon3 gigabit chips and identical current kernels so that is
a truly strange result.

I'll investigate, it may be the same thing you're seeing.
