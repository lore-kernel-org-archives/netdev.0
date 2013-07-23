From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Wed, 24 Jul 2013 00:52:46 +0200
Message-ID: <20130723225246.GR10216@zirkel.wertarbyte.de>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
 <20130723153829.3b6cb3df@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:55925 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934542Ab3GWWws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 18:52:48 -0400
Content-Disposition: inline
In-Reply-To: <20130723153829.3b6cb3df@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Stephen Hemminger (stephen@networkplumber.org):

> > --- a/include/uapi/linux/fib_rules.h
> > +++ b/include/uapi/linux/fib_rules.h
> > @@ -45,7 +45,7 @@ enum {
> >  	FRA_FLOW,	/* flow/class id */
> >  	FRA_UNUSED6,
> >  	FRA_UNUSED7,
> > -	FRA_UNUSED8,
> > +	FRA_TABLE_PREFIXLEN_MIN,
> >  	FRA_TABLE,	/* Extended table id */
> >  	FRA_FWMASK,	/* mask for netfilter mark */
> >  	FRA_OIFNAME,
> 
> Not sure if reusing an entry or adding a new value is better
> to retain compatibility.

Well, neither am I; my first changesets did in fact act a new value,
but I then switched to reusing an existing one. I am open to suggestions
from people having more experience with the existing code base.

> Also don't you have to update FRA_GENERIC_POLICY?

Well, I'm not sure - as I said, I was glad that I was able to add this
functionality (which I was craving for quite some time now) to the kernel,
so please feel free to point out (and possibly iron out) any issues with it.

Thank you very much for your response
Stefan Tomanek
