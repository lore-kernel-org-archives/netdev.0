From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Tue, 1 Sep 2015 16:51:24 +0200
Message-ID: <20150901145124.GC11564@pox.localdomain>
References: <20150831110012.GO20760@orbit.nwl.cc>
 <20150901114300.GB12691@gondor.apana.org.au>
 <20150901124648.GA27550@orbit.nwl.cc>
 <20150901130057.GA13230@gondor.apana.org.au>
 <20150901134310.GB27550@orbit.nwl.cc>
 <20150901135019.GA13629@gondor.apana.org.au>
 <20150901135618.GD27550@orbit.nwl.cc>
 <20150901140341.GA13757@gondor.apana.org.au>
 <20150901141305.GA11564@pox.localdomain>
 <20150901141639.GA13856@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34296 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbbIAOv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 10:51:27 -0400
Received: by wicjd9 with SMTP id jd9so36069878wic.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 07:51:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150901141639.GA13856@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/15 at 10:16pm, Herbert Xu wrote:
> On Tue, Sep 01, 2015 at 04:13:05PM +0200, Thomas Graf wrote:
> >
> > You can easily trigger this outside of the testsuite as well. Open
> > 10K Netlink sockets in a loop and the creation of the sockets will
> > fail way before memory pressure kicks in.
> 
> That means our implementation is buggy.  Do you have a test program?

1. The current in-kernel self-test
2. bind_netlink.c: https://github.com/tgraf/rhashtable
