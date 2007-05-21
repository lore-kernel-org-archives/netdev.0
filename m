From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Questions about IPsec and Netfilter
Date: Mon, 21 May 2007 18:03:47 +1000
Message-ID: <E1Hq2rr-0000Jl-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Cc: netdev@vger.kernel.org
To: stern@rowland.harvard.edu (Alan Stern)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1312 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752100AbXEUID7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 04:03:59 -0400
In-Reply-To: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Stern <stern@rowland.harvard.edu> wrote:
> 
> Q4: Is it true that NAT-Traversal isn't implemented for transport mode?

NAT-Traversal works in transport mode but you have the standard problem
that if you've got two peers behind one IPsec gateway then they'll look
the same to you.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
