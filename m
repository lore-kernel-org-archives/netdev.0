From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 31 Jul 2007 13:51:52 -0700 (PDT)
Message-ID: <20070731.135152.21594763.davem@davemloft.net>
References: <20070731090159.GB12071@florz.florz.dyndns.org>
	<20070731.021602.48807945.davem@davemloft.net>
	<20070731110547.GC12071@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754362AbXGaUv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 16:51:57 -0400
In-Reply-To: <20070731110547.GC12071@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Tue, 31 Jul 2007 13:05:47 +0200

> A few variations I tried back when I created the patch, using larger
> things than a char for accumulating the pieces and then folding down
> from that, turned out to be slower than what I finally submitted, at
> least on the machines I tested it on. I didn't do comprehensive testing,
> as it really doesn't matter, after all, but I think the version I
> submitted is pretty fast, plus it's quite readable, and it keeps the
> flexibility of different hash sizes, but still should allow the
> compiler to optimize away the loops that allow for this flexibility.

Therefore, I've put your original patch into the tree :-)

Thanks.
