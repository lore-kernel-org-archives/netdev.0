From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 21:27:35 +0800
Message-ID: <20080731132735.GA9085@gondor.apana.org.au>
References: <20080731101425.GE23814@xi.wantstofly.org> <20080731.031654.44296685.davem@davemloft.net> <20080731122541.GA29176@xi.wantstofly.org> <20080731.053516.185810642.davem@davemloft.net> <20080731131929.GO10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54363 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750898AbYGaN1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 09:27:47 -0400
Content-Disposition: inline
In-Reply-To: <20080731131929.GO10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 02:19:30PM +0100, Ben Hutchings wrote:
>
> You might want to think about providing a way for soft-GSO to generate
> more lightweight structures than skbs.  The overhead for skb allocation
> becomes quite significant beyond 1 Gbit/s, which is why we added the soft-
> TSO implementation in sfc using per-interface pools of header buffers.  I
> would guess niu would benefit from this sort of approach, though it looks
> like all the other 10G NICs do TSO in hardware/firmware.

We could always provide a library that makes it easier for the
drivers to do TSO in software without allocating skb's.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
