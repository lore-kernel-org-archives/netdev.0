From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Thu, 24 Sep 2015 11:42:14 +0800
Message-ID: <20150924034214.GA27843@gondor.apana.org.au>
References: <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
 <20150924024608.GA25502@htj.duckdns.org>
 <20150924025435.GB27355@gondor.apana.org.au>
 <20150924030609.GA26853@htj.duckdns.org>
 <20150924032100.GA27649@gondor.apana.org.au>
 <20150924032928.GB26853@htj.duckdns.org>
 <20150924033117.GA27754@gondor.apana.org.au>
 <20150924034116.GC26853@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150924034116.GC26853@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2015 at 11:41:16PM -0400, Tejun Heo wrote:
> On Thu, Sep 24, 2015 at 11:31:17AM +0800, Herbert Xu wrote:
> > No this isn't what happened.  My error was trying to see if there
> > is a way to do it without barriers.  In the end there wasn't.  This
> > has nothing to do with using primitives.
> 
> Hmmm... yeah, you can say that, but it still was a failure to
> recognize and apply the common pattern and what you're suggesting is
> deviating for no good reason.  It demands a lot of cognitive overhead
> for something which should be routine and makes the code a lot more
> fragile as a result.  Things like this make barrier usages difficult
> to understand and verify because it takes away a lot of ready-made
> cognitive tools.  So, let's please stick to the known pattern.

Well I disagree so let's leave it at that.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
