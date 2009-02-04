From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 03 Feb 2009 16:46:30 -0800 (PST)
Message-ID: <20090203.164630.173080148.davem@davemloft.net>
References: <20090203094108.GA4639@ff.dom.local>
	<20090203111012.GA16878@ioremap.net>
	<20090203112431.GA8746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, jarkao2@gmail.com, w@1wt.eu, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32806
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751088AbZBDAqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 19:46:33 -0500
In-Reply-To: <20090203112431.GA8746@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 3 Feb 2009 22:24:31 +1100

> Not necessarily.  Even if the hardware can only DMA into contiguous
> memory, we can always allocate a sufficient number of contiguous
> buffers initially, and then always copy them into fragmented skbs
> at receive time.  This way the contiguous buffers are never
> depleted.
> 
> Granted copying sucks, but this is really because the underlying
> hardware is badly designed.  Also copying is way better than
> not receiving at all due to memory fragmentation.

This scheme sounds very reasonable.
