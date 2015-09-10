From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Thu, 10 Sep 2015 12:05:27 +0200
Message-ID: <20150910100527.GX7029@orbit.nwl.cc>
References: <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
 <20150901140341.GA13757@gondor.apana.org.au>
 <20150901141305.GA11564@pox.localdomain>
 <20150901141639.GA13856@gondor.apana.org.au>
 <20150901145124.GC11564@pox.localdomain>
 <20150910080344.GA28214@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150910080344.GA28214@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 10, 2015 at 04:03:44PM +0800, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 04:51:24PM +0200, Thomas Graf wrote:
> > 
> > 1. The current in-kernel self-test
> > 2. bind_netlink.c: https://github.com/tgraf/rhashtable
> 
> I can't reproduce it:

I can't speak for netlink, but if you apply patch 1/3 from this thread,
test_rhashtable.c starts generating many insert failures during the
multiple thread test.

Cheers, Phil
