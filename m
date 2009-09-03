From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 16:28:55 -0700 (PDT)
Message-ID: <20090903.162855.46818886.davem@davemloft.net>
References: <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk>
	<4A9FD2DC.7070807@trash.net>
	<Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, cl@linux-foundation.org, eric.dumazet@gmail.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38444
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756541AbZICX2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 19:28:40 -0400
In-Reply-To: <Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@diku.dk>
Date: Thu, 3 Sep 2009 19:30:00 +0200 (CEST)

> I especially like the possibility to access each qdisc seperately.
> Does it then support having seperate qdisc per TX queue?  (I'm toying
> with the idea of transmitting our multicast traffic into/via a
> seperate TX hardware queue, and making a special qdisc for IPTV
> MPEG2-TS shaping)

Indeed it sounds interesting.

But I want to warn everyone against adding support for anything
that adds a way to do operations "on every device qdisc" at the
kernel level.

I tried to do that and the error unwinding complexity is unacceptable.

We can make the tools support things like this.  Keep the kernel
simple and allow it to only operate on one queue at a time for
a given individual config request.

