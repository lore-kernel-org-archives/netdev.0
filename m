From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Wed, 5 Jul 2006 02:04:35 +0200
Message-ID: <200607050204.35135.ak@suse.de>
References: <adawtazgawi.fsf@cisco.com> <200607050101.12476.ak@suse.de> <1152056909.3285.617.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Tom Tucker <tom@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:5598 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932322AbWGEAEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 20:04:50 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1152056909.3285.617.camel@tahini.andynet.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > Think of the ordinary single linux box somewhere at a rackspace provider which 
> > represents the majority of Linux boxes around. 
> How many of those need 10G nics?

Most of them already have gigabit. At some point they will have 10G too.

Admittedly the iThingy under discussion here seems to be Infiniband only which
will probably not appear in such a use case.

> We're focusing on netfilter here. Is breaking netfilter really the only
> issue with this stuff?

Another concern is that it will just not be able to keep 
up with a high rate of new connections or a high number of them
(because the hardware has too limited state)

And then there are the other issues I listed like subtle TCP bugs
(TSO is already a nightmare in this area and it's still not quite
right) etc. 

> I know you mentioned some other concerns (about 
> TOE specifically), they were really scalability things though weren't
> they 

There was more than just scalability. Reread it.

Anyways the thread is already getting off topic - i'm not actually
that much interested in a generic TOE discussion because the issue
is pretty much settled already with broad consensus. You can refer
to the netdev archives or the respective web pages if you want more
details.

It would need someone who can describe how this new RDMA device avoids
all the problems, but so far its advocates don't seem to be interested
in doing that and I cannot contribute more.

-Andi
