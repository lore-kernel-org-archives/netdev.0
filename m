From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 11:28:28 +0000
Message-ID: <20090519112828.GA6918@ff.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <200905191404.50464.denys@visp.net.lb> <20090519111857.GC5521@ff.dom.local> <200905191421.28519.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Eric Dumazet <dada1@cosmosbay.com>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:60223 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbZESL2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 07:28:37 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1821771rvb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 04:28:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200905191421.28519.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 02:21:28PM +0300, Denys Fedoryschenko wrote:
> On Tuesday 19 May 2009 14:18:57 Jarek Poplawski wrote:
> >
> > Sure, if the queue is too short we could have a problem with reaching
> > the expected rate; but here it's all backwards - it could actually
> > "help" with the stats. ;-)
> >
> > Jarek P.
> Well, i had real experience on HTB, when i set too short buffers on  my QoS 
> qdiscs, the incoming rate jumped too high than overall. When i set larger 
> buffers (and by the way dropped sfq and use bfifo) - it is dropped.  No idea 
> why, bug or specific things in  protocols congestion control. Maybe worth to 
> try...
> 

Very strange. Anyway, "overlimits 0" suggests HTB always got packets
when it needed...

Jarek P.
