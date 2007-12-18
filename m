From: Paul Moore <paul.moore@hp.com>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Tue, 18 Dec 2007 11:14:45 -0500
Message-ID: <200712181114.46957.paul.moore@hp.com>
References: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au> <475CAF94.7020306@trash.net> <20071210034356.GA31825@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	latten@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:25909 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755942AbXLRQO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 11:14:56 -0500
In-Reply-To: <20071210034356.GA31825@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 09 December 2007 10:43:56 pm Herbert Xu wrote:
> On Mon, Dec 10, 2007 at 04:16:36AM +0100, Patrick McHardy wrote:
> > Won't this break with manually installed SAs (without a keying
> > daemon)?
>
> Well what's being suggested here will already break that anyway :)
>
> Alternatively we can take the interpretation that it's the KM's
> responsibility to set the appropriate hard life time if ESNs are
> not in use.
>
> Either way is fine with me.
>
> Cheers,

Sorry for the delay, I got distracted ...

Rereading the thread it's unclear to me which solution was deemed "correct".  
I'm not a big fan of fiddling/forcing SA lifetimes unless we have no other 
option; if someone is foolish enough to use manual keying with replay 
protection and no mechanism to catch rollover then they most likely have 
larger problems.  It's the whole "we'll provide you with the gun, but you 
have to shoot yourself" argument as applied to SA lifetimes.

However, you guys have to deal with this code more often than I do so I'll 
deffer to your better judgment.

-- 
paul moore
linux security @ hp
