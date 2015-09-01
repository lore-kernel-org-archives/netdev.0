From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 14:46:48 +0200
Message-ID: <20150901124648.GA27550@orbit.nwl.cc>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150901114300.GB12691@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 01, 2015 at 07:43:00PM +0800, Herbert Xu wrote:
> On Mon, Aug 31, 2015 at 01:00:12PM +0200, Phil Sutter wrote:
> > 
> > The variable would be used to track if the worker has failed to allocate
> > memory in background.
> > 
> > Since the failing insertion will be retried, subsequent inserts are not
> > necessary unrelated.
> 
> If an insertion fails it is never retried.  The only thing that is
> retried is the expansion of the table.  So I have no idea what
> you are talking about.

This is not an inherent behaviour of the implementation but general
agreement. The insertion may fail non-permanently (returning -EBUSY),
users are expected to handle this by retrying the operation.

Cheers, Phil
