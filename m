From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 11:24:45 +0000
Message-ID: <20090728112445.GB6593@ff.dom.local>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local> <20090728084451.GA26299@gondor.apana.org.au> <20090728090229.GA6593@ff.dom.local> <20090728105329.GA27453@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:47178 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbZG1LYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 07:24:52 -0400
Received: by fxm12 with SMTP id 12so53011fxm.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 04:24:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090728105329.GA27453@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 06:53:29PM +0800, Herbert Xu wrote:
> On Tue, Jul 28, 2009 at 09:02:29AM +0000, Jarek Poplawski wrote:
> >
> > If it's only about the name I'm OK with: (qdisc->flags &
> > TCQ_F_DEFAULT_WITHOUT_PREJUDICE_MAYBE_NON_DEFAULT_IN_THE_FUTURE)
> > or any other, too ;-)
> 
> I see.  Yes a flag should work.

So, I hope Krishna will try if these requested comments save any gains
of the original patch...

Thanks,
Jarek P.
