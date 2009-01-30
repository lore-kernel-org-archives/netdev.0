From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] GRO optimisations
Date: Fri, 30 Jan 2009 11:18:49 +1100
Message-ID: <20090130001849.GA1272@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37707 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751601AbZA3ASx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:18:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This is a dump of my current patches to optimise GRO in order
to get cxgb3 performance back up to the LRO level.  I've got
some more ideas but I'd like to get this out first so it doesn't
rot in my tree.

Oh and of course a direct LRO comparison isn't exactly fair because
LRO skipped some tests such as checking the IP header checksum
(naughty :) so the current 5.7 vs. 6.1 figure isn't all that bad.

But I think we should be able to get back to 6Gb/s with cxgb3
at least.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
