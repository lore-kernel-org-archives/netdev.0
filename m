From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 08:32:05 -0700
Message-ID: <1376926325.4226.64.camel@edumazet-glaptop>
References: <521061B4.1030508@fatooh.org>
	 <1376839467.21329.36.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
	 <1376870425.4226.25.camel@edumazet-glaptop>
	 <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
	 <20130819123314.GC3583@cpaasch-mac>
	 <1376918657.4226.59.camel@edumazet-glaptop>
	 <20130819134919.GF3583@cpaasch-mac>
	 <1376920685.4226.61.camel@edumazet-glaptop>
	 <20130819143509.GA31320@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33454 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab3HSPcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:32:16 -0400
In-Reply-To: <20130819143509.GA31320@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-19 at 07:35 -0700, Phil Oester wrote:
> On Mon, Aug 19, 2013 at 06:58:05AM -0700, Eric Dumazet wrote:
> > Yeah, but here, this is conntrack who is blocking the thing.
> > 
> > TCP receiver has no chance to 'fix' it.
> > 
> > See conntrack is one of those buggy middle box as well.
> > 
> > So if you want to properly handle this mess, you'll also have to fix
> > conntrack.
> 
> Better to fix the box which is randomizing the acks and ignoring
> the SACKs.  Usually these are older Cisco PIX/ASA devices which just
> need a code upgrade.  


Having a patch to relax things could be evaluated, if not adding new
problems ( http://en.wikipedia.org/wiki/Robustness_principle ) 
