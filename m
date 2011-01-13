From: Juliusz Chroboczek <jch@pps.jussieu.fr>
Subject: sch_sfb [was: net_sched: mark packet staying on queue too long]
Date: Thu, 13 Jan 2011 17:04:13 +0100
Message-ID: <87bp3kg58i.fsf_-_@trurl.pps.jussieu.fr>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	<20101220232020.GB2052@del.dom.local>
	<1292887689.2627.150.camel@edumazet-laptop>
	<20101220235209.GA1865@del.dom.local>
	<1292939574.6535.27.camel@mojatatu>
	<AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	<20101221223704.GA1979@del.dom.local>
	<1293111333.11306.170.camel@mojatatu>
	<1294003631.2535.253.camel@edumazet-laptop>
	<20110103095842.7677130d@nehalam>
	<Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
	<4D2EE708.8010806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from witko.kerneis.info ([213.186.56.95]:41038 "EHLO
	witko.kerneis.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040Ab1AMQWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 11:22:37 -0500
In-Reply-To: <4D2EE708.8010806@trash.net> (Patrick McHardy's message of "Thu,
	13 Jan 2011 12:50:32 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Have you looked at the SFB (Stochastic Fair Blue) implementation by
>> Juliusz Chroboczek?

>> http://www.pps.jussieu.fr/~jch/software/sfb/

> I had a closer look at this some time ago and noticed a couple of bugs
> (f.i. double buffering might be enabled or disabled or the buffers
> switched while a packet is queued, so on dequeue the wrong buffer will
> have its queue length decremented) and also found the hashing quite
> inefficient,

And you never found the time to drop me a mail on the subject?

> so I've implemented my own version.

I see.

                                        Juliusz
