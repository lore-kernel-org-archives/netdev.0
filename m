From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Thu, 13 Jan 2011 12:50:32 +0100
Message-ID: <4D2EE708.8010806@trash.net>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com> <20101220232020.GB2052@del.dom.local> <1292887689.2627.150.camel@edumazet-laptop> <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu> <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com> <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu> <1294003631.2535.253.camel@edumazet-laptop> <20110103095842.7677130d@nehalam> <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932732Ab1AMLub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 06:50:31 -0500
In-Reply-To: <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.01.2011 15:19, Jesper Dangaard Brouer wrote:
>> ...
>> You might want to look into CHOKe and ECSFQ which are other AQM models
>> that have shown up in research.
> 
> Have you looked at the SFB (Stochastic Fair Blue) implementation by Juliusz Chroboczek?
> 
> http://www.pps.jussieu.fr/~jch/software/sfb/

I had a closer look at this some time ago and noticed a couple of bugs
(f.i. double buffering might be enabled or disabled or the buffers
switched while a packet is queued, so on dequeue the wrong buffer will
have its queue length decremented) and also found the hashing quite
inefficient, so I've implemented my own version. There's still a minor
bug somewhere, but if people are interested I could finish it some
time soon and post the patches.
