From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: HTB/HSFC shaping precision
Date: Tue, 20 Nov 2007 23:21:02 +0200
Message-ID: <20071120211258.M55249@visp.net.lb>
References: <20071119083849.M87605@visp.net.lb> <1195489494.4445.119.camel@localhost> <20071120092317.M96721@visp.net.lb> <47433CF8.70501@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:45467 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbXKTVVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 16:21:14 -0500
In-Reply-To: <47433CF8.70501@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Nov 2007 21:00:56 +0100, Jarek Poplawski wrote
> Denys Fedoryshchenko wrote, On 11/20/2007 10:43 AM:
> ....
> 
> > If let's say i will limit bandwidth to 1Mbps, and will try to send 
packets 
> > will 100Mbps speed, and will check which packets will be dropped.
> 
> As a matter of fact, I wonder why you're so afraid of this dropping. 
> It's usual method of auto-regulation e.g. for tcp. You've written 
> latency isn't so much problem, then slightly overloading ISP's queue 
> you'll always get full bandwidth, you've payed for. You didn't write 
> what kind of traffic you service, but I doubt you can get rid of 
> dropping everywhere: on your HTB etc. queues or on incoming traffic.

If traffic is dropped - it will be resent, a lot of energy will be wasted for 
nothing. Same bytes will pass all long way around earth just because i am not 
able to manage my QoS box :-)

Plus uplink bandwidth will be used for that, i am using my own protocol(it is 
TCP "accelerator" for satellite communications based on NACK and "streaming" 
compression, so each resend - it is few bytes more on uplink and additional 
delay. Ah yes, even resend over TCP it is more delay, than if it will be 
queued for few milliseconds on bottleneck. 

Plus if buffer on STM-1 interface way too small - smallest spike will cause 
packetlossy, and sitation can be far away from congestion. As result it will 
be very difficult to reach maximum bandwidth on such link. And linux box in 
this situation is magic box, which can help to save energy, hungry people and 
help to use resources efficiently :-)


> 
> > [...] This means something wrong or in my shaping tree configuration 
> > (that time HTB) or in shaper code. Thats why i try to dig in this things 
more 
> > deeply.
> 
> Did you try to dig at this very nice HTB page?:
> http://luxik.cdi.cz/~devik/qos/htb/
Yes, for sure. Thats what i am reading almost each day, when i dont 
understand something clearly. But, my english is far away from good, so 
sometimes i just misunderstand something even in good manual.

> 
> Regards,
> Jarek P.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

