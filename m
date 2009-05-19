From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 15:18:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0905191517350.4730@tyr.diku.dk>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local>
 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
 <20090518175352.GB2755@ami.dom.local> <298f5c050905181123o55c35e74n24cd4ee2c07d8fca@mail.gmail.com>
 <20090518183221.GC2755@ami.dom.local> <298f5c050905181156w2254fcb4p889d67e26fad6e6@mail.gmail.com>
 <20090518190541.GA3047@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Eric Dumazet <dada1@cosmosbay.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:51633 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbZESNTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 09:19:51 -0400
In-Reply-To: <20090518190541.GA3047@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 18 May 2009, Jarek Poplawski wrote:

> Since you're so kind... :-) There is a line in net/sched/sch_htb.c:
>
> #define HTB_HYSTERESIS 1        /* whether to use mode hysteresis for speedup */
>
> Could you change 1 to 0, and repeat these tests above after recompiling?

Notice its runtime adjustable via:
  /sys/module/sch_htb/parameters/htb_hysteresis

Since kernel version v2.6.26.


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
