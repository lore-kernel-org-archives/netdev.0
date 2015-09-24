From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Wed, 23 Sep 2015 23:06:09 -0400
Message-ID: <20150924030609.GA26853@htj.duckdns.org>
References: <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
 <20150924024608.GA25502@htj.duckdns.org>
 <20150924025435.GB27355@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150924025435.GB27355@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Sep 24, 2015 at 10:54:36AM +0800, Herbert Xu wrote:
> What I am concerned about is the next guy who comes along and
> does a rewrite like the one that introduced the netlink_bind
> bug.  That person needs to fully understand what each primitive
> is protecting against.
> 
> Using primitives where they're not needed can lead to misunderstandings
> which may end up causing bugs.

I think this is where we're not agreeing.  My point is that better
understanding and lower likelihood of bug doesn't equate specializing
each usage site.  That's a lot more likely to lead to unnecessary
cognition overhead and naturally errors.  There's no reason to require
such error-prone and specific understanding of each usage site when we
can have agreed-upon abstractions which yield invariants which are a
lot easier for people to wrap their heads around.

This isn't an isolated one-off barrier hack.  This is a
well-established pattern and sure there are cases we wanna deconstruct
that and make exceptions but that needs to be justifiable.  The
overhead gotta buy us something.  Here it just doesn't.

Thanks.

-- 
tejun
