From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 3 Aug 2006 19:36:23 +1000
Message-ID: <20060803093623.GC8808@gondor.apana.org.au>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <20060802004929.GA12404@gondor.apana.org.au> <44D1C2B0.5050004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:63493 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932440AbWHCJga
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:36:30 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D1C2B0.5050004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 11:32:32AM +0200, Patrick McHardy wrote:
> 
> The checksum is verified here because a full checksum update is done
> later in that function and we don't want to accidentally fix up
> broken checksums.

Sorry, I missed that.

BTW, we should make sure that we clear CHECKSUM_COMPLETE since at the
end of the function skb->csum no longer contains the payload checksum.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
