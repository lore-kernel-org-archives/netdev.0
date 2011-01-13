From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Thu, 13 Jan 2011 16:54:27 +0100
Message-ID: <1294934067.3570.245.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <20110103095842.7677130d@nehalam>
	 <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk> <4D2EE708.8010806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Stephen Hemminger <shemminger@vyatta.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37280 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170Ab1AMPyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 10:54:33 -0500
Received: by wwa36 with SMTP id 36so1951345wwa.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 07:54:32 -0800 (PST)
In-Reply-To: <4D2EE708.8010806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 12:50 +0100, Patrick McHardy a =C3=A9cr=
it :
> On 04.01.2011 15:19, Jesper Dangaard Brouer wrote:
> >> ...
> >> You might want to look into CHOKe and ECSFQ which are other AQM mo=
dels
> >> that have shown up in research.
> >=20
> > Have you looked at the SFB (Stochastic Fair Blue) implementation by=
 Juliusz Chroboczek?
> >=20
> > http://www.pps.jussieu.fr/~jch/software/sfb/
>=20
> I had a closer look at this some time ago and noticed a couple of bug=
s
> (f.i. double buffering might be enabled or disabled or the buffers
> switched while a packet is queued, so on dequeue the wrong buffer wil=
l
> have its queue length decremented) and also found the hashing quite
> inefficient, so I've implemented my own version. There's still a mino=
r
> bug somewhere, but if people are interested I could finish it some
> time soon and post the patches.

I am very interested Patrick, I also found SFB hashing inefficient, so
any new idea is welcomed.=20

We should get more schedulers at hand.

CHOKe is about to be released, QFQ is also coming soon, thanks to
Stephen (and respective AQM authors)

Thanks


