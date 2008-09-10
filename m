From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 22:21:27 -0700 (PDT)
Message-ID: <20080909.222127.40980994.davem@davemloft.net>
References: <20080909.212426.193696271.davem@davemloft.net>
	<20080909.214829.193700357.davem@davemloft.net>
	<20080910045350.GA3060@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50644
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbYIJFVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 01:21:33 -0400
In-Reply-To: <20080910045350.GA3060@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Sep 2008 14:53:50 +1000

> On Tue, Sep 09, 2008 at 09:48:29PM -0700, David Miller wrote:
> > 
> > I can't see what does the list delete from the GC leftover list?  Entries
> > seem to stay on there forever.  We even kfree() the object.
> 
> Doh! Yes there's supposed to be a list_del in there.

Your original change was already in net-next-2.6 so I commited the
one-liner fix.

Thanks.
