From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 12:56:40 +0300
Message-ID: <20090131095640.GA29099@ioremap.net>
References: <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com> <20090131093123.GA28151@ioremap.net> <49841E8C.60401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:40721 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842AbZAaJ4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 04:56:42 -0500
Content-Disposition: inline
In-Reply-To: <49841E8C.60401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2009 at 10:49:00AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> It appears you are always right, I have nothing to say then.
> 
> Stupid I am.
> 
> I vote for plain revert of your initial patch, since you are anaware
> of performance problems it introduces. Then, probably nobody cares
> of my complaints, so dont worry.

Eric, do not get it soo personally :) After all it is only a matter of
how we enjoy the process and have fun with the development.

Really, I appreciate your work and help, and likely this
misunderstanding happened because of a bad mix of the original bug and
this performance implication. Original bug has really nothing with what
we discuss here. And while the performance problem with bound sockets
creation may be visible, I did not observe it, while the idea
implemented with this approach shows up clearly in the graph I posted.
So I vote by both hands to further improve it by moving things around so
that there would be no unneded cache flushes during update of this
field.

-- 
	Evgeniy Polyakov
