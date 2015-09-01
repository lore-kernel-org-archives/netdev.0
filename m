From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 22:16:39 +0800
Message-ID: <20150901141639.GA13856@gondor.apana.org.au>
References: <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
 <20150901140341.GA13757@gondor.apana.org.au>
 <20150901141305.GA11564@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150901141305.GA11564@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 01, 2015 at 04:13:05PM +0200, Thomas Graf wrote:
>
> You can easily trigger this outside of the testsuite as well. Open
> 10K Netlink sockets in a loop and the creation of the sockets will
> fail way before memory pressure kicks in.

That means our implementation is buggy.  Do you have a test program?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
