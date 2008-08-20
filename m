From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 07:22:56 +0200
Message-ID: <1219209776.7591.265.camel@violet.holtmann.net>
References: <20080819.140458.236030589.davem@davemloft.net>
	 <200808192315.48718.rjw@sisk.pl>
	 <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>
	 <20080819.143556.245692295.davem@davemloft.net>
	 <alpine.LFD.1.10.0808191440440.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49620 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbYHTFWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 01:22:53 -0400
In-Reply-To: <alpine.LFD.1.10.0808191440440.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> And btw, don't get me wrong - you're not the only problem spot. During the 
> -rc's leading up to 2.6.26, drivers/merdia was actually a _bigger_ 
> problem. I happen to care less about that (the same way I care less about 
> some odd-ball architectures), but I have to admit that drivers/media was a 
> total disaster last time around.

to be quite honest, don't you think this is a little bit unfair. So if
it is drivers/media/ or arch/sh/ or whatever you don't care. Do you
actually care what I do in drivers/bluetooth/?

I think that networking and USB are the two most biggest trees of the
kernel and the number of changes they produce are big. And most things
are drivers. I do think that we are doing pretty well in holding back
architectural changes of a subsystem and testing them properly in -mm or
-next before merging them.

The actual drivers make a big portion of Linux and we need them and we
want them. However drivers are the biggest problem for most subsystem
maintainers since they don't own all hardware. And just face it. Most
people that have certain hardware bits are not going to run -next or -mm
kernels. If we get them to test -rc kernels we are lucky.

So drivers/net/ alone is 41M in size. That is a quarter of all drivers/
directory and to be fair the others also contain the actual subsystem in
there while networking maintains it outside that directory.

Just look at your EeePC. Booting a 2.6.26 kernel on it and you have no
Ethernet and no WiFi drivers for the built-in hardware.

I personally think that we need to be conservative for the actual
subsystem changes and a little bit more open for driver changes.
Especially when it comes to new drivers (not a tg3 or e100 driver) since
we wanna ease the entry level to get Linux running. When it comes to
networking, there are just a lot of drivers. Plain simple as that.

And when it comes to architectural or subsystem changes, I think that
the merge window rule is followed quite literal. With minor things
during -rc1 because of merge conflicts, but eventually the -next tree
will solve all of these.

So what about the drivers? Should drivers for new hardware go in? Even
if the maintainers don't think they are stable enough? The current
approach is that even an almost stable driver is better than no driver.
If this no longer applies, then please spell it out and I am more than
happy to oblige.

Regards

Marcel


