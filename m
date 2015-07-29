From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Wed, 29 Jul 2015 23:34:28 +0200
Message-ID: <20150729213428.GC15554@orbit.nwl.cc>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
 <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <20150729210618.GF32705@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37022 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753958AbbG2Vec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 17:34:32 -0400
Content-Disposition: inline
In-Reply-To: <20150729210618.GF32705@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 11:06:18PM +0200, Florian Westphal wrote:
> Phil Sutter <phil@nwl.cc> wrote:
[...]
> > +config DEFAULT_TX_QUEUE_LEN
> > +	prompt "Default TX queue length (in packets)" if EXPERT
> > +	int
> > +	default 1000	# Ethernet wants good queues
> > +	help
> > +	  Set the default value of tx_queue_len for newly created network
> > +	  interfaces. It is used by queueing disciplines to determine how many
> > +	  packets to keep in backlog before starting to drop new ones.
> > +
> > +	  The default value of 1000 packets is there for a very long time and
> > +	  in combination with GSO way too big.
> > +
> 
> I can't see how this could be used in a meaningful way.
> 
> No distro is going to touch this.
> 
> I don't think sysctl value would help either.

I just didn't want to introduce yet another magic value assignment. It's
merely a #define with a little flexibility and a subtle note that the
default should be changed attached.

Cheers, Phil
