From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 15:06:16 +1000
Message-ID: <20070531050616.GA32391@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <465E0149.6030307@intel.com> <20070531005147.GA30628@gondor.apana.org.au> <465E5442.7010503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Chapman <doug.chapman@hp.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4828 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753366AbXEaFGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 01:06:23 -0400
Content-Disposition: inline
In-Reply-To: <465E5442.7010503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 09:51:14PM -0700, Kok, Auke wrote:
> 
> this has been an age-old confusion that I never grasped either, so I 
> perfectly understand why you added the explicit e1000_disable_irq call in 
> the other patch (and think thats a great idea). But really, there should be 
> a way for a driver to tell the stack that it should really keep it's hands 
> off :)

Well yes, you can get the stack to keep away by not registering your
device :)

> BTW e1000 currently triggers a single irq manually in the watchdog as link 
> goes up, so that might be the one that is giving problems now. In any case 
> I can't reproduce any of it - perhaps my hardware is too fast. Time to whip 
> out the pIII :o

Hmm, if it's triggered by the watchdog then that means the watchdog has
been scheduled.  However, it seems that the only way to schedule it is
through an interrupt?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
