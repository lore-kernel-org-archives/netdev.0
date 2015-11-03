From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 13:23:46 -0800
Message-ID: <1446585826.23275.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
	 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
	 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35833 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbKCVXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:23:49 -0500
Received: by pasz6 with SMTP id z6so29593100pas.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 13:23:48 -0800 (PST)
In-Reply-To: <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 22:24 +0200, Denys Fedoryshchenko wrote:

> I wont argue on that, you are right.
> Ok, then it is a bit offtopic in current case, different setup, but i 
> know this one has easy to reproduce issues with offloading. but this is 
> bug related to that, directly appearing when i enable tso/gso/gro. I am 
> losing access to remote box, so max i can do right now:
> ethtool -K eth0 tso on gso on gro on; sleep 5;ethtool -K eth0 tso off 
> gso off gro off
> 
> No shapers, just plain nat. I suspect it might be specific to network 
> card, but not sure.
> 



What happens if you enable gro, but disable tso ?

With GRO enabled, you'll get a good performance increase, as forwarding
and qdisc will use big packets.
