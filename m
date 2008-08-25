From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 24 Aug 2008 20:29:22 -0400
Message-ID: <20080824202922.2cc9b9f6@speedy>
References: <20080822.044248.175133807.davem@davemloft.net>
	<20080822120918.GB14981@ff.dom.local>
	<20080822121144.GA32397@gondor.apana.org.au>
	<20080822.051841.259820995.davem@davemloft.net>
	<20080822124556.GA15788@gondor.apana.org.au>
	<20080824192639.587f9391@speedy>
	<20080824234947.GA19018@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54621 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433AbYHYA30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2008 20:29:26 -0400
In-Reply-To: <20080824234947.GA19018@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2008 09:49:47 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, Aug 24, 2008 at 07:26:39PM -0400, Stephen Hemminger wrote:
> >
> > Tfifo is there only to add the jitter based reordering. Netem has other
> > better kinds of reordering as well.
> > 
> > Netem has to be able to put TBF in as a child qdisc. This is how loss
> > plus rate control is done.
> 
> What about making TBF a child of tfifo instead? Alternatively
> we could merge tfifo into netem.
> 

But then you couldn't replace tfifo with pfifo or tbf??
