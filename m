From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 12:44:26 -0700
Message-ID: <20100414124426.6aee95c3@nehalam>
References: <1265568122.3688.36.camel@bigi>
	<65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	<1265641748.3688.56.camel@bigi>
	<1271245986.3943.55.camel@bigi>
	<t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop>
	<1271271222.4567.51.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35724 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756461Ab0DNToy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 15:44:54 -0400
In-Reply-To: <1271271222.4567.51.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Apr 2010 14:53:42 -0400
jamal <hadi@cyberus.ca> wrote:

> Agreed. So to enumerate, the benefits come in if:
> a) you have many processors
> b) you have single-queue nic
> c) at sub-threshold traffic you dont care about a little latency

There probably needs to be better autotuning for this, there is no reason
that RPS to be steering packets unless the queue is getting backed up.
Some kind of high / low water mark mechanism is needed.

RPS might also interact with the core turbo boost functionality on Intel chips.
Newer chips will make a single core faster if other core can be kept idle.


-- 
