From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 3 Aug 2006 19:30:13 +1000
Message-ID: <20060803093013.GA8808@gondor.apana.org.au>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net> <20060801115102.GA5638@gondor.apana.org.au> <44D1C029.1030300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47621 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932423AbWHCJaZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:30:25 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D1C029.1030300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 11:21:45AM +0200, Patrick McHardy wrote:
> 
> This looks OK. But we also need this for the redirect to loopback case,
> do you want me to put it in dev_gso_segment as well? nfmark and
> secmark should go in skb_segment I guess?

OK, you've convinced me.  Let's put them all into skb_segment.

However, I'd like to have the code shared between skb_segment and
copy_skb_header so we have only one place to add things to in future.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
