From: Benny Lyne Amorsen <benny@amorsen.dk>
Subject: Re: Strange packet drops with heavy firewalling
Date: Mon, 12 Apr 2010 16:44:39 +0200
Message-ID: <1271083479.2858.377.camel@ursa.amorsen.dk>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	 <q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhigang gong <zhigang.gong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:45303 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab0DLOor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 10:44:47 -0400
In-Reply-To: <q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

man, 12 04 2010 kl. 16:16 +0800, skrev zhigang gong:

> How do you know the per CPU usage data, by oprofile? I'm just a little
> surprised with the result, as it shows your new core is running 10x
> faster than your old core :). 

Well the old server had only two CPU's plus hyperthreading, and the
CPU's were Pentium-4-based. Add a slow memory bus to that and you have a
fairly slow system. It's almost 5 years old, so Moore's law says 2**3
increase in number of transistors...

In about the same time frame Linux has gone from being able to fill
1Gbps ethernet to being able to fill 10Gbps ethernet 

> What's the average packet size?

I asked the switch (I can't find a handy equivalent to ifstat which
counts packets instead of bytes). The 5 minute average packet sizes seem
to vary in the range 450 to 550 bytes.

> If your packet size is 64 bytes, then the pps(packet per second) rate
> should be about 585Kpps. As I know, this value is almost the best
> result when the standard linux kernel is processing the networking
> traffic with a normal 1Gb ethernet card (without multi-queue support)
> on a intel box. If it is the case, to buy a better ethernet card with
> multi-queue support should be a good choice. Otherwise, it may not
> help. 

I am far from that, perhaps 1/10th of that. I do a lot more processing
on at least some of the packets though (the ones starting new flows).


/Benny


