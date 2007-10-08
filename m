From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/7] IPsec: Preparatory patcheds for async crypto on output
Date: Mon, 8 Oct 2007 19:28:18 +0800
Message-ID: <20071008112818.GA3010@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1714 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753403AbXJHL2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:28:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Here is a bunch of patches paving the way for removal of the
state spin lock on the output path so that we can let the crypto
complete asynchronously.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
