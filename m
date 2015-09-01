From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 19:43:00 +0800
Message-ID: <20150901114300.GB12691@gondor.apana.org.au>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150831110012.GO20760@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 31, 2015 at 01:00:12PM +0200, Phil Sutter wrote:
> 
> The variable would be used to track if the worker has failed to allocate
> memory in background.
> 
> Since the failing insertion will be retried, subsequent inserts are not
> necessary unrelated.

If an insertion fails it is never retried.  The only thing that is
retried is the expansion of the table.  So I have no idea what
you are talking about.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
