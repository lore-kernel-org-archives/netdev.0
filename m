From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] pktgen: Add NOINIT option to leave packet data
 uninitialized
Date: Fri, 16 May 2014 16:39:02 +0100
Message-ID: <20140516153902.GG8346@casper.infradead.org>
References: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch>
 <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
 <53761286.2040505@candelatech.com>
 <1400250203.7973.173.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516145032.GD8346@casper.infradead.org>
 <1400252935.7973.176.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516152035.GE8346@casper.infradead.org>
 <1400253971.7973.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40297 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932646AbaEPPjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:39:04 -0400
Content-Disposition: inline
In-Reply-To: <1400253971.7973.186.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/14 at 08:26am, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 16:20 +0100, Thomas Graf wrote:
> 
> > I'm aware of the work and I agree. That is perfectly fine if the
> > produced skbs do not get enqueued and modified. Otherwise the clone
> > and COW will undo the gain again. I need pktgen to produce large,
> > linear skbs with a unique flow for each individual packet. Hence this
> > optimization ;-)
> 
> pktgen is a tool for us kernel net developers.
> 
> I doubt more than 20 people on this planet used it in the last 12
> months, expecting crazy numbers out of one core, while a simple user
> space program can outperform pktgen these days.
> 
> So if you need a very specific hack, you can do it on your local tree ;)

Which I already stated I'd be fine with ;)

But for the sake of the argument... Since you mention that pktgen is
clearly a tool for us kernel net developers. That would (hopefully)
imply that everybody using it knows what they are doing. Just like
somebody running kgdb, dumping kernel memory with kdump, or running
perf. I don't see why the choice of deliberately exposing kernel memory
in either of these cases is an issue.
