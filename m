From: Patrick McHardy <kaber@trash.net>
Subject: Re: sch_sfb [was: net_sched: mark packet staying on queue too long]
Date: Thu, 13 Jan 2011 19:59:15 +0100
Message-ID: <4D2F4B83.6060001@trash.net>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>	<20101220232020.GB2052@del.dom.local>	<1292887689.2627.150.camel@edumazet-laptop>	<20101220235209.GA1865@del.dom.local>	<1292939574.6535.27.camel@mojatatu>	<AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>	<20101221223704.GA1979@del.dom.local>	<1293111333.11306.170.camel@mojatatu>	<1294003631.2535.253.camel@edumazet-laptop>	<20110103095842.7677130d@nehalam>	<Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>	<4D2EE708.8010806@trash.net> <87bp3kg58i.fsf_-_@trurl.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	David Miller <davem@davemloft.net>
To: Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50083 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756887Ab1AMS7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 13:59:19 -0500
In-Reply-To: <87bp3kg58i.fsf_-_@trurl.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 13.01.2011 17:04, schrieb Juliusz Chroboczek:
>>> Have you looked at the SFB (Stochastic Fair Blue) implementation by
>>> Juliusz Chroboczek?
> 
>>> http://www.pps.jussieu.fr/~jch/software/sfb/
> 
>> I had a closer look at this some time ago and noticed a couple of bugs
>> (f.i. double buffering might be enabled or disabled or the buffers
>> switched while a packet is queued, so on dequeue the wrong buffer will
>> have its queue length decremented) and also found the hashing quite
>> inefficient,
> 
> And you never found the time to drop me a mail on the subject?

Well, I just looked at it out of interest after already having started
my own version. Also I was riding the train without possibility of
communication :)

>> so I've implemented my own version.
> 
> I see.

I took a lot of ideas from your version, and this is also mentioned
in my version. It just seemed easier to start from scratch than to
fully analyze your version and base it on the original paper.
Since to my knowledge you've never attempted an upstream merge this
also seemed like the more polite way. No impoliteness intended.
