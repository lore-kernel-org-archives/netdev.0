From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 7/9] rhashtable: Add multiple rehash support
Date: Mon, 23 Mar 2015 16:37:09 +0000
Message-ID: <20150323163709.GB20752@casper.infradead.org>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kM-0004If-GN@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57033 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbCWQhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 12:37:11 -0400
Content-Disposition: inline
In-Reply-To: <E1Ya2kM-0004If-GN@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 12:50am, Herbert Xu wrote:
> This patch adds the missing bits to allow multiple rehashes.  The
> read-side as well as remove already handle this correctly.  So it's
> only the rehasher and insertion that need modification to handle
> this.
> 
> Note that this patch doesn't actually enable it so for now rehashing
> is still only performed by the worker thread.
> 
> This patch also disables the explicit expand/shrink interface because
> the table is meant to expand and shrink automatically, and continuing
> to export these interfaces unnecessarily complicates the life of the
> rehasher since the rehash process is now composed of two parts.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
