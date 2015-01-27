From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 13:09:50 +0000
Message-ID: <20150127130950.GA3950@acer.localdomain>
References: <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
 <20150127111604.GF22262@casper.infradead.org>
 <20150127112304.GA4548@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42382 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbbA0NJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 08:09:57 -0500
Content-Disposition: inline
In-Reply-To: <20150127112304.GA4548@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.01, Herbert Xu wrote:
> On Tue, Jan 27, 2015 at 11:16:04AM +0000, Thomas Graf wrote:
> > 
> > No objection. I have a patch prepared which allows the user to
> > provide ht->mutex himself so nfset can provide its own existing
> > mutex to rhashtable and lock out the resizes from inserts,
> > removals and dump iterations automatically That would restore the
> > old behaviour of the nfset API without major surgery.
> 
> If you take the mutex you might as well just make it synchronous.
> There is zero difference.
> 
> Maybe you misunderstood my email.  I'm not making it synchronous
> for everybody, just those that always take a lock on inserts/removals
> and therefore don't need per-bucket locks.

Actually I have a patchset queued that adds runtime additions and
removals, both active and timeout based. So netfilter won't have
pure synchronous behaviour anymore.
