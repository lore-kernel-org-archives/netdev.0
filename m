From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 14:56:05 +0300
Message-ID: <20090107115605.GA29250@ioremap.net>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au> <20090107112906.GA28161@ioremap.net> <20090107115032.GA25198@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:33497 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbZAGL4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 06:56:08 -0500
Content-Disposition: inline
In-Reply-To: <20090107115032.GA25198@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 10:50:32PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > That would not happen without scatter-gather support on the interface,
> > date would be plain copied, and after Jarek's requst Willy confirmed
> > that corruption happens with all acceleration being turned off.
> 
> It will happen without scatter-gather support.  The problem
> is with skb->head, which is always there.  In any case, SG can't
> make any difference because the skb is an inbound one and most
> drivers only produce linear packets.

But it will not push pages into the stack, but copy them including copy
of the submitted head?

-- 
	Evgeniy Polyakov
