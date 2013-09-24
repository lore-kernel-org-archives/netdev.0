From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 18:01:45 +0200
Message-ID: <20130924160145.GB26769@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47997 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab3IXQBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:01:46 -0400
Content-Disposition: inline
In-Reply-To: <1380001118.3165.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 10:38:38PM -0700, Eric Dumazet wrote:
> On Tue, 2013-09-24 at 05:35 +0200, Hannes Frederic Sowa wrote:
> 
> > > build_ehash_secret builds up the data which seeds fragmentation ids, ephermal
> > > port randomization etc. Could we drop the check of sock->type? I guess the
> > > idea was that in-kernel sockets of type raw/udp do not seed the keys when no
> > > entropy is available?
> > 
> > Would this be better (I checked inet_ehash_secret, ipv6_hash_secret
> > and net_secret to actual get initialized)?
> > 
> 
> inet_ehash_secret is used only to make jhash() for tcp ehash, not for
> fragmentation ids or other uses (port randomization).

inet(6)_ehashfn does get used by udp btw. But I do not understand the code,
yet. ;)
