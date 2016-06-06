From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Mon, 6 Jun 2016 11:57:18 +0800
Message-ID: <20160606035718.GA19559@gondor.apana.org.au>
References: <5751E702.5040909@gmx.de>
 <20160604073527.GE29740@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, Helge Deller <deller@gmx.de>,
	netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47842 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbcFFD5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 23:57:31 -0400
Content-Disposition: inline
In-Reply-To: <20160604073527.GE29740@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 04, 2016 at 09:35:27AM +0200, Phil Sutter wrote:
> [Cc'ing other interested parties, therefore full-quoting.]
> 
> Hi Helge,
> 
> On Fri, Jun 03, 2016 at 10:22:26PM +0200, Helge Deller wrote:
> > Hi Phil,
> > 
> > I'm testing 4.7.0-rc1-64bit on a parisc/hppa machine and get
> > those message with CONFIG_TEST_RHASHTABLE=y.
> > 
> > Is this expected/normal ?
> 
> No, this shouldn't happen. Can you possibly bisect the issue?

This reminds me that I do still have to tackle the multi-page
kmalloc issue.  This may or may not be the problem here.  Enabling
warnings at the kmalloc call should be an easy way to check.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
