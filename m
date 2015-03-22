From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 2/10] rhashtable: Eliminate unnecessary branch in
 rht_key_hashfn
Date: Sun, 22 Mar 2015 11:07:55 +0000
Message-ID: <20150322110755.GC1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarY-0000ur-2v@gondolin.me.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:50020 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbCVLH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 07:07:57 -0400
Content-Disposition: inline
In-Reply-To: <E1YZarY-0000ur-2v@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 07:04pm, Herbert Xu wrote:
> When rht_key_hashfn is called from rhashtable itself and params
> is equal to ht->p, there is no point in checking params.key_len
> and falling back to ht->p.key_len.
> 
> For some reason gcc couldn't figure out that params is the same
> as ht->p.  So let's help it by only checking params.key_len when
> it's a constant.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

A comment to document this gcc hack would be nice as it's not
obvious from just reading the code. Shouldn't hold up this series
though.

Acked-by: Thomas Graf <tgraf@suug.ch>
