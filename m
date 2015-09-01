From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 22:03:41 +0800
Message-ID: <20150901140341.GA13757@gondor.apana.org.au>
References: <20150829090701.GN20760@orbit.nwl.cc>
 <20150830074717.GA25396@gondor.apana.org.au>
 <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46730 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbbIAODv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 10:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20150901135618.GD27550@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 03:56:18PM +0200, Phil Sutter wrote:
> 
> Looking at rhashtable_test.c, I see the initial table size is 8 entries.
> 70% of that is 5.6 entries, so background expansion is started after the
> 6th entry has been added, right? Given there are 10 threads running
> which try to insert 50k entries at the same time, I don't think it's
> unlikely that three more entries are inserted before the background
> expansion completes.

Yes but in that case the GFP_ATOMIC allocation should work because
the table is so small anyway.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
