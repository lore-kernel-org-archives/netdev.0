From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: HTB/HSFC shaping precision
Date: Tue, 20 Nov 2007 21:00:56 +0100
Message-ID: <47433CF8.70501@o2.pl>
References: <20071119083849.M87605@visp.net.lb> <1195489494.4445.119.camel@localhost> <20071120092317.M96721@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:48631 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753886AbXKTT6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 14:58:46 -0500
In-Reply-To: <20071120092317.M96721@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Fedoryshchenko wrote, On 11/20/2007 10:43 AM:
... 

> If let's say i will limit bandwidth to 1Mbps, and will try to send packets 
> will 100Mbps speed, and will check which packets will be dropped.

As a matter of fact, I wonder why you're so afraid of this dropping. It's
usual method of auto-regulation e.g. for tcp. You've written latency isn't
so much problem, then slightly overloading ISP's queue you'll always get full
bandwidth, you've payed for. You didn't write what kind of traffic you service,
but I doubt you can get rid of dropping everywhere: on your HTB etc. queues
or on incoming traffic.

> [...] This means something wrong or in my shaping tree configuration 
> (that time HTB) or in shaper code. Thats why i try to dig in this things more 
> deeply.

Did you try to dig at this very nice HTB page?:
http://luxik.cdi.cz/~devik/qos/htb/

Regards,
Jarek P.
