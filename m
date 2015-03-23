From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 6/9] rhashtable: Shrink to fit
Date: Mon, 23 Mar 2015 15:38:20 +0000
Message-ID: <20150323153820.GA20752@casper.infradead.org>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kL-0004IO-CI@gondolin.me.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:56759 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbbCWPiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 11:38:21 -0400
Content-Disposition: inline
In-Reply-To: <E1Ya2kL-0004IO-CI@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 12:50am, Herbert Xu wrote:
> This patch changes rhashtable_shrink to shrink to the smallest
> size possible rather than halving the table.  This is needed
> because with multiple rehashing we will defer shrinking until
> all other rehashing is done, meaning that when we do shrink
> we may be able to shrink a lot.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
