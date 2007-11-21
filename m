From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: HTB/HSFC shaping precision
Date: Wed, 21 Nov 2007 10:47:10 +0100
Message-ID: <20071121094710.GA2295@ff.dom.local>
References: <20071120211258.M55249@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:57732 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751404AbXKUJmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 04:42:49 -0500
Content-Disposition: inline
In-Reply-To: <20071120211258.M55249@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20-11-2007 22:21, Denys Fedoryshchenko wrote:
...
> If traffic is dropped - it will be resent, a lot of energy will be wasted for 
> nothing. Same bytes will pass all long way around earth just because i am not 
> able to manage my QoS box :-)

Sure, but you'll use probably almost every bit you've payed for!

> 
> Plus uplink bandwidth will be used for that, i am using my own protocol(it is 
> TCP "accelerator" for satellite communications based on NACK and "streaming" 
> compression, so each resend - it is few bytes more on uplink and additional 
> delay. Ah yes, even resend over TCP it is more delay, than if it will be 
> queued for few milliseconds on bottleneck. 
> 
> Plus if buffer on STM-1 interface way too small - smallest spike will cause 
> packetlossy, and sitation can be far away from congestion. As result it will 
> be very difficult to reach maximum bandwidth on such link. And linux box in 
> this situation is magic box, which can help to save energy, hungry people and 
> help to use resources efficiently :-)
> 

I'm still not sure how this traffic goes around, because eg., if you
receive something through a satelite, then it would only make sense if
it were controlled earlier to the same speed too. Otherwise you should
have this dropping on your HTB (of course you could use big buffers,
but anyway...), instead of STM, but resending could be similar.

But, if you have full control on your side, it looks like a kind of
realtime traffic, and then HFSC should be more appropriate for this
(but I only 'heard' about this).

> Yes, for sure. Thats what i am reading almost each day, when i dont 
> understand something clearly. But, my english is far away from good, so 
> sometimes i just misunderstand something even in good manual.

Then good news: read the code! There is really as little English as
possible...

Cheers,
Jarek P.
