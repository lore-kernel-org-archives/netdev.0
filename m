From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 16:02:20 -0700
Message-ID: <20100414160220.43a62999@nehalam>
References: <1265568122.3688.36.camel@bigi>
	<1271245986.3943.55.camel@bigi>
	<t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop>
	<1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam>
	<1271276568.4567.59.camel@bigi>
	<1271276855.16881.1756.camel@edumazet-laptop>
	<z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	<1271278661.16881.1761.camel@edumazet-laptop>
	<v2s412e6f7f1004141551u5764604h3ab092ee9e70a650@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44850 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756094Ab0DNXJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 19:09:23 -0400
In-Reply-To: <v2s412e6f7f1004141551u5764604h3ab092ee9e70a650@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Apr 2010 06:51:29 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Thu, Apr 15, 2010 at 4:57 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > RPS can be tuned (Changli wants a finer tuning...), it would be
> > intereting to tune multiqueue devices too. I dont know if its possible
> > right now.
> >
> > On my Nehalem machine (16 logical cpus), its NetXtreme II BCM57711E
> > 10Gigabit has 16 queues. It might be good to use less queues according
> > to your results on some workloads, and eventually use RPS on a second
> > layering.
> 
> My idear is: run a daemon in userland to monitor the softnet
> statistics, and tun the RPS setting if necessary. It seems that the
> current softnet statistics data isn't correct.
> 
> Long time ago, I did a test, and the conclution was
> call_function_single IPI was more expensive than resched IPI, so I
> moved to kernel thread from softirq for packet processing. I'll redo
> the test later.
> 

The big thing is data, data, data... Performance can only be examined
with real hard data with multiple different kind of hardware.  Also, check for
regressions in lmbench and TPC benchmarks. Yes this is hard, but papers
on this would allow for rational rather than speculative choices.

Adding more tuning knobs is not the answer unless you can show when
the tuning helps.

-- 
