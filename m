From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Sat, 17 Jan 2015 21:13:10 +1100
Message-ID: <20150117101309.GA19585@gondor.apana.org.au>
References: <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116204921.GA14833@gondor.apana.org.au>
 <20150116213156.GA7109@acer.localdomain>
 <20150117003340.GA16374@gondor.apana.org.au>
 <20150117080621.GB3968@acer.localdomain>
 <20150117093228.GA19137@gondor.apana.org.au>
 <7AE5EEE0-60C7-43B4-848A-2D952D3A6DEF@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7AE5EEE0-60C7-43B4-848A-2D952D3A6DEF@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 17, 2015 at 09:51:46AM +0000, Patrick McHardy wrote:
> 
> I agree, however at least in the case of nftables you can easily do the same thing by adding millions of rules.

I think that's a problem in itself.  If a single packet can kill
the CPU through millions of rules, then namespaces would be a joke.
There has to be a limit to the number of rules or the processing
has to be deferred into thread context (thus subject to scheduler
control) at some point.

> It doesn't make things worse.

So I don't think that's a valid justification for ignoring this
hash table problem.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
