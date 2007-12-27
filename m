From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: testing crazy stuff with iproute2
Date: Thu, 27 Dec 2007 23:25:53 +0200
Message-ID: <20071227212405.M87764@visp.net.lb>
References: <20071226045037.M75814@visp.net.lb> <4774146D.1030502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:54784 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbXL0VlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 16:41:14 -0500
In-Reply-To: <4774146D.1030502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will try to talk in lartc, about HTB i wrote another mail...
It is not acting as TBF with burst, it is even acting weird. Probably it is 
bug, when traffic get "blocked" cause of burst.

I will try to use lartc, if it is better to not "spam" my stuff here :-)

I didn't try yet PSPacer yet, as ESFQ things. If it is need i can do that and 
write feedback. I can use some of them in real environment after some pre-
testing.

On Thu, 27 Dec 2007 22:09:01 +0100, Jarek Poplawski wrote
> Denys Fedoryshchenko wrote, On 12/26/2007 05:57 AM:
> ....
> 
> > But i got few times in dmesg, during tests (probably when i set sfq 
instead 
> > pfifo, or etc).
> > 
> > [2090816.116000] htb: class 10003 isn't work conserving ?!
> > 
> > Is it a bug? And does it worth to do such "shaper"?
> 
> It's not a bug - htb simply wonders the sub-queue has packets,
> but doesn't dequeue any when expected. Probably htb + tbf isn't
> the most common configuration, but nothing wrong either. You
> should only consider htb could do similar (not exactly) job by
> itself, and each additional qdisc adds some latency, so it's only
> a question of priorities. But, hmm, ...don't you think this
> lartc.org's mailing list is really nice?
> 
> Regards,
> Jarek P.
> 
> PS: BTW, maybe I missed this, but I hoped you'd share here some
> impressions from testing this new PSPacer scheduler?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

