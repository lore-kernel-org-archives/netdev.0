From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] [PATCH] ip: skip IP checksum for skbs with CHECKSUM_UNNECESSARY set
Date: Sat, 23 Aug 2008 12:58:11 +0300
Message-ID: <200808231258.12397.opurdila@ixiacom.com>
References: <E1KWlT3-0001HJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:10225 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752468AbYHWKBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 06:01:11 -0400
In-Reply-To: <E1KWlT3-0001HJ-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 23 Aug 2008 15:15:17 +1000

> > I don't think they want this for performance, they want to not have to
> > compute the IP header checksum in their HW LRO implementation, which
> > is just as silly :-)

Yes, this was the intention, it seemed like a reasonable trade-off between FPGA 
space & complexity / software complexity at the time. Thanks for the input, 
will do it in hardware then.

> I sure hope they're not planning on leaving out the IP header
> checksum verification too :)

Of course not :) 

tavi

