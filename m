From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Wed, 16 Sep 2009 08:52:18 -0300
Message-ID: <20090916115218.GK22743@ghostprotocols.net>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com> <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com> <20090914230902.GC22743@ghostprotocols.net> <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com> <20090915141110.GG22743@ghostprotocols.net> <9b2db90b0909151120l71498303w26cfd657c9f18092@mail.gmail.com> <20090915205207.GI22743@ghostprotocols.net> <20090916045333.GA18325@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Nir Tzachar <nir.tzachar@gmail.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755873AbZIPLwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 07:52:32 -0400
Content-Disposition: inline
In-Reply-To: <20090916045333.GA18325@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Sep 16, 2009 at 02:53:44PM +1000, Simon Horman escreveu:
> On Tue, Sep 15, 2009 at 05:52:07PM -0300, Arnaldo Carvalho de Melo wrote:
> > Em Tue, Sep 15, 2009 at 09:20:13PM +0300, Nir Tzachar escreveu:
> > > >> Setup:
> > > >> linux 2.6.29.2 with the third version of the patch, running on an
> > > >> Intel Xeon X3220 2.4GHz quad core, with 4Gbyte of ram, running Ubuntu
> > > >> 9.04
> > > >
> > > > Which NIC? 10 Gbit/s?
> > > 
> > > 1G. We do not care as much for throughput as we do about latency...
> > 
> > OK, but anyway the 10 Gbit/s cards I've briefly played with all
> > exhibited lower latencies than all 1 gbit/s ones, in fact I've heard
> > about people moving to 10 Gbit/s not for the bw, but for the lower
> > latencies :-)
> 
> Hi Arnaldo,
> 
> Out of curiosity, is that using a 10Gbit card with
> a 10Gbit link or a 1Gbit link?

Its been a while, but most details should be publicly available here:

http://www.stacresearch.com/node/4211

- Arnaldo
