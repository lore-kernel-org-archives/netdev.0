From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Wed, 23 Sep 2015 23:29:28 -0400
Message-ID: <20150924032928.GB26853@htj.duckdns.org>
References: <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
 <20150924024608.GA25502@htj.duckdns.org>
 <20150924025435.GB27355@gondor.apana.org.au>
 <20150924030609.GA26853@htj.duckdns.org>
 <20150924032100.GA27649@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:36251 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932477AbbIXD3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 23:29:33 -0400
Content-Disposition: inline
In-Reply-To: <20150924032100.GA27649@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Sep 24, 2015 at 11:21:00AM +0800, Herbert Xu wrote:
> Well we'll have to agree to disagree on that one.  I have seen too
> many instances over the years where people post patches that use
> primitives such as RCU and think that they must be safe because
> it compiles with no warnings (and probably even runs).

So, while that also has been a common failure mode that we've been
seeing with barrier usages, what you're suggesting isn't the right
balance either.  It's error-prone in a different way as amply
exemplified in this very thread.  It ended up making what should have
been a straight-forward writer-reader interlocking into a maze in
which one can easily be lost.  I think you should be able to see that
after this thread.

Both misusages can be solved by understanding and sticking to
established patterns and making exceptions only when explicitly
justifiable and with ample explanation.

Thanks.

-- 
tejun
