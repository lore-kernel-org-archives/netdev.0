From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] xfrm: Do not hash socket policies
Date: Thu, 13 Nov 2014 17:00:49 +0800
Message-ID: <20141113090048.GA3120@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54677 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbaKMJA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 04:00:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen:

I'm working on converting the xfrm policy hashing over to RCU
due to performance complaints.  While doing this I noticed that
we're needlessly hashing socket policies.

Here are two patches to get rid of that and slightly clean things
up.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
