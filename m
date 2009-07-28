From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 17:13:45 +0530
Message-ID: <OFD1BE2D07.6BDFA87B-ON65257601.003F8F24-65257601.00406E62@in.ibm.com>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local> <20090728084451.GA26299@gondor.apana.org.au> <20090728090229.GA6593@ff.dom.local> <20090728105329.GA27453@gondor.apana.org.au> <20090728112445.GB6593@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:39791 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbZG1Lo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 07:44:27 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n6SBiPtL022319
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 17:14:25 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6SBiPhZ1458430
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 17:14:25 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n6SBiOV8016707
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 17:14:25 +0530
In-Reply-To: <20090728112445.GB6593@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure, I will test and give my findings here. I guess setting the
flag in qdisc_create_dflt is the right place - that will cover pfifo,
bfifo and pfifo_fast (instead of attach_one_default_qdisc)?

Thanks for all the suggestions.

- KK

Jarek Poplawski <jarkao2@gmail.com> wrote on 07/28/2009 04:54:45 PM:

> On Tue, Jul 28, 2009 at 06:53:29PM +0800, Herbert Xu wrote:
> > On Tue, Jul 28, 2009 at 09:02:29AM +0000, Jarek Poplawski wrote:
> > >
> > > If it's only about the name I'm OK with: (qdisc->flags &
> > > TCQ_F_DEFAULT_WITHOUT_PREJUDICE_MAYBE_NON_DEFAULT_IN_THE_FUTURE)
> > > or any other, too ;-)
> >
> > I see.  Yes a flag should work.
>
> So, I hope Krishna will try if these requested comments save any gains
> of the original patch...
>
> Thanks,
> Jarek P.

