From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Possible netlink autobind regression
Date: Thu, 17 Sep 2015 11:08:45 +0800
Message-ID: <20150917030845.GA19162@gondor.apana.org.au>
References: <20150917022909.GA22754@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tom@herbertland.com, kafai@fb.com,
	kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150917022909.GA22754@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2015 at 10:29:09PM -0400, Tejun Heo wrote:
>
> Anyways, after the patch, it seems something like the following could
> happen.

Good catch! I think your explanation makes perfect sense.  Linus
ran into this previously too after suspend-and-resume.

I'll look into it.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
