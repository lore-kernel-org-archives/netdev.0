From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: testing crazy stuff with iproute2
Date: Fri, 28 Dec 2007 01:44:17 +0200
Message-ID: <20071227233749.M11574@visp.net.lb>
References: <20071226045037.M75814@visp.net.lb> <4774146D.1030502@gmail.com> <20071227212405.M87764@visp.net.lb> <20071227225455.GA6672@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:38529 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbXL0Xyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 18:54:43 -0500
In-Reply-To: <20071227225455.GA6672@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Dec 2007 23:54:55 +0100, Jarek Poplawski wrote
> On Thu, Dec 27, 2007 at 11:25:53PM +0200, Denys Fedoryshchenko wrote:
> > I will try to talk in lartc, about HTB i wrote another mail...
> > It is not acting as TBF with burst, it is even acting weird. Probably it 
is 
> > bug, when traffic get "blocked" cause of burst.
> 
> HTB was probably projected to be simple, so it has less knobs than 
> CBQ or TBF. But it shouldn't act weird, unless you do weird things...
> E.g. what do you expect with 'rate 8bit'? I think, you should 
> firstly do some tests with different rates without touching cburst 
> or even quantum: HTB usually uses workable defaults if rates and 
> packet sizes are within some limits. End at the beginning I think 
> it's better to always use 'default' parameter with qdisc, and add 
> some class for this to verify all traffic is filtered as expected.

It is just to make ceil thing there is no bandwidth available. I know that 
parents in theory must be equal or more than childs sum and etc. About 
strange cburst/burst i will explain in next part.


> 
> > I will try to use lartc, if it is better to not "spam" my stuff here :-)
> 
> Maybe you don't believe it, but I really knew much more about 
> properly setting HTB parameters 2 years ago, when I read lartc or 
> not worse our local linux networking news group than now - when, 
> this practical knowledge was mostly erased by some 'useless' inside details.

For bandwidth sharing it is perfect, but i want just to make things, which i 
did with TBF - some time bursty speed, and then slow down to lower speed if 
customer is using too much. In theory it has to work like this, but in 
practice i am hitting wall. I tried it about 1 year ago, it was same thing, 
just with another conditions. Seems cburst/burst a bit different thing, just 
to make load on CPU by HTB less , at high speeds.

> 
> > I didn't try yet PSPacer yet, as ESFQ things. If it is need i can do that 
and 
> > write feedback. I can use some of them in real environment after some pre-
> > testing.
> 
> It looked like very interesting, so I'm only a bit curious why so
> quiet...
On my experience people don't like much talking on mails, sending bug reports 
and etc. I know a lot of people who have kernel panic, oops issues, and who 
don't know what to do, just to blame "linux". Now i am trying to help them 
and also to help improve linux this way.
For me personally more interesting right now ESFQ way. Just i am scared to 
put in producting patches not from mainline, cause then on issues i cannot 
write proper bugreport.

> 
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

