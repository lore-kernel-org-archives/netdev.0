From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TX time stamping
Date: Fri, 20 Mar 2009 10:10:50 +0800
Message-ID: <20090320021050.GA7021@gondor.apana.org.au>
References: <1236105081.4653.68.camel@pohly-MOBL> <20090319.140509.152824531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: patrick.ohly@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56850 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753108AbZCTCK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 22:10:57 -0400
Content-Disposition: inline
In-Reply-To: <20090319.140509.152824531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 02:05:09PM -0700, David Miller wrote:
>
> Instead, we have a half-working turd in a tree, and I'm removing it.

Yes, we need to spend a bit more time pondering the semantics
of all this.

First of all, if a packet bifurcates and is transmitted through
two interfaces both capable of timestamping, which event do we
take as the timestamp of the original packet?

As to the problem of skb->sk, I don't think that's even needed
as we can simply use the skb shared area as the communication
medium.  However, for that to work we need to figure out what
we do when the packet becomes two independent entities, hence
we need to resolve the above question first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
