From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Thu, 24 Sep 2015 11:21:00 +0800
Message-ID: <20150924032100.GA27649@gondor.apana.org.au>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
 <20150924024608.GA25502@htj.duckdns.org>
 <20150924025435.GB27355@gondor.apana.org.au>
 <20150924030609.GA26853@htj.duckdns.org>
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
In-Reply-To: <20150924030609.GA26853@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2015 at 11:06:09PM -0400, Tejun Heo wrote:
> 
> I think this is where we're not agreeing.  My point is that better
> understanding and lower likelihood of bug doesn't equate specializing
> each usage site.  That's a lot more likely to lead to unnecessary
> cognition overhead and naturally errors.  There's no reason to require
> such error-prone and specific understanding of each usage site when we
> can have agreed-upon abstractions which yield invariants which are a
> lot easier for people to wrap their heads around.

Well we'll have to agree to disagree on that one.  I have seen too
many instances over the years where people post patches that use
primitives such as RCU and think that they must be safe because
it compiles with no warnings (and probably even runs).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
