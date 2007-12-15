From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 21:44:18 -0800
Message-ID: <20071214214418.0ecd5e67.akpm@linux-foundation.org>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au>
	<20071214002209.ac748206.akpm@linux-foundation.org>
	<20071214083037.GA15602@gondor.apana.org.au>
	<20071214.111514.03773174.davem@davemloft.net>
	<20071214151136.ae0f969b.akpm@linux-foundation.org>
	<20071215041827.GC25324@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48188 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbXLOFp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 00:45:26 -0500
In-Reply-To: <20071215041827.GC25324@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Dec 2007 12:18:27 +0800 Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Dec 14, 2007 at 03:11:36PM -0800, Andrew Morton wrote:
> >
> > I don't believe that ASSERT_RTNL() presently warns when called from atomic
> > contexts.  If it does then I missed it.
> 
> It does when mutex debugging is enabled.
> 

That sounds like a bug in mutex_trylock() to me.

Where in the tangled forest of the mutex implementation is the code
which does this?
