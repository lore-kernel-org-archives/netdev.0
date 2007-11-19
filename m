From: jamal <hadi@cyberus.ca>
Subject: Re: HTB/HSFC shaping precision
Date: Mon, 19 Nov 2007 11:24:54 -0500
Message-ID: <1195489494.4445.119.camel@localhost>
References: <20071119083849.M87605@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:56308 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbXKSQZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 11:25:16 -0500
Received: by py-out-1112.google.com with SMTP id u77so5884978pyb
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 08:25:15 -0800 (PST)
In-Reply-To: <20071119083849.M87605@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys,

You certainly make a very compelling case. It is always compelling if
you can translate a bug/feature into $$;->.

So in your measurements, what kind of clock sources did you use?
I think the parameters to worry about are: packet size, rate and clock
source. 
I know that based on very old measurements i did on CBQ, regardless of
the clock source if you have a long-lived flow the bandwidth measurement
corrects itself. I wouldnt recommend going to CBQ, but a good start is
to test and post some results.

cheers,
jamal

On Mon, 2007-19-11 at 10:55 +0200, Denys Fedoryshchenko wrote:
> Hi 2 all again
> 
> This is not a bug report this time :-) 
> Just it is very interesting question, about using Linux "shaping" technologies
> in serious jobs.
> 
> What i realised few days ago, many ISP's set on their STM-1(155520000 bits/s)
> links (over Cisco) packet buffer/queue 40 packets(for example).
> It means 103680  pps with 1500 byte packets,  and if buffer is only 40
> packets, it means it require at least 0.3ms scheduler precision? Otherwise i
> can have buffer overflow and as result packetloss(what is much worse than
> delay in most of situations).
> 
> What i am interested - to utilise such links nearby 100%. So anything not
> precise will kill idea.
> Thats important, cause price for links in my area is about $1000-$1500 Mbit/s,
> and just 1% lost/not utilised on STM-1 is up to $2325/USD lost per month.
> I have to count also overhead, LAN jitter, and etc.
> 
> As far as i test, on HFSC if i set dmax 1ms-10ms it works much better (i am
> talking about precision) than HTB with quantum 1514 (it is over ethernet). 
> 
> Anybody have ideas what is the precision of bandwidth shaping in HFSC/HTB?


