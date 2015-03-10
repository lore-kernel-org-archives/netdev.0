From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Move hash_rnd into bucket_table
Date: Wed, 11 Mar 2015 08:48:39 +1100
Message-ID: <20150310214839.GB28785@gondor.apana.org.au>
References: <20150309222631.GA12221@gondor.apana.org.au>
 <E1YV69T-0003DX-CV@gondolin.me.apana.org.au>
 <20150310172002.GA13155@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48348 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661AbbCJVsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 17:48:50 -0400
Content-Disposition: inline
In-Reply-To: <20150310172002.GA13155@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 05:20:02PM +0000, Thomas Graf wrote:
> On 03/10/15 at 09:27am, Herbert Xu wrote:
> > Currently hash_rnd is a parameter that users can set.  However,
> > no existing users set this parameter.  It is also something that
> > people are unlikely to want to set directly since it's just a
> > random number.
> > 
> > In preparation for allowing the reseeding/rehashing of rhashtable,
> > this patch moves hash_rnd into bucket_table so that it's now an
> > internal state rather than a parameter.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I assume you are targeting net-next?

Yes.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
