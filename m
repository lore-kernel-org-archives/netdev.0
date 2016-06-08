From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Wed, 8 Jun 2016 10:39:57 +0800
Message-ID: <20160608023957.GA12209@gondor.apana.org.au>
References: <5751E702.5040909@gmx.de>
 <20160604073527.GE29740@orbyte.nwl.cc>
 <20160606035718.GA19559@gondor.apana.org.au>
 <5756D69E.1080402@gmx.de>
 <20160607141656.GB2237@gondor.apana.org.au>
 <5756DE80.4040705@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41381 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbcFHCkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 22:40:08 -0400
Content-Disposition: inline
In-Reply-To: <5756DE80.4040705@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 04:47:28PM +0200, Helge Deller wrote:
> On 07.06.2016 16:16, Herbert Xu wrote:
> > On Tue, Jun 07, 2016 at 04:13:50PM +0200, Helge Deller wrote:
> >>
> >> What warnings do you mean specifically? Some specific CONFIG_ option ?
> > 
> > Look for GFP_NOWARN in lib/rhashtable.c and delete it.
> 
> Ok, removed it.
> It generates a kernel warning: 

Thanks.  This is exactly the problem that I'm yet to fix, namely
we're trying to allocate a hash table that's too big to be done
using physically contiguous memory.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
