From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/14] GRO: Lots of microoptimisations
Date: Wed, 27 May 2009 14:45:39 +1000
Message-ID: <20090527044539.GA32372@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50330 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759328AbZE0FNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:13:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This series of patches brings GRO performance to within 1% of LRO
on the slow machine that I was testing.  I can overtake LRO by
deleting the IP checksum test and the Ethernet header test from
GRO, which LRO doesn't do anyway, but that's not very nice :)

I'm still looking at other optimisations as time allows.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
