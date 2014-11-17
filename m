From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Mon, 17 Nov 2014 06:16:54 +0000
Message-ID: <20141117061654.GA8723@casper.infradead.org>
References: <20141116022227.GA24541@gondor.apana.org.au>
 <7DA2F716-1E87-4AC8-A18F-CE5BFB6E6F81@joshtriplett.org>
 <20141117044657.GA30723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52973 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaKQGQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 01:16:56 -0500
Content-Disposition: inline
In-Reply-To: <20141117044657.GA30723@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/14 at 12:46pm, Herbert Xu wrote:
> On Sat, Nov 15, 2014 at 06:37:26PM -0800, Josh Triplett wrote:
> > On November 15, 2014 6:22:27 PM PST, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > >Josh Triplett <josh@joshtriplett.org> wrote:
> > >>
> > >> - Set up the new empty table with the new set of hash parameters.
> > >> - synchronize_rcu().  Readers will now search both old and new
> > >tables.
> > >> - Peel nodes off the ends of the old hash table and add them to the
> > >new
> > >
> > >We currently use a singly linked list in rhashtable.  Peeling nodes
> > >off the end would mean upgrading to a doubly linked list, which is
> > >no different than keeping two lists in terms of cache footprint, no?
> > 
> > No, since each pass just handles one set of nodes from each bucket anyway, you can just do a bit more work in the rehasher instead.
> 
> OK let me see if I could implement something like that in rhashtable.

This sounds great. Thanks Herbert and Josh!
