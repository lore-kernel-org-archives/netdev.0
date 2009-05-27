From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 10/14] ipv4: Use 32-bit loads for ID and length in GRO
Date: Wed, 27 May 2009 20:00:36 +0200
Message-ID: <87zlcymnnf.fsf@basil.nowhere.org>
References: <20090527044539.GA32372@gondor.apana.org.au>
	<E1M9B5x-0001Sw-RR@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49579 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbZE0SAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 14:00:38 -0400
In-Reply-To: <E1M9B5x-0001Sw-RR@gondolin.me.apana.org.au> (Herbert Xu's message of "Wed, 27 May 2009 14:50:29 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> ipv4: Use 32-bit loads for ID and length in GRO
>
> This patch optimises the IPv4 GRO code by using 32-bit loads
> (instead of 16-bit ones) on the ID and length checks in the receive
> function.

On what architecture is that faster?

At least on x86 they should be the same performance, except that
the 16bit one is one byte larger, but that shouldn't make a difference.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
