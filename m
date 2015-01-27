From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 22:23:04 +1100
Message-ID: <20150127112304.GA4548@gondor.apana.org.au>
References: <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
 <20150127111604.GF22262@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150127111604.GF22262@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 27, 2015 at 11:16:04AM +0000, Thomas Graf wrote:
> 
> No objection. I have a patch prepared which allows the user to
> provide ht->mutex himself so nfset can provide its own existing
> mutex to rhashtable and lock out the resizes from inserts,
> removals and dump iterations automatically That would restore the
> old behaviour of the nfset API without major surgery.

If you take the mutex you might as well just make it synchronous.
There is zero difference.

Maybe you misunderstood my email.  I'm not making it synchronous
for everybody, just those that always take a lock on inserts/removals
and therefore don't need per-bucket locks.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
