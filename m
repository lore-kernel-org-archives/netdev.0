From: Andrew Vagin <avagin@parallels.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sun, 30 Dec 2012 01:19:39 +0400
Message-ID: <20121229211938.GC4350@paralelels.com>
References: <20121229092417.GA4038@paralelels.com>
 <1356789203.21409.3923.camel@edumazet-glaptop>
 <20121229145030.GA7959@paralelels.com>
 <1356802828.21409.4623.camel@edumazet-glaptop>
 <1356807516.4102.4.camel@edumazet-laptop>
 <1356810062.21409.4991.camel@edumazet-glaptop>
 <20121229200848.GA3389@paralelels.com>
 <1356815546.21409.5277.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: <netdev@vger.kernel.org>, <vvs@parallels.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:33889 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149Ab2L2VUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 16:20:13 -0500
Content-Disposition: inline
In-Reply-To: <1356815546.21409.5277.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 01:12:26PM -0800, Eric Dumazet wrote:
> On Sun, 2012-12-30 at 00:08 +0400, Andrew Vagin wrote:
> 
> > Is it right, that a received window will be less, if packets are not sorted?
> > Looks like a bug.
> 
> Not really a bug.
> 
> TCP is very sensitive to packet reorders. I wont elaborate here as
> its a bit off topic.
> 
> Try to reorders credits/debits on your bank account, I am pretty sure
> you'll lose some money or even get serious troubles.
> 
> Of course, enabling GRO on eth0 would definitely help a bit...
> 
> (once/iff veth driver features are fixed to allow GSO packets being
> forwarded without being segmented again)
> 

Eric, thank you for the help.
I need time for thinking. I will ask you, if new questions will appear.

> 
> 
