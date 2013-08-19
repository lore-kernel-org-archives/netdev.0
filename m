From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 09:00:31 -0700
Message-ID: <1376928031.4226.66.camel@edumazet-glaptop>
References: <1376839467.21329.36.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
	 <1376870425.4226.25.camel@edumazet-glaptop>
	 <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
	 <20130819123314.GC3583@cpaasch-mac>
	 <1376918657.4226.59.camel@edumazet-glaptop>
	 <20130819134919.GF3583@cpaasch-mac>
	 <1376920685.4226.61.camel@edumazet-glaptop>
	 <20130819143509.GA31320@linuxace.com> <20130819153328.GH3583@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:64540 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab3HSQAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 12:00:40 -0400
In-Reply-To: <20130819153328.GH3583@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-19 at 17:33 +0200, Christoph Paasch wrote:

> 
> Unfortunately, they will hardly go away in the near futur. Rather the
> opposite is the case.
> 
> 
> If you have a public server running, I would be interested in the count of
> invalid SACK-blocks received (netstat -s | grep TCPSACKDiscard). This is an
> indication for such kind of middlebox between your server and the client,
> implying that these connections cannot benefit from TCP-FastRetransmission
> and each packet-loss will require an RTO to recover.
> 

If the (random) sequence offset is small rather than completely out of
window, it's going to be hard to detect all problems.

Show us your patch ;)
