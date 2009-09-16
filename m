From: Simon Horman <horms@verge.net.au>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Wed, 16 Sep 2009 14:53:44 +1000
Message-ID: <20090916045333.GA18325@verge.net.au>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com>
 <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com>
 <20090914230902.GC22743@ghostprotocols.net>
 <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com>
 <20090915141110.GG22743@ghostprotocols.net>
 <9b2db90b0909151120l71498303w26cfd657c9f18092@mail.gmail.com>
 <20090915205207.GI22743@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nir Tzachar <nir.tzachar@gmail.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48886 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbZIPExm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 00:53:42 -0400
Content-Disposition: inline
In-Reply-To: <20090915205207.GI22743@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 05:52:07PM -0300, Arnaldo Carvalho de Melo wrote:
> Em Tue, Sep 15, 2009 at 09:20:13PM +0300, Nir Tzachar escreveu:
> > >> Setup:
> > >> linux 2.6.29.2 with the third version of the patch, running on an
> > >> Intel Xeon X3220 2.4GHz quad core, with 4Gbyte of ram, running Ubuntu
> > >> 9.04
> > >
> > > Which NIC? 10 Gbit/s?
> > 
> > 1G. We do not care as much for throughput as we do about latency...
> 
> OK, but anyway the 10 Gbit/s cards I've briefly played with all
> exhibited lower latencies than all 1 gbit/s ones, in fact I've heard
> about people moving to 10 Gbit/s not for the bw, but for the lower
> latencies :-)

Hi Arnaldo,

Out of curiosity, is that using a 10Gbit card with
a 10Gbit link or a 1Gbit link?


