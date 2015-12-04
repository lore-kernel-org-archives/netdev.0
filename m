From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: ENOMEM errors when hit with a flood of insertions
Date: Fri, 4 Dec 2015 08:07:02 +0800
Message-ID: <20151204000702.GA8863@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203125117.GB5505@gondor.apana.org.au>
 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 03, 2015 at 08:08:39AM -0800, Eric Dumazet wrote:
>
> Well, it will fail before this point if memory is fragmented.

Indeed, I was surprised that it even worked up to that point,
possibly because the previous resizes might have actually been
done in process context.

> Anyway, __vmalloc() can be used with GFP_ATOMIC, have you tried this ?

Ah I didn't know that.  That would be much simpler.  I'll give it a
try.

Thanks Eric!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
