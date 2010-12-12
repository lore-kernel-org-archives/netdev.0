From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Sun, 12 Dec 2010 13:48:33 -0200
Message-ID: <20101212154833.GB20240@ghostprotocols.net>
References: <1288954189.28003.178.camel@firesoul.comx.local> <1288988955.2665.297.camel@edumazet-laptop> <1289213926.15004.19.camel@firesoul.comx.local> <1289214289.2820.188.camel@edumazet-laptop> <1289228785.2820.203.camel@edumazet-laptop> <1289311159.17448.9.camel@traveldev.cxnet.dk> <1289312178.17448.20.camel@traveldev.cxnet.dk> <1289313516.17448.28.camel@traveldev.cxnet.dk> <1289388256.15004.66.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:39888 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab0LLPsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 10:48:37 -0500
Content-Disposition: inline
In-Reply-To: <1289388256.15004.66.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Nov 10, 2010 at 12:24:16PM +0100, Jesper Dangaard Brouer escreveu:
> > BUT perf top reveals that its probably related to the function
> > 'find_busiest_group' ... any kernel config hints how I get rid of that?
> 
> The 'find_busiest_group' seems to be an artifact of "perf top", if I use
> "perf record" then the 'find_busiest_group' function disappears.  Which
> is kind of strange, as 'find_busiest_group' seem the be related to
> sched_fair.c.
> 
> perf --version
> perf version 2.6.35.7.1.g60d9c

perf top does sytemwide sampling, while when you use 'perf record
./workload' its not systemwide.

Take a look at 'perf top --help' to see how to limit this to an existing
pid, tid, cpu list, etc.

- Arnaldo
