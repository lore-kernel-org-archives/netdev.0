From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 18:53:29 +0800
Message-ID: <20090728105329.GA27453@gondor.apana.org.au>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local> <20090728084451.GA26299@gondor.apana.org.au> <20090728090229.GA6593@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35984 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751931AbZG1Kxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 06:53:35 -0400
Content-Disposition: inline
In-Reply-To: <20090728090229.GA6593@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 09:02:29AM +0000, Jarek Poplawski wrote:
>
> If it's only about the name I'm OK with: (qdisc->flags &
> TCQ_F_DEFAULT_WITHOUT_PREJUDICE_MAYBE_NON_DEFAULT_IN_THE_FUTURE)
> or any other, too ;-)

I see.  Yes a flag should work.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
