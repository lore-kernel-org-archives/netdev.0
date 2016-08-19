From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3] rhashtable: Remove GFP flag from rhashtable_walk_init
Date: Sat, 20 Aug 2016 00:38:35 +0800
Message-ID: <20160819163835.GA24067@gondor.apana.org.au>
References: <20160818084854.GA11502@gondor.apana.org.au>
 <E1baJ2O-00030u-FE@gondolin.me.apana.org.au>
 <20160819162504.GA29430@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33711 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753911AbcHSQjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:39:01 -0400
Content-Disposition: inline
In-Reply-To: <20160819162504.GA29430@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 06:25:04PM +0200, Thomas Graf wrote:
> On 08/18/16 at 04:50pm, Herbert Xu wrote:
> > +/* Obsolete function, do not use in new code. */
> > +static inline int rhashtable_walk_init(struct rhashtable *ht,
> > +				       struct rhashtable_iter *iter, gfp_t gfp)
> > +{
> > +	rhashtable_walk_enter(ht, iter);
> > +	return 0;
> > +}
> 
> Converting the 5 users of rhashtable_walk_init() looks very straight
> forward, any reason to keep this around?

It is easy but it's needless churn, especially since we've just
converted all of them the other way.

Feel free to do a patch on top of this to get rid of them.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
