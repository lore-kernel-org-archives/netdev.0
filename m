From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 21:11:31 +0800
Message-ID: <20100331131131.GA13793@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:54805 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933284Ab0CaNLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:11:52 -0400
Content-Disposition: inline
In-Reply-To: <1270040773.26743.12.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 09:06:13AM -0400, jamal wrote:
> On Wed, 2010-03-31 at 19:03 +0800, Herbert Xu wrote:
> 
> > This seems to be bogus to me.  Just because the DB was empty
> > before the flush doesn't mean that the flush didn't happen.
> 
> Herbert, If a tree falls in a forest and no one is around to hear it,
> does it make a sound? ;->
> A flush event is meant to be a signal to user space that what
> was once a non-empty table is now empty. 

I disagree.  A flush event is a signal that someone has sent a
flush command.  In any case we've had this semantics for years
and I haven't heard a good reason why this should be changed.

> This is a consistent definition of the semantics everywhere tables
> are flushed (not just in Linux)..

Please give specific examples in the kernel.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
