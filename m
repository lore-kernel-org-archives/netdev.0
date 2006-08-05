From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 09:19:59 +1000
Message-ID: <20060805231959.GA25768@gondor.apana.org.au>
References: <20060804101017.GA17393@gondor.apana.org.au> <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <1154797002.5081.21.camel@jzny2> <20060805230517.GA25468@gondor.apana.org.au> <1154819868.5517.34.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33032 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751427AbWHEXUR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:20:17 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154819868.5517.34.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 07:17:48PM -0400, jamal wrote:
>
> So would the holding of the tx lock at the top layer/qdisc_restart level
> not help?

Yes it should so the corresponding fix for tg3 would be simpler.

> Actually the stat i captured was not related to this, rather it was the
> number of times we entered qdisc_is_running and were unable to get a
> packet. I am using the simple pfifo so it cant be the scheduler refusing
> to give us a packet. I have a feeling it is just enthusiastic wake up of
> the tx softirq. Thoughts on this? I will add checks to be sure. 

Interesting.  I can't really think of why it'd do that so some extra
checks would really help.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
