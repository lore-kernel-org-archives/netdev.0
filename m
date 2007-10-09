From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/7] [IPSEC]: Move common output code to xfrm_output
Date: Tue, 9 Oct 2007 09:02:57 +0800
Message-ID: <20071009010257.GA14117@gondor.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au> <E1Ieqnr-0000o7-00@gondolin.me.apana.org.au> <20071008.171717.71577244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3875 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752198AbXJIBDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 21:03:00 -0400
Content-Disposition: inline
In-Reply-To: <20071008.171717.71577244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 08, 2007 at 05:17:17PM -0700, David Miller wrote:
> 
> Could you submit a 2.6.23 version of just the ipv4 fix?
> It might be interesting to determine why it was omitted,
> perhaps it was an oversight, and it probably predates the
> addition of skb_reset_*().

OK I double-checked and it isn't necessary at all for IPv4 as
the mode output function already sets the correct value in it.

It's needed for IPv6 because the mode output functions there
uses it to store a pointer to the NH pointer.

So no changes are necessary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
