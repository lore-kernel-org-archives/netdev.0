From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 09:30:40 +1000
Message-ID: <20060805233040.GA25875@gondor.apana.org.au>
References: <1154642918.5187.13.camel@jzny2> <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au> <20060804083734.GA16082@gondor.apana.org.au> <20060804101017.GA17393@gondor.apana.org.au> <1154686563.5187.43.camel@jzny2> <20060804102557.GA17723@gondor.apana.org.au> <1154819086.5517.25.camel@jzny2> <20060805230655.GB25468@gondor.apana.org.au> <1154820073.5517.38.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:61960 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751404AbWHEXay
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:30:54 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154820073.5517.38.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 07:21:13PM -0400, jamal wrote:
>
> > Hardly surprising since you only have one CPU doing the actual sending.
> 
> Would it make a difference if we had more than one? qdisc_is_running
> ensures only one entering that region.

Good point.  I can probably simplify the e1000 patch then.

> > The only time when this can happen is if we more than one CPU transmitted
> > at the exatly same time.
> 
> Did you mean to the same eth device? 

Yes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
