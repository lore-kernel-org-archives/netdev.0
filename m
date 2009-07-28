From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 09:02:29 +0000
Message-ID: <20090728090229.GA6593@ff.dom.local>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local> <20090728084451.GA26299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:42329 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbZG1JCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 05:02:35 -0400
Received: by bwz21 with SMTP id 21so754552bwz.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 02:02:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090728084451.GA26299@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 04:44:51PM +0800, Herbert Xu wrote:
> On Tue, Jul 28, 2009 at 08:37:13AM +0000, Jarek Poplawski wrote:
> >
> > Hmm.. would something IMHO_more_readable/less_fixing like:
> > (qdisc->flags & TCQ_F_DEFAULT) be too much? (Btw, IIRC there was an
> > idea long time ago to treat all queues equally.)
> 
> Well the fact that as it stands the only true multiqueue qdisc
> is the default is a mere coincidence.  There is no fundamental
> reason why non-default qdiscs cannot be made multiqueue aware,
> well, for some of them anyway.
> 
> For example, sfq can naturally be enhanced as a multiqueue qdisc
> just like the default qdisc.
> 
> So I don't think we want to prejudice what a future non-default
> qdisc may support.

If it's only about the name I'm OK with: (qdisc->flags &
TCQ_F_DEFAULT_WITHOUT_PREJUDICE_MAYBE_NON_DEFAULT_IN_THE_FUTURE)
or any other, too ;-)

Cheers,
Jarek P.
