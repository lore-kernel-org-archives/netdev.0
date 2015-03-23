From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 3/9] rhashtable: Allow hashfn to be unset
Date: Mon, 23 Mar 2015 15:36:37 +0000
Message-ID: <20150323153637.GB9478@casper.infradead.org>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kH-0004HZ-IC@gondolin.me.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:56739 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbbCWPgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 11:36:38 -0400
Content-Disposition: inline
In-Reply-To: <E1Ya2kH-0004HZ-IC@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 12:50am, Herbert Xu wrote:
> Since every current rhashtable user uses jhash as their hash
> function, the fact that jhash is an inline function causes each
> user to generate a copy of its code.
> 
> This function provides a solution to this problem by allowing
> hashfn to be unset.  In which case rhashtable will automatically
> set it to jhash.  Furthermore, if the key length is a multiple
> of 4, we will switch over to jhash2.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>

I'll add some documentation when the API stabilizes and multiple
rehashing is complete.
