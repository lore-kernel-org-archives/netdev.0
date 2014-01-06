From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon, 6 Jan 2014 13:58:23 +0100
Message-ID: <20140106125823.GA8076@localhost>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
 <1388963586-5049-2-git-send-email-pablo@netfilter.org>
 <20140105234157.GB29910@order.stressinduktion.org>
 <20140106115436.GE28854@breakpoint.cc>
 <20140106124340.GC4611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56167 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbaAFM63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:58:29 -0500
Content-Disposition: inline
In-Reply-To: <20140106124340.GC4611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 01:43:40PM +0100, Hannes Frederic Sowa wrote:
[...]
> > > Hmm, some of them look like good candidates for net_get_random_once. I don't
> > > see such a problem with draining entropy pool, especially as they don't run
> > > that early and they don't request so many random bits.
> > 
> > I specifically did not use net_get_random_once once because checkentry is
> > not a hotpath.
> > 
> > I don't see why get_random_bytes use increases the security margin, especially
> > considering none of these hashes have periodic run-time rehashing?
> > 
> > But sure, if you think this change is a problem, Pablo can just revert it.
> 
> I don't know if it is a real problem. Most of the time the initial seed
> should be enough, but I guess get_random_bytes would still be a more
> defensive choice. I would have used it. ;)

OK, I have reverted this patch, thanks.
