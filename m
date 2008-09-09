From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Mon, 08 Sep 2008 17:20:56 -0700 (PDT)
Message-ID: <20080908.172056.106770678.davem@davemloft.net>
References: <20080905115506.GA26179@gondor.apana.org.au>
	<20080908.170907.242316059.davem@davemloft.net>
	<20080909001828.GA20643@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754361AbYIIAVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:21:03 -0400
In-Reply-To: <20080909001828.GA20643@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 9 Sep 2008 10:18:28 +1000

> On Mon, Sep 08, 2008 at 05:09:07PM -0700, David Miller wrote:
> > What happens to all of the entries on the local gc_list which you
> > will be skipping when you break out of that last loop?
> > 
> > It looks like they will never get processed.
> 
> I made gc_list static, so they'll be processed when the GC task
> runs again.  Also whenever completed is incremented we schedule
> the GC task.

Thanks, I didn't catch that "static" bit :-)
