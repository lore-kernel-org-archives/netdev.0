From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO restructuring?
Date: Tue, 12 Aug 2008 09:00:04 +0800
Message-ID: <20080812010004.GD18547@gondor.apana.org.au>
References: <48A03EF9.9090602@myri.com> <20080812005033.GA18547@gondor.apana.org.au> <20080811.175434.215224347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gallatin@myri.com, netdev@vger.kernel.org, brice@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38371 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750762AbYHLBAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:00:07 -0400
Content-Disposition: inline
In-Reply-To: <20080811.175434.215224347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 05:54:34PM -0700, David Miller wrote:
>
> And the checksums :-)  As an intermediate node we don't want
> to touch the checksum.

Yeah if it wasn't verified then we must store this as well.

> The length and the checksum is two u16 values, which would be
> able to fit in a single 32-bit descriptor or something like
> that.

Yep.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
