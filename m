From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/6] rhashtable: Fixes + cleanups + preparation for multiple
 rehash
Date: Fri, 13 Mar 2015 20:56:07 +1100
Message-ID: <20150313095607.GA598@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39275 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbbCMJ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:56:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Patch 1 fixes the walker so that it behaves properly even during
a resize.

Patch 2-3 are cleanups.

Patch 4-6 lays some ground work for the upcoming multiple rehashing.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
