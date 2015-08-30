From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Sun, 30 Aug 2015 15:47:17 +0800
Message-ID: <20150830074717.GA25396@gondor.apana.org.au>
References: <20150829090701.GN20760@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150829090701.GN20760@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Sutter <phil@nwl.cc> wrote:
>
> Should we introduce a new field to struct rhashtable to track the
> internal state? This might allow to clean up some rather obscure tests,
> e.g. whether a table resize is in progress or not.

Why would we want to do that? The deferred expansion is done
on a best effort basis so its failure has nothing to do with
the failure of a subsequent insertion.

The insertion must have tried its own last-ditch synchronous
expansion and only fail if that fails.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
