From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 2/9] rhashtable: Eliminate unnecessary branch in
 rht_key_hashfn
Date: Mon, 23 Mar 2015 13:58:11 +0000
Message-ID: <20150323135811.GA9478@casper.infradead.org>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kG-0004HI-9N@gondolin.me.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:56164 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbbCWN6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:58:15 -0400
Content-Disposition: inline
In-Reply-To: <E1Ya2kG-0004HI-9N@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 12:50am, Herbert Xu wrote:
> When rht_key_hashfn is called from rhashtable itself and params
> is equal to ht->p, there is no point in checking params.key_len
> and falling back to ht->p.key_len.
> 
> For some reason gcc couldn't figure out that params is the same
> as ht->p.  So let's help it by only checking params.key_len when
> it's a constant.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
