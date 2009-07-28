From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 16:44:51 +0800
Message-ID: <20090728084451.GA26299@gondor.apana.org.au>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44595 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751927AbZG1Io6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:44:58 -0400
Content-Disposition: inline
In-Reply-To: <20090728083713.GB5424@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 08:37:13AM +0000, Jarek Poplawski wrote:
>
> Hmm.. would something IMHO_more_readable/less_fixing like:
> (qdisc->flags & TCQ_F_DEFAULT) be too much? (Btw, IIRC there was an
> idea long time ago to treat all queues equally.)

Well the fact that as it stands the only true multiqueue qdisc
is the default is a mere coincidence.  There is no fundamental
reason why non-default qdiscs cannot be made multiqueue aware,
well, for some of them anyway.

For example, sfq can naturally be enhanced as a multiqueue qdisc
just like the default qdisc.

So I don't think we want to prejudice what a future non-default
qdisc may support.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
