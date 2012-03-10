From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Namespaces and inetpeer
Date: Sun, 11 Mar 2012 00:25:29 +1100
Message-ID: <20120310132529.GA3631@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:52651 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753984Ab2CJNZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 08:25:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

While looking through the inetpeer code I noticed that there is
no namespace support at all.  This means that metric and other
information will be leaking across namespaces.  As IP addresses
are meant to be independent between them, this is not a good thing.

We need to get the namespace folks to fix this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
