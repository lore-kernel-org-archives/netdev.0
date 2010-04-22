From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 duplicate address detection erroneously marking address
	as duplicate when a host receives its own multicast packets?
Date: Thu, 22 Apr 2010 10:41:40 +0800
Message-ID: <20100422024140.GA7215@gondor.apana.org.au>
References: <4BCFA615.8060205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sam.cannell@catalyst.net.nz, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:44094 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755563Ab0DVClw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 22:41:52 -0400
Content-Disposition: inline
In-Reply-To: <4BCFA615.8060205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:
> 
> Well, my initial reaction is XVM is doing the wrong thing looping-back
> multicast packets.  You can try the following (untested) patch, I can
> only confirm it compiles.

I agree, whatever is looping the packet back should be fixed.

And if we are going to filter them out at our end, then it should
be done below IP.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
