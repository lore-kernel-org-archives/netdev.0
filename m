From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 13:58:48 -0700
Message-ID: <20100426135848.76d46c80@nehalam>
References: <u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com>
	<20100426.112244.260086869.davem@davemloft.net>
	<4BD5F553.6020006@hp.com>
	<20100426.134051.232750473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47210 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679Ab0DZU7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 16:59:09 -0400
In-Reply-To: <20100426.134051.232750473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Apr 2010 13:40:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 26 Apr 2010 13:19:31 -0700
> 
> > As a networking guy I can see why it seems baffling, but stepping out
> > of myself and thinking like the customers with whom I've interacted
> > over the years, it is not baffling at all.
> 
> <sarcasm>
> And hey nobody is using SCTP either, that's right, nobody...
> </sarcasm>
> 
> Look, don't try to defend this abomination of a situation with some
> "customers only use TCP" argument.  It only makes the situation look
> even more absurd.  
> 
> Furthermore, people test system scalability using tools like pktgen,
> which surprise surprise generates streams of UDP packets.  Most
> hardware based scalability testers spew UDP too.
> 
> Everything in the world points to "this toeplitz hash situation is
> stupid an inexcusable."
> 
> If UDP isn't used by anyone, then you tell me why the checksum engines
> of all of these chips can handle them just fine.  Maybe the guy who
> works on the checksum logic blocks doesn't talk to the guy who works
> on the hashing ones?  Maybe the checksum guy can find the ports in a
> UDP packet, but the hashing dude can't locate them?
> 
> What the heck do you think people use for various forms of media
> streaming?  They often use UDP and it has to scale, and they'd like to
> move to DCCP at some point too which is another argument for a fully
> protocol agnostic hash.
> 
> Why do you think Eric Dumazet gives a crap about UDP scalability and
> is constantly testing it?  What about VOIP?  H.323, RTP, etc.?
> 
> Some of these cards can even statelessly offload UDP fragmentation
> too, in silicon, not even in firmware.  What's their excuse for
> screwing up the hash?
> 
> Look, this is a complete joke from every angle, at least admit that
> fact.

I think it is fair to blame Microsoft for this as well. The vendors
follow what Msft tells them to do with NDIS spec. It looks like
IPV6 didn't make it in until the NDIS6.2 (Win7) spec.

-- 
