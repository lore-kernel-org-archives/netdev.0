From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 10/14] ipv4: Use 32-bit loads for ID and length in GRO
Date: Thu, 28 May 2009 07:26:49 +1000
Message-ID: <20090527212649.GB22052@gondor.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au> <E1M9B5x-0001Sw-RR@gondolin.me.apana.org.au> <87zlcymnnf.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53848 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750964AbZE0V0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 17:26:53 -0400
Content-Disposition: inline
In-Reply-To: <87zlcymnnf.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2009 at 08:00:36PM +0200, Andi Kleen wrote:
>
> On what architecture is that faster?
> 
> At least on x86 they should be the same performance, except that
> the 16bit one is one byte larger, but that shouldn't make a difference.

It shrunk the code by more than a byte, at least with some versions
of gcc on x86-64.

Yes some of these patches might seem a tad trivial, but it does add
up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
