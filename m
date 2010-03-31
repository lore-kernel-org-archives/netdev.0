From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 22:15:25 +0800
Message-ID: <20100331141525.GA14331@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au> <20100331132622.GA13908@gondor.apana.org.au> <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi> <20100331135505.GC14082@gondor.apana.org.au> <1270044768.26743.58.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48279 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756436Ab0CaOPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:15:42 -0400
Content-Disposition: inline
In-Reply-To: <1270044768.26743.58.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 10:12:48AM -0400, jamal wrote:
> On Wed, 2010-03-31 at 21:55 +0800, Herbert Xu wrote:
> 
> > Eliding the notification if SELinux says so is fine, but eliding
> > it because the table is empty is wrong.
> > 
> > The flush did not fail just because the table was empty to begin
> > with.
> 
> Like i said i didnt touch the behavior except for the selinux case
> (which sounds very reasonable). I believe there maybe historical legacy
> reasons for that semantic in pfkey. 
> Can you point to something in the kernel (or anywhere else) that behaves
> like this on table flushing? Actually if there was an app that depended
> on netlink flush being exposed on empty table - then i think theres
> reason for a revert.
> Other than that i will say again: i respectfully disagree.

OK I give up.

Dave can keep or revert this as he likes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
