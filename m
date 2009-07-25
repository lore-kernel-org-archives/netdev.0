From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Sat, 25 Jul 2009 13:53:09 +0200
Message-ID: <20090725115309.GB3086@ami.dom.local>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <20090724083006.GA5698@ff.dom.local> <20090724083749.GA23521@gondor.apana.org.au> <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com> <20090725032436.GA30741@gondor.apana.org.au> <20090725110409.GA3086@ami.dom.local> <20090725111207.GA518@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:41382 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbZGYLxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 07:53:31 -0400
Received: by fxm18 with SMTP id 18so1846835fxm.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 04:53:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090725111207.GA518@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 25, 2009 at 07:12:07PM +0800, Herbert Xu wrote:
> On Sat, Jul 25, 2009 at 01:04:09PM +0200, Jarek Poplawski wrote:
> > 
> > It would be nice to establish what difference is made by each part of
> > this patch. The check for stopped queue before each skb xmit was done
> > earlier too, so it's not exactly multiqueue penalization.
> 
> No, but getting into qdisc_restart when we know that the queue is
> stopped is just silly.  The only reason that is done right now is
> because of the pathological case where a packet on qdisc X maps to
> hardware queue Y.  This is something which almost nobody uses and
> yet it penalises everybody.

Hmm... I agree with you 100%! (I'd only like to see more digits... ;-)

Cheers,
Jarek P.
