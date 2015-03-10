From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] rhashtable: Move hash_rnd into bucket_table
Date: Tue, 10 Mar 2015 17:20:02 +0000
Message-ID: <20150310172002.GA13155@casper.infradead.org>
References: <20150309222631.GA12221@gondor.apana.org.au>
 <E1YV69T-0003DX-CV@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39387 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbbCJRUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:20:06 -0400
Content-Disposition: inline
In-Reply-To: <E1YV69T-0003DX-CV@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/15 at 09:27am, Herbert Xu wrote:
> Currently hash_rnd is a parameter that users can set.  However,
> no existing users set this parameter.  It is also something that
> people are unlikely to want to set directly since it's just a
> random number.
> 
> In preparation for allowing the reseeding/rehashing of rhashtable,
> this patch moves hash_rnd into bucket_table so that it's now an
> internal state rather than a parameter.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I assume you are targeting net-next?

Acked-by: Thomas Graf <tgraf@suug.ch>
