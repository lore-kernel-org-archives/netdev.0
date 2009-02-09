From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] gro: Optimise GRO receive functions
Date: Mon, 9 Feb 2009 14:59:30 +1100
Message-ID: <20090209035930.GA2988@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34961 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753845AbZBID7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 22:59:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This is a split up version of a patch that Divy tested earlier.
I was going to do this earlier but I wanted to track down the
igb/ixgbe regressions first.

After this I'm going to look at moving the skb construction calls
into cxgb3 itself in order to avoid copying the meta data twice.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
