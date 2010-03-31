From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 21:56:29 +0800
Message-ID: <20100331135629.GD14082@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au> <20100331132622.GA13908@gondor.apana.org.au> <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi> <1270042883.26743.32.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:53500 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933420Ab0CaN4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:56:38 -0400
Content-Disposition: inline
In-Reply-To: <1270042883.26743.32.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 09:41:23AM -0400, jamal wrote:
> 
> On Wed, 2010-03-31 at 09:39 -0400, jamal wrote:
> > 
> > On Wed, 2010-03-31 at 09:32 -0400, jamal wrote:
> > 
> > > I did not touch pfkey. That behavior remains there. 
> > 
> > Sorry - I lied. I did touch pfkey. Here was my reasoning.
> 
> And what I meant by not touching is that "the behavior there
> remains as it was before"

No you've changed it.  PF_KEY will no longer notify if the policy
table is empty.

This is inconsistent with the behaviour of SADB flushes, and the
spirit of RFC2367.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
