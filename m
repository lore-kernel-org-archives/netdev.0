From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO restructuring?
Date: Tue, 12 Aug 2008 09:53:21 +0800
Message-ID: <20080812015321.GA19011@gondor.apana.org.au>
References: <20080811.175434.215224347.davem@davemloft.net> <20080812010004.GD18547@gondor.apana.org.au> <48A0E7A3.6030200@hp.com> <20080811.183913.09225669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, gallatin@myri.com, netdev@vger.kernel.org,
	brice@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34162 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750852AbYHLBx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:53:28 -0400
Content-Disposition: inline
In-Reply-To: <20080811.183913.09225669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 06:39:13PM -0700, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 11 Aug 2008 18:30:11 -0700
> 
> > Even if it was verified I think you want to keep the checksums from the 
> > header.   Since an intermediate device isn't supposed to be peeking at 
> > the TCP part anyway, it wouldn't do to drop the segment ourselves, pass 
> > it along to be dropped by the ultimate reciever.  And if there is 
> > something amis in the verification or the regeneration, we don't want to 
> >   introduce silent data corruption.

Well I wasn't suggesting that it be dropped, but simply skip LRO
if the inbound packet fails the checksum check.

But yeah, it's only two bytes so we might as well always have it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
